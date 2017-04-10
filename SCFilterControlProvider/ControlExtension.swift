/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	This file contains the ControlExtension class. The ControlExtension class is a sub-class of NEFilterControlProvider, and is responsible for downloading content filter rules from a web service.
*/

import NetworkExtension
import Foundation

/// A NEFitlerControlProvider sub-class that implements logic for downloading rules from a web server.
class ControlExtension : NEFilterControlProvider {

	// MARK: Properties

	/// An integer to use as the context for key-value observing.
	var observerContext = 0

	// MARK: Interface

	/// Update the filter based on changes to the configuration
	func updateFromConfiguration() {
		guard let serverAddress = filterConfiguration.serverAddress else { return }

//		FilterUtilities.fetchRulesFromServer(filterConfiguration.serverAddress)

		let remediationURL = "https://\(serverAddress)/remediate/?url=\(NEFilterProviderRemediationURLFlowURLHostname)&organization=\(NEFilterProviderRemediationURLOrganization)&username=\(NEFilterProviderRemediationURLUsername)"

		NSLog("Remediation url is \(remediationURL)")

		remediationMap =
			[
				NEFilterProviderRemediationMapRemediationURLs : [ "Remediate1" : remediationURL as NSObject ],
				NEFilterProviderRemediationMapRemediationButtonTexts :
					[
						"RemediateButton1" : "Request Access" as NSObject,
						"RemediateButton2" : "\"<script>alert('wooo hoooooo');</script>" as NSObject,
						"RemediateButton3" : "Request Access 3" as NSObject,
				]
			]

		self.urlAppendStringMap = [ "SafeYes" : "safe=yes", "Adult" : "adult=yes"]

		NSLog("Remediation map set")
	}

	// MARK: Initializers

	override init() {
         NSLog("Init filter control provider!");
        
		super.init()
		updateFromConfiguration()

//		FilterUtilities.fetchRulesFromServer(self.filterConfiguration.serverAddress)

		self.addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
	}

	// MARK: NSObject

	/// Observe changes to the configuration.
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "filterConfiguration" && context == &observerContext {
			NSLog("configuration changed")
			updateFromConfiguration()
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}

	// MARK: NEFilterControlProvider

	/// Handle a new flow of network data
	override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
		NSLog("Handle new flow called")
		var controlVerdict = NEFilterControlVerdict.updateRules()
		let (ruleType, hostname, _) = FilterUtilities.getRule(flow)

		switch ruleType {
			case .needMoreRulesAndAllow:
				NSLog("\(hostname) is set to be Allowed")
				controlVerdict = NEFilterControlVerdict.allow(withUpdateRules: false)

			case .needMoreRulesAndBlock:
				NSLog("\(hostname) is set to be blocked")
				controlVerdict = NEFilterControlVerdict.drop(withUpdateRules: false)
			
			default:
				NSLog("\(hostname) is not set for need more rules")
		}

		completionHandler(controlVerdict)
	}
}
