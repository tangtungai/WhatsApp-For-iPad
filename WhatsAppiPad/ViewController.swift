//
//  ViewController.swift
//
//  Created by Tung Ai Tang on 01/06/2020.
//  Copyright © 2020 Tung Ai Tang. All rights reserved.
//

import UIKit
import WebKit
import UserNotifications
import CoreLocation


private var thisViewController: ViewController? 


class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler,WKNavigationDelegate, CLLocationManagerDelegate, UIScrollViewDelegate {
    
    var locationManager: CLLocationManager?
    
    static var instance: ViewController {
        guard let thisViewController = thisViewController else { fatalError() } 
        return thisViewController
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if (message.name == "openDocument") {
            //future usage
        }
        else if (message.name == "jsError") {
            //future usage
        }
        else
        {
            var messageSender = "";
            var messageBody = "";
            
            var messageData = message.body as! String
            if let index = messageData.firstIndex(of: "|") {
                messageSender = String(messageData[..<index])
                let indexNext = messageData.index(after: index)
                messageBody = String(messageData[indexNext...])
            }
            
            let content = UNMutableNotificationContent()
            content.title = messageSender//"WhatsApp Message"
            content.body = messageBody//message.body as! String
            
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    NSLog(error.debugDescription)
                }
            }
        }
    }
    
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if ((url?.absoluteString.hasPrefix("https://web.whatsapp.com")) != false)
        {
            decisionHandler(.allow)
        }
        else if ((url?.absoluteString.hasPrefix("blob:")) != false)
        {
            decisionHandler(.allow)
        }
        else
        {
            decisionHandler(.cancel)
            UIApplication.shared.openURL(url!)
        }
	}
    
    
    var webView: WKWebView!
    var backButton: UIButton!
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // you're good to go!
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            reloadData()
        }
    }
    
    func reloadData()
    {
        webView.evaluateJavaScript("1+1", completionHandler: nil)
    }
    
   
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
       scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    override func loadView() {
        
        let userScriptURL = Bundle.main.url(forResource: "UserScript", withExtension: "js")!
        let userScriptCode = try! String(contentsOf: userScriptURL)
        let userScript = WKUserScript(source: userScriptCode, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        let webConfiguration = WKWebViewConfiguration()
        
        webConfiguration.userContentController.addUserScript(userScript)
        webConfiguration.userContentController.add(self, name: "notify")
        
        //For Content Blocker
        let blockRules = """
           [
               {
                   "trigger": {
                       "url-filter": ".*img/qr-video-.*",
                       "resource-type": ["image"]
                   },
                   "action": {
                       "type": "block"
                   }
               }
           ]
        """
        
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "ContentBlockingRules",
            encodedContentRuleList: blockRules) { (contentRuleList, error) in

                if let error = error {
                    return
                }
                webConfiguration.userContentController.add(contentRuleList!)
        }
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringVisits()
        locationManager?.startMonitoringSignificantLocationChanges()
        
        let myURL = URL(string:"https://web.whatsapp.com")
        var myRequest = URLRequest(url: myURL!)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15"
        
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        webView.scrollView.bounces = false
        webView.allowsBackForwardNavigationGestures = true
        webView.load(myRequest)
    }}


