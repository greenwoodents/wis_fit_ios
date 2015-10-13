//
//  NetworkManager.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 13.10.2015.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let sharedInstace = NetworkManager()
    
    let defaultManager: Alamofire.Manager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "wis.fit.vutbr.cz": .PinCertificates(
                certificates: ServerTrustPolicy.certificatesInBundle(),
                validateCertificateChain: true,
                validateHost: true
            )]
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        return Alamofire.Manager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        }()
}