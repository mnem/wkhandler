//
//  ViewController.swift
//  wkhandler
//
//  Created by David Wagner on 20/06/2018.
//  Copyright © 2018 David Wagner. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var wkv: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createWebView()
        goToInitialPage("mnem://google.com")
    }

    func goToInitialPage(_ page:String) {
        guard let url = URL(string: page) else {
            fatalError("Could not create URL object")
        }
        
        WKContentRuleListStore.default()?.compileContentRuleList(forIdentifier: "BlockAllTheThings", encodedContentRuleList: contentRules(), completionHandler: { (contentRulesList, error) in
            if let error = error {
                fatalError("Error creating content rules: \(String(describing: error))")
            }
            guard let contentRulesList = contentRulesList else {
                fatalError("Failed to get rules list")
            }
            self.wkv.configuration.userContentController.add(contentRulesList)
            self.wkv.load(URLRequest(url: url))
        })
    }
    
    func contentRules() -> String {
        return """
        [
          {
            "trigger" : {
              "url-filter": "http://.*"
            },
            "action": {
              "type": "block"
            }
          },
          {
            "trigger" : {
              "url-filter": "https://.*"
            },
            "action": {
              "type": "block"
            }
          }
        ]
        """
    }
    
    func createWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(MnemCustomScheme(), forURLScheme: MnemCustomScheme.urlScheme)
        wkv = WKWebView(frame: .zero, configuration: configuration)
        view.addSubview(wkv)
        
        wkv.translatesAutoresizingMaskIntoConstraints = false
        let views = ["wkv": wkv]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[wkv]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views as [String : Any])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[wkv]-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views as [String : Any])
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    

}

