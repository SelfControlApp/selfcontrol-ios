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

    open class func getHostnameRuleObj(_ hostname: String) -> [String: AnyObject]? {
        let rules = (defaults?.object(forKey: "rules") as AnyObject)
        var adjustedHostname = hostname;

        // TODO: special handling for special sites like Facebook, Google, etc that are hard to block for end-users
        
        // These are all subdomains that are usually just the main site, but on a subdomain for some practical reason
        // We'll assume that if the user blocked the root domain, they meant to block these, and if
        // they block these they meant to block them all
        let AUTOINCLUDED_SUBDOMAINS = ["www",
                                       "ww1",
                                       "ww2",
                                       "www1",
                                       "www2",
                                       "secure",
                                       "web",
                                       "app",
                                       "m"]
        
        // first, strip any of the AUTOINCLUDED_SUBDOMAINS, to get to the root domain (or at least one level down)
        for subdomain in AUTOINCLUDED_SUBDOMAINS {
            if (adjustedHostname.hasPrefix("\(subdomain).")) {
                // remove the prefix
                let newStartIndex = adjustedHostname.index(adjustedHostname.startIndex, offsetBy: subdomain.characters.count + 1)
                adjustedHostname = adjustedHostname.substring(from: newStartIndex)
                
                // break so we don't keep going down to sub-subdomains (e.g. www.secure.app.web.example.com)
                break
            }
        }
        
        // now see if we have a rule for the stripped domain...
        var ruleObj = rules.object(forKey: adjustedHostname) as? [String: AnyObject]
        if ruleObj != nil && !(ruleObj!["type"]?.isEqual(to: "hostname"))! {
            ruleObj = nil;
        }
        if (ruleObj != nil) {
            return ruleObj
        }
        
        // OR if not, for the stripped domain prefixed by any autoinclude subdomain
        for subdomain in AUTOINCLUDED_SUBDOMAINS {
            ruleObj = rules.object(forKey: "\(subdomain).\(adjustedHostname)") as? [String: AnyObject]
            
            // if we found a rule, we're done!
            if (ruleObj != nil) { break }
        }
        if (ruleObj != nil) {
            return ruleObj
        }
        
        // If we still didn't find a rule, finally try checking any regex rules
        // (anything starting/ending with slash is treated as a regex
        // TODO: add sugar to make *.example.com be treated as a regex
        NSLog("looking for regexes in all the wrong places for \(adjustedHostname)")
        for rule in (rules as! [String: [String: AnyObject]]) {
            if (rule.key.hasPrefix("/") && rule.key.hasSuffix("/")) {
                // power user! just use it as a regex and test it against the hostname
                
                // we have to remove the / prefix/suffix first
                let regexStart = rule.key.index(rule.key.startIndex, offsetBy: 1)
                let regexEnd = rule.key.index(rule.key.endIndex, offsetBy: -1)
                let regex = rule.key.substring(with: regexStart..<regexEnd)
                
                NSLog("Treating as a regex: \(regex)")
                if (hostname.range(of: regex, options: .regularExpression) != nil) {
                    NSLog("  --> MATCHED: \(rule.key) on \(hostname)")
                    ruleObj = rule.value;
                }
            } else if (rule.key.hasPrefix("*.")) {
                // wildcard subdomain block
                
                // first remove the *. prefix
                var regexRule = rule.key.substring(from: rule.key.index(rule.key.startIndex, offsetBy: 2))
                
                // next remove all other regex special characters
                // (they usually shouldn't be in hostnames anyway
                // TODO: escape them and leave them in the regex
                regexRule = SCUtils.stringWithoutRegexSpecialChars(regexRule)
                
                // and re-add the wildcard subdomain part properly
                // wildcards for us match the root domain also, because it's
                // what average-Jane user would normally expect (yes, I know it's
                // inconsistent with some other uses)
                regexRule = ".*\\.?\(regexRule)$";
                
                // finally, run it against hostname (make sure to make it work on the root domain also)
                 NSLog("Treating as a wildcard rule, regex: \(regexRule)")
                if (hostname.range(of: regexRule, options: .regularExpression) != nil) {
                    NSLog("  --> MATCHED: \(regexRule) on \(hostname)")
                    ruleObj = rule.value;
                }
            }
        }
        
        return ruleObj
    }

    open class func getAppRuleObj(_ sourceAppIdentifier: String) -> [String: AnyObject]? {
        let rules = (defaults?.object(forKey: "rules") as AnyObject)
        var ruleObj = rules.object(forKey: sourceAppIdentifier) as? [String: AnyObject]
        if ruleObj != nil && !(ruleObj!["type"]?.isEqual(to: "app"))! {
            ruleObj = nil;
        }
        
        return ruleObj
    }
    
	/// Get rule parameters for a flow from the SimpleTunnel user defaults.
	open class func getRule(_ flow: NEFilterFlow) -> (SCBlockRuleFilterAction, String, [String: AnyObject]) {
		let hostname = FilterUtilities.getFlowHostname(flow)
        let sourceAppId = FilterUtilities.getFlowSourceAppId(flow)
        let blockIdent = hostname.isEmpty ? sourceAppId : hostname;
        NSLog("Finding rule for hostname %@ from app %@", hostname, sourceAppId);
    
        let blockEndDate = defaults?.object(forKey: "blockEndDate") as? Date
        if (blockEndDate == nil || blockEndDate! < Date()) {
            // block is over or not started, so always return allow!
            // and clear any cruft left in the blockEndDate field
            if (blockEndDate != nil) {
                NSLog("*** Block is over! Removing object")
                defaults?.removeObject(forKey: "blockEndDate")
            } else { NSLog("Allow all, no block.") }
            return (.allow, blockIdent, [: ])
        }
        
        var blockRule: [String: AnyObject]? = nil;
        
        // check app-based rules first
        if (!sourceAppId.isEmpty) {
            blockRule = getAppRuleObj(sourceAppId);
        }
        
        // then try hostname-based rules
        if blockRule == nil {
            guard !hostname.isEmpty else { return (.allow, blockIdent, [:]) }
            
            blockRule = getHostnameRuleObj(hostname);
        }
        
        if blockRule == nil {
            NSLog("\(hostname) is set for NO RULES")
            return (.allow, blockIdent, [:]);
        }
		
		guard let ruleTypeInt = blockRule!["kRule"] as? Int,
			let ruleType = SCBlockRuleFilterAction(rawValue: ruleTypeInt)
			else { return (.allow, blockIdent, [:]) }

		return (ruleType, blockIdent, blockRule!)
	}

	/// Get the hostname from a browser flow.
	open class func getFlowHostname(_ flow: NEFilterFlow) -> String {
        // if it's got an HTTP URL, great! return the hostname from that
        if (flow.url != nil && flow.url!.host != nil) {
            return flow.url!.host!;
        }
        
        // otherwise we can try to grab it from an NEFilterSocketFlow's remoteEndpoint (unfortunately this is generally an IP address)
        guard let socketFlow:NEFilterSocketFlow = flow as? NEFilterSocketFlow,
            let hostEndpoint:NWHostEndpoint = socketFlow.remoteEndpoint as? NWHostEndpoint
            else { return "" }
        return hostEndpoint.hostname;
	}

    /// Get the source app ID from a filter flow.
    open class func getFlowSourceAppId(_ flow: NEFilterFlow) -> String {
        if flow.sourceAppIdentifier == nil {
            return "";
        }

        var bundleIdComponents = flow.sourceAppIdentifier!.components(separatedBy: ".");
        bundleIdComponents.removeFirst();
    
        return bundleIdComponents.joined(separator: ".");
    }

	/// Download a fresh set of rules from the rules server.
	open class func fetchRulesFromServer(_ serverAddress: String?) {
		NSLog("fetch rules called")

		guard serverAddress != nil else { return }
        NSLog("Fetching rules from \(String(describing: serverAddress))")

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
