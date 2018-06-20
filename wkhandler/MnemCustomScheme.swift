//
//  MyCustomScheme.swift
//  wkhandler
//
//  Created by David Wagner on 20/06/2018.
//  Copyright © 2018 David Wagner. All rights reserved.
//

import Foundation
import WebKit

@objc
class MnemCustomScheme: NSObject, WKURLSchemeHandler {
    static let urlScheme = "mnem"
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Start \(String(describing: urlSchemeTask.request.url?.absoluteString))")
        let session = URLSession.shared
        var request = urlSchemeTask.request
        guard let requestURLString = request.url?.absoluteString else {
            print("Could not get string for URL")
            return
        }
        request.url = URL(string: requestURLString.replacingOccurrences(of: "mnem://", with: "https://"))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Data task failed with error: \(String(describing: error))")
                urlSchemeTask.didFailWithError(error)
                return
            }
            guard let data = data else {
                print("Data task failed to get data")
                let error = NSError(domain: "app", code: 1, userInfo: nil)
                urlSchemeTask.didFailWithError(error)
                return
            }
            guard let response = response else {
                print("Data task failed to get response")
                let error = NSError(domain: "app", code: 2, userInfo: nil)
                urlSchemeTask.didFailWithError(error)
                return
            }
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
            print("Completed \(String(describing: urlSchemeTask.request.url?.absoluteString))")
        }
        print("Starting data task")
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("Stop \(String(describing: urlSchemeTask.request.url?.absoluteString))")
    }
    
}
