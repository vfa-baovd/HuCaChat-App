//
//  BottomMenuView.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/6/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import Foundation

protocol BottomMenuViewDelegate: class {
    func didSelectedBtnHome(_: BottomMenuView!)
    func didSelectedBtnCalendar(_: BottomMenuView!)
    func didSelectedBtnCenter(_: BottomMenuView!)
    func didSelectedBtnAlarm(_: BottomMenuView!)
    func didSelectedBtnSetting(_: BottomMenuView!)
    func didSelectedBtnContact(_: BottomMenuView!)
    func didSelectedBtnVideo(_: BottomMenuView!)
    func didSelectedBtnCamera(_: BottomMenuView!)
    func didSelectedBtnCheckIn(_: BottomMenuView!)
    func didSelectedBtnCheckOut(_: BottomMenuView!)
}

let kHeightCenterButtonRatio = CGFloat(0.18)

class BottomMenuView: UIView {
    var itemsArr = [UIView]()
    var highlightViewArr = [UIView]()
    
    var currentIndex:Int = 0 {
        didSet {
            var index = 0
            for view in highlightViewArr {
                view.isHidden = (index != currentIndex)
                index += 1
            }
        }
    }
    
    weak var delegate: BottomMenuViewDelegate?
    lazy var viewBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        return view
    }()
    
    lazy var btnHome: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnHome(btn:)), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "tabbar_chat_off"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "tabbar_chat_on"), for: .selected)
        
        return btn
    }()
    
    lazy var btnCalendar: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnCalendar(btn:)), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "tabbar_group_off"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "tabbar_group_on"), for: .selected)
        
        return btn
    }()
    
    lazy var btnCenter: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnCenter(btn:)), for: .touchUpInside)
        let image = UIView.filledImage(from: #imageLiteral(resourceName: "icon_center"), with: Theme.shared.color_Dark_App())
        
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .highlighted)
        
        return btn
    }()
    
    lazy var btnAlart: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnAlart(btn:)), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "tabbar_notification_off"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "tabbar_notification_on"), for: .selected)
        
        return btn
    }()
    
    lazy var btnSetting: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnSetting(btn:)), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "tabbar_more_off"), for: .normal)
        btn.setImage(#imageLiteral(resourceName: "tabbar_more_on"), for: .selected)
        
        return btn
    }()
    
    //MARK:- Sub button from center button
    lazy var viewBlueBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        return view
    }()
    
    lazy var imgViewEclipseBackground: UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "eclipse_bg"))
        
        return img
    }()
    
    lazy var btnContact: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedbtnContact(btn:)), for: .touchUpInside)
        let image = UIView.filledImage(from: #imageLiteral(resourceName: "icon_text"), with: Theme.shared.color_Dark_App())
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .highlighted)
        
        return btn
    }()
    
    lazy var btnVideo: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnVideo(btn:)), for: .touchUpInside)
        let image = UIView.filledImage(from: #imageLiteral(resourceName: "icon_text"), with: Theme.shared.color_Dark_App())
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .highlighted)
        
        return btn
    }()
    
    lazy var btnCamera: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnCamera(btn:)), for: .touchUpInside)
        let image = UIView.filledImage(from: #imageLiteral(resourceName: "icon_text"), with: Theme.shared.color_Dark_App())
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .highlighted)
        
        return btn
    }()
    
    lazy var btnCheckIn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnCheckIn(btn:)), for: .touchUpInside)
        let image = UIView.filledImage(from: #imageLiteral(resourceName: "icon_text"), with: Theme.shared.color_Dark_App())
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .highlighted)
        
        return btn
    }()
    
    lazy var btnCheckOut: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.tappedBtnCheckOut(btn:)), for: .touchUpInside)
        let image = UIView.filledImage(from: #imageLiteral(resourceName: "icon_text"), with: Theme.shared.color_Dark_App())
        btn.setImage(image, for: .normal)
        btn.setImage(image, for: .highlighted)
        
        return btn
    }()
    
    lazy var imgViewLogo: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "icon_logo"))
        imgV.layer.cornerRadius = 30
        imgV.layer.borderWidth = 1.0
        imgV.layer.borderColor = UIColor.white.cgColor
        imgV.clipsToBounds = true
        
        return imgV
    }()
    
    lazy var imgViewIconText: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "iContact"))
        
        return imgV
    }()
    
    lazy var imgViewIconVideo: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "iMaker"))
        
        return imgV
    }()
    
    lazy var imgViewIconCamera: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "iMusic"))
        
        return imgV
    }()
    
    lazy var imgViewIconCheckIn: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "iMove"))
        
        return imgV
    }()
    
    lazy var imgViewIconCheckOut: UIImageView = {
        let imgV = UIImageView(image: #imageLiteral(resourceName: "iCalendar"))
        
        return imgV
    }()
    
    //MARK:- Gesture
    var isShowSubButton: Bool = false
    var gesture: UITapGestureRecognizer!
    
    func clearSelectButton() {
        btnHome.isSelected = false
        btnCalendar.isSelected = false
        btnAlart.isSelected = false
        btnSetting.isSelected = false
    }
    
    //MARK:- Handle event
    func tappedBtnHome(btn: UIButton) {
//        let url = URL(string: "http://static.new.tuoitre.vn/tto/i/s626/2017/06/01/nguyen-xuan-phuc-jpg-1496283435.jpg")
//        let str = url!.lastPathComponent
//        print(str)
        self.delegate?.didSelectedBtnHome(self)
    }
    
    func tappedBtnCalendar(btn: UIButton) {
        self.delegate?.didSelectedBtnCalendar(self)
    }
    
    func tappedBtnCenter(btn: UIButton) {
        if isShowSubButton {
            tappedScreen()
            return
        }
        isShowSubButton = true
        showSubButtons()
        gesture.isEnabled = true
        self.delegate?.didSelectedBtnCenter(self)
    }
    
    func tappedBtnAlart(btn: UIButton) {
        self.delegate?.didSelectedBtnAlarm(self)
    }
    
    func tappedBtnSetting(btn: UIButton) {
        self.delegate?.didSelectedBtnSetting(self)
    }
    
    func tappedbtnContact(btn: UIButton) {
        self.delegate?.didSelectedBtnContact(self)
        if isShowSubButton {
            tappedScreen()
            return
        }
    }
    
    func tappedBtnVideo(btn: UIButton) {
        self.delegate?.didSelectedBtnVideo(self)
        if isShowSubButton {
            tappedScreen()
            return
        }
    }
    
    func tappedBtnCamera(btn: UIButton) {
        self.delegate?.didSelectedBtnCamera(self)
        if isShowSubButton {
            tappedScreen()
            return
        }
    }
    
    func tappedBtnCheckIn(btn: UIButton) {
        self.delegate?.didSelectedBtnCheckIn(self)
        if isShowSubButton {
            tappedScreen()
            return
        }
    }
    
    func tappedBtnCheckOut(btn: UIButton) {
        self.delegate?.didSelectedBtnCheckOut(self)
        if isShowSubButton {
            tappedScreen()
            return
        }
    }
    
    //MARK:- View Setting
    convenience init(delegate: BottomMenuViewDelegate?) {
        self.init()
        self.delegate = delegate
        self.setupViewsAndLayout()
    }
    
    func setupViewsAndLayout() {
        self.addSubview(viewBackground)
        self.viewBackground.addSubview(btnHome)
        self.viewBackground.addSubview(btnCalendar)
        self.viewBackground.addSubview(btnAlart)
        self.viewBackground.addSubview(btnSetting)
        
        self.addSubview(viewBlueBackground)
        self.addSubview(imgViewEclipseBackground)
        self.addSubview(btnContact)
        self.addSubview(btnVideo)
        self.addSubview(btnCamera)
        self.addSubview(btnCheckIn)
        self.addSubview(btnCheckOut)
        self.addSubview(btnCenter)
        self.imgViewEclipseBackground.isHidden = true
        
        let items = [(btnContact, imgViewIconText), (btnVideo, imgViewIconVideo), (btnCamera, imgViewIconCamera), (btnCheckIn, imgViewIconCheckIn), (btnCheckOut, imgViewIconCheckOut)]
        for (btn, img) in items {
            btn.addSubview(img)
            img.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
            })
            itemsArr.append(btn)
        }
        
        self.backgroundColor = UIColor.clear
        viewBlueBackground.isHidden = true
        setupGesture()
        
        btnCenter.layer.cornerRadius = kHeightCenterButtonRatio * UIManager.screenWidth() / 2
        btnCenter.layer.shadowOpacity = 1
        btnCenter.layer.shadowColor = Theme.shared.color_Dark_App().cgColor
        btnCenter.layer.shadowRadius = 15
        
        self.btnCenter.addSubview(imgViewLogo)
        imgViewLogo.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.9)
        }
        
        self.btnCenter.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalToSuperview().multipliedBy(kHeightCenterButtonRatio)
            make.height.equalTo(btnCenter.snp.width)
        }
        
        viewBlueBackground.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIManager.screenHeight())
        }
        
        viewBackground.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        let arr = [btnContact, btnVideo, btnCamera, btnCheckIn, btnCheckOut];
        for btn in arr {
            btn.snp.makeConstraints({ (make) in
                make.centerX.equalTo(btnCenter)
                make.centerY.equalTo(btnCenter)
                make.width.equalTo(60)
                make.height.equalTo(btn.snp.width)
            })
        }
        
        let onePartWidth = ((1 - kHeightCenterButtonRatio)/8) * UIManager.screenWidth()
        self.btnHome.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(55)
            make.height.equalToSuperview()
            make.centerX.equalTo(btnCenter.snp.leading).offset(-3*onePartWidth)
        }
        
        self.btnCalendar.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(55)
            make.height.equalToSuperview()
            make.centerX.equalTo(btnCenter.snp.leading).offset(-1.2*onePartWidth)
        }
        
        self.btnAlart.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(55)
            make.height.equalToSuperview()
            make.centerX.equalTo(btnCenter.snp.trailing).offset(1.2*onePartWidth)
        }
        
        self.btnSetting.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-1)
            make.width.equalTo(55)
            make.height.equalToSuperview()
            make.centerX.equalTo(btnCenter.snp.trailing).offset(3*onePartWidth)
        }
        
        let arrButtons = [btnHome, btnCalendar, btnAlart, btnSetting]
        for btn in arrButtons {
            let view = UIView()
            view.backgroundColor = Theme.shared.color_App()
            view.layer.cornerRadius = 2
            self.viewBackground.addSubview(view)
            highlightViewArr.append(view)
            view.snp.makeConstraints({ (make) in
                make.bottom.equalToSuperview()
                make.centerX.equalTo(btn)
                make.width.equalTo(btn.snp.width)
                make.height.equalTo(5)
            })
        }
        
        currentIndex = 0
        btnHome.isSelected = true
    }
    
    func setupGesture() {
        gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedScreen))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.isEnabled = false
    }
    
    func tappedScreen() {
        hiddenSubButtons()
        isShowSubButton = false
        gesture.isEnabled = false
    }
    
    func showSubButtons() {
        viewBlueBackground.isHidden = false
        viewBlueBackground.alpha = 0
        
        self.imgViewEclipseBackground.isHidden = false
        self.imgViewEclipseBackground.center.x = self.btnCenter.center.x
        self.imgViewEclipseBackground.center.y = self.btnCenter.center.y - 20
        self.imgViewEclipseBackground.frame.size.width = 80*2
        
        UIView.animate(withDuration: 0.35, animations: {
            self.viewBlueBackground.alpha = 1
            let delta = 80
            
            switch self.itemsArr.count {
            case 3:
                self.itemsArr[0].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter)
                    make.centerX.equalTo(self.btnCenter).offset(-delta)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnContact.snp.width)
                })
                
                self.itemsArr[1].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter).offset(-delta)
                    make.centerX.equalTo(self.btnCenter)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnVideo.snp.width)
                })
                
                self.itemsArr[2].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter)
                    make.centerX.equalTo(self.btnCenter).offset(delta)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnCamera.snp.width)
                })
                break
                
            case 4:
                self.itemsArr[0].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter)
                    make.centerX.equalTo(self.btnCenter).offset(-delta)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnContact.snp.width)
                })
                
                self.itemsArr[1].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter).offset(-60)
                    make.centerX.equalTo(self.btnCenter).offset(-delta/2)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnVideo.snp.width)
                })
                
                self.itemsArr[2].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter).offset(-60)
                    make.centerX.equalTo(self.btnCenter).offset(delta/2)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnCamera.snp.width)
                })
                
                self.itemsArr[3].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter)
                    make.centerX.equalTo(self.btnCenter).offset(delta)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnCheckIn.snp.width)
                })
                break
                
            case 5:
                self.itemsArr[0].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter)
                    make.centerX.equalTo(self.btnCenter).offset(-delta)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnContact.snp.width)
                })
                
                self.itemsArr[1].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter).offset(-56.56)
                    make.centerX.equalTo(self.btnCenter).offset(-56.56)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnVideo.snp.width)
                })
                
                self.itemsArr[2].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter).offset(-delta)
                    make.centerX.equalTo(self.btnCenter)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnCamera.snp.width)
                })
                
                self.itemsArr[3].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter).offset(-56.56)
                    make.centerX.equalTo(self.btnCenter).offset(56.56)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnCheckIn.snp.width)
                })
                
                self.itemsArr[4].snp.updateConstraints({ (make) in
                    make.centerY.equalTo(self.btnCenter)
                    make.centerX.equalTo(self.btnCenter).offset(delta)
                    make.width.equalTo(60)
                    make.height.equalTo(self.btnCheckOut.snp.width)
                })
                break
                
            default:
                break
            }
        }) { (finish) in
            
        }
    }
    
    func hiddenSubButtons() {
        self.imgViewEclipseBackground.isHidden = true
        viewBlueBackground.alpha = 1
        UIView.animate(withDuration: 0.35, animations: { 
            self.viewBlueBackground.alpha = 0
            let arr = [self.btnContact, self.btnVideo, self.btnCamera, self.btnCheckIn, self.btnCheckOut];
            for btn in arr {
                btn.snp.updateConstraints({ (make) in
                    make.centerX.equalTo(self.btnCenter)
                    make.centerY.equalTo(self.btnCenter)
                    make.width.equalTo(60)
                    make.height.equalTo(btn.snp.width)
                })
            }
            self.layoutIfNeeded()
        }) { (finish) in
            self.viewBlueBackground.isHidden = true
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var height: CGFloat = 10
        if viewBlueBackground.isHidden == false {
            height = 160
        }
        let rect = CGRect(x: 0, y: -110, width: UIManager.screenWidth(), height: height)
        if rect.contains(point) {
            return true
        }
        return super.point(inside: point, with: event)
    }
}
