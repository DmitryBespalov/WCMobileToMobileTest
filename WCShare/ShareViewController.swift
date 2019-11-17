//
//  ShareViewController.swift
//  WCShare
//
//  Created by Dmitry Bespalov on 17.11.19.
//  Copyright © 2019 Dmitry Bespalov. All rights reserved.
//

import UIKit
import Foundation
import Starscream
import LocalAuthentication

class ShareViewController: UIViewController {

    var socket: WebSocket!
    var context: LAContext!

    @IBAction func sendRequest(_ sender: Any) {

    }

    func faceID() {
        context = LAContext()
        context.localizedCancelTitle = "Enter thing"
        var canError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &canError) {
            let reason = "Log in"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    print("Auth success!")
                } else {
                    print(error?.localizedDescription ?? "can't auth")
                }
            }
        } else {
            print(canError?.localizedDescription ?? "can't eval")
        }
    }

    func websocket() {
        guard let ctx = extensionContext, let item = ctx.inputItems.first as? NSExtensionItem,
            let attachment = item.attachments?.first else { return }
        attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { [unowned self] (data, error) in
            if let error = error {
                print(error)
                return
            }
            guard let url = data as? URL else {
                print("can't convert to url")
                return
            }
            self.connect(to: url)
        }
    }

    func connect(to url: URL) {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let bridgeURLString = comps?.queryItems?.first(where: { $0.name == "bridge" })?.value,
            let bridgeURL = URL(string: bridgeURLString) else { return }
        print(bridgeURL)

        socket = WebSocket(url: bridgeURL)

        //websocketDidConnect
        socket.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(error?.localizedDescription ?? "<error>")")
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
        }
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
        }
        //you could do onPong as well.
        socket.connect()
    }

}
