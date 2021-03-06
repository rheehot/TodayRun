//
//  recomendCourseImnfoVC.swift
//  TodayRunning
//
//  Created by 김재석 on 22/09/2019.
//  Copyright © 2019 김재석. All rights reserved.
//

import Foundation
import UIKit
import NMapsMap
import SDWebImage

class recomendCourseInfoVC: UIViewController, UINavigationBarDelegate,UIScrollViewDelegate, NMFMapViewDelegate {
    
    @IBOutlet weak var recomendImg: UIImageView!
    
    @IBOutlet weak var recomendSpotTitle: UILabel!
    @IBOutlet weak var recomendSpotInfo: UILabel!
    
    @IBOutlet weak var recomendSpotExplanation: UITextView!
    
    @IBOutlet weak var recomendSpotMapView: UIView!
    
    var recomendSpotAutoID : String? //note: 유저가 작성한 추천스팟을 선택하면 전달 받는 AutoID이다.
    var recomendOpenAPIIndex : Int?
    
    
    var cameraLat = 37.5666102
    var cameraLng = 126.9783881
    var NaverMapView : NMFNaverMapView?//note: 이걸 이렇게 프로퍼티로 만든 이유를 생각하자( 탑하였을 때 실행되는 didTap 메소드에서 마커를 찍을 네이버 지도 맵뷰에 접근하도록 하기 위해서 프로퍼티로 만들어 주고 클래스 내부 메소드에서 자유롭게 접근할 수 있도록 해주느 것이다. )
    var Marker = NMFMarker() //note: 이걸 이렇게 프로퍼티로 만든 이유를 생각하자( didTap 메소드 안에다 마커 객체를 만들어 놓으면 지도를 탭 할 때 마다 매번 새로운 마커가 만들어져서 지도에 탭한 만큼의 마커가 찍히게 된다 그래서 지도에 찍히는 마커의 갯수를 제한하기 위해서 이렇게 프로퍼티 빼고 탭을 할 때 마다 해당 마커의 mapView에 값이 nil인지 아닌지를 확인해 nil이면 기존 마커를 없애서 새로운 마커가 찍히게 해주는 것이다 .)
    
    var viewAppearCheckApiOrPeopleTo : Bool? //note: 상단 배너에 OpneAPI 정보를 받아와선 만들어짓 추천 스팟을 선택했느가 아니면 유저가 만든 추천스팟을 선택했는가를 확인하는 용도이다.
    
    var pageControlCurrentPage : Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        if self.viewAppearCheckApiOrPeopleTo!{//note: 추천스팟 셀을 선택한 경우
            initView()
            addMapView() // 일단 기본 중심 지역으로 지도 카메라를 옮기고 시작하자(테스터 용!!)
        }
        else{ // note: 상단 배너에 위치한 추천스팟 이미지 뷰를 선택한 경우
           initViewForOpenAPI()
           addMapViewOfOpenApi()
            
        }
    }
    
    func initViewForOpenAPI(){
            var appDelegate = UIApplication.shared.delegate as! AppDelegate
                   
            self.recomendSpotExplanation.isEditable = false
            self.navigationItem.title = "추천스팟 정보"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonPress(_:)))
        
        self.recomendImg.sd_setImage(with: URL(string: appDelegate.ReloadRTDB.OpenAPIDataInfoForRecomendArr[self.pageControlCurrentPage!]["p_img"] as! String), completed: nil)
                   
            self.recomendSpotTitle.text = appDelegate.ReloadRTDB.OpenAPIDataInfoForRecomendArr[self.pageControlCurrentPage!]["p_park"] as! String
        
            self.recomendSpotInfo.text = appDelegate.ReloadRTDB.OpenAPIDataInfoForRecomendArr[self.pageControlCurrentPage!]["p_addr"] as! String
            self.recomendSpotExplanation.text = appDelegate.ReloadRTDB.OpenAPIDataInfoForRecomendArr[self.pageControlCurrentPage!]["p_list_content"] as! String
        
    }
    //  check: 공공 데이터 포털에서 받아온 좌표에 대한 문제점을 해결하자!!! 도대체 어디서 잘못된걸까???
    func  addMapViewOfOpenApi(){//note: 공공데이터 포털에서 가져온 위도, 경도를 이용해서 지도에 띄우기
        
        var appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var lng = (appDelegate.ReloadRTDB.OpenAPIDataInfoForRecomendArr[self.pageControlCurrentPage!]["longitude"] as! NSString).doubleValue//note: 공공 데이터 포털에서 받아온 x좌표를 해당 변수에 저장
        
        var lat = (appDelegate.ReloadRTDB.OpenAPIDataInfoForRecomendArr[self.pageControlCurrentPage!]["latitude"] as! NSString).doubleValue // note: 공공 데이터 포털에서 받아온 y좌표를 저장
        
//        var tm = NMGTm128(x: lng, y: lat)// x, y 좌표를 utm_k 좌표계로 변환
//        var latlng = tm.toLatLng() // utm_k 좌표계를 네이버 지도에서 사용할 수 있는 좌표계롤 변환
//        var utm = NMGUtmk(x: 969828.309 , y:  1944736.4575  )// x, y 좌표를 utm_k 좌표계로 변환
//               var latlng = utm.toLatLng() // utm_k 좌표계를 네이버 지도에서 사용할 수 있는 좌표계롤 변환

//        var utm = NMGUtmk(x: lat, y: lng )// x, y 좌표를 utm_k 좌표계로 변환
//        var latlng = utm.toLatLng() // utm_k 좌표계를 네이버 지도에서 사용할 수 있는 좌표계롤 변환
//백 이시만
                
    var latlng = NMGLatLng(lat: lat, lng: lng)
        
        self.NaverMapView = NMFNaverMapView(frame: CGRect(x: 0, y: 0, width: self.recomendSpotMapView.frame.width, height: self.recomendSpotMapView.frame.height))
        self.NaverMapView!.delegate = self
        var DEFAULT_CAMERA_POSITION = NMFCameraPosition(latlng, zoom: 14, tilt: 0, heading: 0)
//        var DEFAULT_CAMERA_POSITION = NMFCameraPosition(NMGLatLng(lat: 23.764851101352427 , lng: 119.67097857829495  ), zoom: 14, tilt: 0, heading: 0)
        self.NaverMapView!.mapView.moveCamera(NMFCameraUpdate(position: DEFAULT_CAMERA_POSITION))
        self.recomendSpotMapView.addSubview(self.NaverMapView!)
        print("공공데이터 포텅에서 가져온 x 값:\(lng), y 값: \(lat)")
        
        
        print("공공데이터 포텅에서 가져온 x 값:\(latlng.lng), y 값: \(latlng.lat)")
               
        
        
        
    }
    
    func addMapView(){ // note 원래 뷰의 속한 가장 첫번재 서브뷰를 삭제하고 새로운 뷰룰 서브뷰로 등록하고
        //화면에 띄우는 방법
        //        var view =  self.recomendMapView.subviews[0]//note: 원래 뷰의 서브 뷰를 변수에 할당한다.
        self.NaverMapView = NMFNaverMapView(frame: CGRect(x: 0, y: 0, width: self.recomendSpotMapView.frame.width, height: self.recomendSpotMapView.frame.height))
        self.NaverMapView!.delegate = self
        var DEFAULT_CAMERA_POSITION = NMFCameraPosition(NMGLatLng(lat: self.cameraLat , lng: self.cameraLng ), zoom: 14, tilt: 0, heading: 0)
        self.NaverMapView!.mapView.moveCamera(NMFCameraUpdate(position: DEFAULT_CAMERA_POSITION))
        self.recomendSpotMapView.addSubview(self.NaverMapView!)
        
        //note : 초기화면 설정
        
    }
    
    func initView(){
            var appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.recomendSpotExplanation.isEditable = false
        self.navigationItem.title = "추천스팟 정보"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonPress(_:)))
        
        self.recomendSpotTitle.text = appDelegate.ReloadRTDB.recomendSpotMadeUserDic!["title"] as! String
        self.recomendSpotInfo.text = appDelegate.ReloadRTDB.recomendSpotMadeUserDic!["address"] as! String
        self.recomendSpotExplanation.text = appDelegate.ReloadRTDB.recomendSpotMadeUserDic!["reson"] as! String
        self.cameraLat = appDelegate.ReloadRTDB.recomendSpotMadeUserDic!["spotLat"] as! Double
        self.cameraLng = appDelegate.ReloadRTDB.recomendSpotMadeUserDic!["spotLng"] as! Double
        
    }
    
    @objc func backButtonPress(_ sender : Any){
        
         self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
}
