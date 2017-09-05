//
//  MessageWebViewController.swift
//  ofo-test
//
//  Created by zheng zhang on 2017/9/4.
//  Copyright © 2017年 auction. All rights reserved.
//

import UIKit
import WebKit

class MessageWebViewController: UIViewController {
    
    var webView:WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView = WKWebView(frame: self.view.bounds);
        self.view.addSubview(webView);
        
        self.title = "热门活动";
        webView.load(URLRequest(url: URL(string: "http://m.ofo.so/active.html")!));
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
