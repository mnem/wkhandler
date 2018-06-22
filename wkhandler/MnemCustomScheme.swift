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
    static let scheme = "mnem"
    
    var tasks = [URLSessionDataTask : WKURLSchemeTask]()
    var session: URLSession!
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Start \(String(describing: urlSchemeTask.request.url?.absoluteString))")
        var request = urlSchemeTask.request
        guard let requestURLString = request.url?.absoluteString else {
            print("Could not get string for URL")
            return
        }
        request.url = URL(string: requestURLString.replacingOccurrences(of: "mnem://", with: "https://"))
        
        let task = session.dataTask(with: request)
        tasks[task] = urlSchemeTask;

        print("Starting data task")
        task.resume()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("Stop \(String(describing: urlSchemeTask.request.url?.absoluteString))")
    }
    
}

extension MnemCustomScheme: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let dataTask = task as? URLSessionDataTask, let wkTask = tasks[dataTask] else {
            print("ERROR: Could not find WK Task")
            return
        }
        if let error = error {
            wkTask.didFailWithError(error)
        } else {
            wkTask.didFinish()
        }
        
        tasks.removeValue(forKey: dataTask)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let wkTask = tasks[dataTask] else {
            print("ERROR: Could not find WK Task")
            completionHandler(.cancel)
            return
        }
        wkTask.didReceive(response)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let wkTask = tasks[dataTask] else {
            print("ERROR: Could not find WK Task")
            return
        }
        wkTask.didReceive(data)
    }
    
}
