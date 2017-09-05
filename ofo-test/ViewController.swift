//
//  ViewController.swift
//  ofo-test
//
//  Created by zheng zhang on 2017/9/4.
//  Copyright © 2017年 auction. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {

    var mapView: MAMapView!;
    var search: AMapSearchAPI!;
    
    @IBOutlet weak var meniView: UIView!
    
    //MARK: - 搜索相关
    //搜索周边小黄车
    func searchNearBike() {
        self.searchNearBikeWithCenter(_center: mapView.userLocation.coordinate);
    }
    
    //根据经纬度搜索小黄车
    func searchNearBikeWithCenter(_center: CLLocationCoordinate2D) {
        let request = AMapPOIAroundSearchRequest();
        request.location = AMapGeoPoint.location(withLatitude: CGFloat(_center.latitude), longitude: CGFloat(_center.longitude));
        request.keywords = "餐馆";
        request.radius = 500;
        request.requireExtension = true;
        self.search.aMapPOIAroundSearch(request);
    }
    
    //MARK: - AMapSearchDelegate
    //搜索完成
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        guard response.count > 0 else {
            print("无黄车");
            return;
        }
        
        var centerArr : [MAPointAnnotation] = [];
        
        centerArr = response.pois.map{
            let point = MAPointAnnotation();
            
            point.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees($0.location.latitude), longitude: CLLocationDegrees($0.location.longitude));
            if $0.distance < 200
            {
                point.title = "红包区域内开锁任意小黄车";
                point.subtitle = "骑行10分钟可获得现金红包";
            }
            else
            {
                point.title = "正常可用";
            }
            return point;
        }
        //添加并展示
        mapView.addAnnotations(centerArr);
        mapView.showAnnotations(centerArr, animated: true);
    }
    
    //MARK: - MAMapViewDelegate
    
    //用户移动地图，搜索周边
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction == true
        {
            self.searchNearBikeWithCenter(_center: mapView.centerCoordinate);
        }
    }
    
    /// 自定义大头针
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation is MAUserLocation
        {
            //用户大头针不需要自定义
            return nil;
        }
        
        let reuseid = "myID";
        var annoationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseid) as? MAPinAnnotationView;
        if annoationView == nil
        {
            annoationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid);
        }
        if annotation.title == "正常可用"
        {
            annoationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBike");
        }
        else
        
        {
            annoationView?.image = #imageLiteral(resourceName: "HomePage_nearbyBikeRedPacket");
        }
        annoationView?.canShowCallout = true;
        annoationView?.animatesDrop = true;
        return annoationView;
    }
    
    //地图初始化
    func mapInitComplete(_ mapView: MAMapView!) {
        
    }
    
    
    //MARK: - SystemMethod
    //用户点击定位
    @IBAction func locationClick(_ sender: UIButton!) {
        self.searchNearBike();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //地图初始化
        mapView = MAMapView(frame: self.view.bounds);
        mapView.delegate = self;
        mapView.showsUserLocation = true;
        mapView.userTrackingMode = .follow;
        mapView.zoomLevel = 17;
        self.view.addSubview(mapView);
        
        self.view.bringSubview(toFront: self.meniView);
        
        search = AMapSearchAPI();
        search.delegate = self;
        
        //定制导航
        self.navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "user_center_icon").withRenderingMode(.alwaysOriginal);
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "blue_bar_message_icon").withRenderingMode(.alwaysOriginal);
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "Login_Logo"));
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        
        if let reveaVC = revealViewController() {
            reveaVC.rearViewRevealWidth = 280;
            navigationItem.leftBarButtonItem?.target = reveaVC;
            navigationItem.leftBarButtonItem?.action = #selector(SWRevealViewController.revealToggle(_:));
            view.addGestureRecognizer(reveaVC.panGestureRecognizer());
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

