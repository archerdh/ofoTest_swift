//
//  OFOOpenBikeViewController.swift
//  ofo-test
//
//  Created by zheng zhang on 2017/9/5.
//  Copyright © 2017年 auction. All rights reserved.
//

import UIKit
import swiftScan
import FTIndicator

class OFOOpenBikeViewController: LBXScanViewController {

    var isOpen = false;
    
    @IBOutlet var menuView: UIView!
    
    // MARK: - systemMethod

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "扫码用车";
        
        //定制扫描样式
        var style = LBXScanViewStyle();
        style.anmiationStyle = .NetGrid;
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_full_net");
        scanStyle = style;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.view.bringSubview(toFront: self.menuView);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.navigationBar.barStyle = .default;
        self.navigationController?.navigationBar.tintColor = UIColor.black;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.barStyle = .blackOpaque;
        self.navigationController?.navigationBar.tintColor = UIColor.white;
    }

    // MARK: - Action
    @IBAction func CamerClick(_ sender: Any) {
        self.isOpen = !self.isOpen;
        scanObj?.changeTorch();
        if self.isOpen {
            
        }
        else
        {
            
        }
    }
    
    // MARK: - 二维码结果处理
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        if let result = arrayResult.first {
            let reStr = result.strScanned;
            
            FTIndicator.setIndicatorStyle(.dark);
            FTIndicator.showToastMessage(reStr);
        }
    }

}
