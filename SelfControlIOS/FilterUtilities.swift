/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	This file contains the FilterUtilities class. FilterUtilities objects contain functions and data that is used by both the SimpleTunnel UI and the SimpleTunnel content filter providers.
*/

import Foundation
import NetworkExtension

/// A class containing utility properties and functions for Content Filtering.
open class FilterUtilities: NSObject {

	// MARK: Properties

	/// A reference to the SimpleTunnel user defaults.
	open static let defaults = UserDefaults(suiteName: "group.com.selfcontrolapp.SelfControlIOS")

	// MARK: Initializers

	/// Get rule parameters for a flow from the SimpleTunnel user defaults.
	open class func getRule(_ flow: NEFilterFlow) -> (SCBlockRuleFilterAction, String, [String: AnyObject]) {
		let hostname = FilterUtilities.getFlowHostname(flow)
        NSLog("Finding rule for hostname %@", hostname);
    
        let blockEndDate = defaults?.object(forKey: "blockEndDate") as? Date
        if (blockEndDate == nil || blockEndDate! < Date()) {
            // block is over or not started, so always return allow!
            // and clear any cruft left in the blockEndDate field
            if (blockEndDate != nil) {
                NSLog("*** Block is over! Removing object")
                defaults?.removeObject(forKey: "blockEndDate")
            } else { NSLog("Allow all, no block.") }
            return (.allow, hostname, [:])
        }
        
		guard !hostname.isEmpty else { return (.allow, hostname, [:]) }

		guard let hostNameRule = (defaults?.object(forKey: "rules") as AnyObject).object(forKey: hostname) as? [String: AnyObject] else {
			NSLog("\(hostname) is set for NO RULES")
			return (.allow, hostname, [:])
		}

		guard let ruleTypeInt = hostNameRule["kRule"] as? Int,
			let ruleType = SCBlockRuleFilterAction(rawValue: ruleTypeInt)
			else { return (.allow, hostname, [:]) }

		return (ruleType, hostname, hostNameRule)
	}

	/// Get the hostname from a browser flow.
	open class func getFlowHostname(_ flow: NEFilterFlow) -> String {
		guard let browserFlow : NEFilterBrowserFlow = flow as? NEFilterBrowserFlow,
			let url = browserFlow.url,
			let hostname = url.host
			, flow is NEFilterBrowserFlow
			else { return "" }
		return hostname
	}

	/// Download a fresh set of rules from the rules server.
	open class func fetchRulesFromServer(_ serverAddress: String?) {
		NSLog("fetch rules called")

		guard serverAddress != nil else { return }
		NSLog("Fetching rules from \(serverAddress)")

		guard let infoURL = URL(string: "http://\(serverAddress!)/rules/") else { return }
		NSLog("Rules url is \(infoURL)")

		let content: String
		do {
			content = try String(contentsOf: infoURL, encoding: String.Encoding.utf8)
		}
		catch {
			NSLog("Failed to fetch the rules from \(infoURL)")
			return
		}

		let contentArray = content.components(separatedBy: "<br/>")
		NSLog("Content array is \(contentArray)")
		var urlRules = [String: [String: AnyObject]]()

		for rule in contentArray {
			if rule.isEmpty {
				continue
			}
			let ruleArray = rule.components(separatedBy: " ")

			guard !ruleArray.isEmpty else { continue }

			var redirectKey = "SafeYes"
			var remediateKey = "Remediate1"
			var remediateButtonKey = "RemediateButton1"
			var actionString = "9"

			let urlString = ruleArray[0]
			let ruleArrayCount = ruleArray.count

			if ruleArrayCount > 1 {
				actionString = ruleArray[1]
			}
			if ruleArrayCount > 2 {
				redirectKey = ruleArray[2]
			}
			if ruleArrayCount > 3 {
				remediateKey = ruleArray[3]
			}
			if ruleArrayCount > 4 {
				remediateButtonKey = ruleArray[4]
			}


			urlRules[urlString] = [
				"kRule" : actionString as AnyObject,
				"kRedirectKey" : redirectKey as AnyObject,
				"kRemediateKey" : remediateKey as AnyObject,
				"kRemediateButtonKey" : remediateButtonKey as AnyObject,
			]
		}
		defaults?.setValue(urlRules, forKey:"rules")
	}
}
