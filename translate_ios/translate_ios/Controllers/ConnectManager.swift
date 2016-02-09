//
//  ConnectManager.swift
//  translate_ios
//
//  Created by Thuy Duong on 01/11/15.
//  Copyright © 2015 PiscesTeam. All rights reserved.
//

import Foundation

class ConnectionManager: NSObject {
    static var translateServer: TranslationServiceClient!

    static func openConnect() {
        let transport = TSocketClient(hostname: serverHost, port: serverPort)
        let proto = TBinaryProtocol(transport: transport, strictRead: true, strictWrite: true)
        translateServer = TranslationServiceClient(withProtocol: proto)
    }
}