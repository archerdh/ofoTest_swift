//
//  ViewController.swift
//  ofo-test
//
//  Created by zheng zhang on 2017/9/4.
//  Copyright © 2017年 auction. All rights reserved.
//

import UIKit
import FTIndicator
import SWRevealViewController

class ViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, AMapNaviWalkManagerDelegate {
    var mapView: MAMapView!;
    var search: AMapSearchAPI!;
    var point : PointAnnotation!;
    var pointView : MAAnnotationView!;
    var starPoint : CLLocationCoordinate2D!;
    var endpoint : CLLocationCoordinate2D!;
    var nearBySearch = true;
    var warkManager : AMapNaviWalkManager!;
    
    @IBOutlet weak var meniView: UIView!
    
    //MARK: - 中心大头针动画
    func pointViewAnimation() {
        //记录oldframe
        let oldFrame = self.pointView.frame;
        self.pointView.frame = oldFrame.offsetBy(dx: 0, dy: -20);
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: [], animations: {
            self.pointView.frame = oldFrame;
        }, completion: nil)
    }

    
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
        self.mapView.addAnnotations(centerArr);
        if nearBySearch
        {
            self.mapView.showAnnotations(centerArr, animated: true);
            self.nearBySearch = false;
        }
    }
    
    //MARK: - AMapNaviWalkManagerDelegate
    //计算距离
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        
        //清除掉之前计算的线
        self.mapView.removeOverlays(self.mapView.overlays);
        
        var coordinates = warkManager.naviRoute!.routeCoordinates!.map{
            return CLLocationCoordinate2D(latitude: CLLocationDegrees($0.latitude), longitude: CLLocationDegrees($0.longitude));
        };
        let polyLine : MAPolyline = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count));
        self.mapView.add(polyLine);
        
        //提示距离和时间
        let walkMinute = walkManager.naviRoute!.routeTime / 60;
        let timeDesc = walkMinute > 0 ? walkMinute.description + "分钟" : "1分钟以内";
        let hintTitle = "步行" + timeDesc;
        
        let walkLeagth = walkManager.naviRoute?.routeLength;
        let hintSubTitle = "距离" + (walkLeagth?.description)! + "米";
        
        FTIndicator.setIndicatorStyle(.dark);
        FTIndicator.showNotification(with: #imageLiteral(resourceName: "clock"), title: hintTitle, message: hintSubTitle);
    }

    //MARK: - MAMapViewDelegate
    //地图画线
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline
        {
            self.point.isLockedToScreen = true;
            
            //绘制线，地图缩放至线显示区域
            self.mapView.visibleMapRect = overlay.boundingMapRect;
            
            let renderer = MAPolylineRenderer(overlay: overlay);
            renderer?.lineWidth = 8.0;
            renderer?.strokeColor = UIColor.blue;
            return renderer;
        }
        return nil;
    }
    
    //用户移动地图，搜索周边
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction == true
        {
            self.point.isLockedToScreen = true;
            self.pointViewAnimation();
            self.searchNearBikeWithCenter(_center: mapView.centerCoordinate);
        }
    }
    
    //定制小黄车大头针动画
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        let annoationArr = views as! [MAAnnotationView];
        for view in annoationArr {
            guard view.annotation is MAAnnotationView else {
                continue;
            }
            
            view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1);
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: { 
                view.transform = .identity;
            }, completion: nil);
        }
    }
    
    /// 自定义大头针
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation is MAUserLocation
        {
            //用户大头针不需要自定义
            return nil;
        }
        
        if annotation is PointAnnotation
        {
            //中心点大头针
            let centerReuseid = "centerID";
            var centerAnnoationView = mapView.dequeueReusableAnnotationView(withIdentifier: centerReuseid);
            if centerAnnoationView == nil
            {
                centerAnnoationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: centerReuseid);
            }
            centerAnnoationView?.image = #imageLiteral(resourceName: "homePage_wholeAnchor");
            centerAnnoationView?.canShowCallout = false;
            //保存property
            self.pointView = centerAnnoationView;
            return centerAnnoationView;
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
    
    //点击大头针
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        self.starPoint = self.point.coordinate;
        self.endpoint = view.annotation.coordinate;
        
        let starPoint = AMapNaviPoint.location(withLatitude: CGFloat(self.starPoint.latitude), longitude: CGFloat(self.starPoint.longitude))!;
        let endPoint = AMapNaviPoint.location(withLatitude: CGFloat(self.endpoint.latitude), longitude: CGFloat(self.endpoint.longitude))!;
        self.warkManager.calculateWalkRoute(withStart: [starPoint], end: [endPoint]);
    }
    
    //地图初始化
    func mapInitComplete(_ mapView: MAMapView!) {
        self.point = PointAnnotation();
        self.point.coordinate = mapView.centerCoordinate;
        self.point.lockedScreenPoint = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2);
        self.point.isLockedToScreen = true;
        
        self.mapView.addAnnotation(self.point);
        self.mapView.showAnnotations([self.point], animated: true);
        self.searchNearBike();
        
        self.warkManager = AMapNaviWalkManager();
        self.warkManager.delegate = self;
    }
    
    
    //MARK: - SystemMethod
    //用户点击定位
    @IBAction func locationClick(_ sender: UIButton!) {
        nearBySearch = true;
        self.searchNearBike();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //地图初始化
        self.mapView = MAMapView(frame: self.view.bounds);
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = true;
        self.mapView.userTrackingMode = .follow;
        self.mapView.zoomLevel = 17;
        self.view.addSubview(mapView);
        
        self.view.bringSubview(toFront: self.meniView);
        
        self.search = AMapSearchAPI();
        self.search.delegate = self;
        
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

