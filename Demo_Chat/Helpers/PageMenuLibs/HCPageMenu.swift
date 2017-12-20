//
//  HCPageMenu.swift
//  Demo_Chat
//
//  Created by HungNV on 8/11/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit

@objc public protocol HCPageMenuDelegate {
    @objc optional func willMoveToPage(controller: UIViewController, index: Int)
    @objc optional func didMoveToPage(controller: UIViewController, index: Int)
}

class MenuItemView: UIView {
    var lblTitle: UILabel?
    var menuItemSeparator: UIView?
    
    func setupMenuItemView(menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat, separatorPercentageHeight: CGFloat, separatorWidth: CGFloat, separatorRoundEdges: Bool, menuItemSeparatorColor: UIColor) {
        lblTitle = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: menuItemWidth, height: menuScrollViewHeight - indicatorHeight))
        menuItemSeparator = UIView(frame: CGRect(x: menuItemWidth - (separatorWidth / 2), y: floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)), width: separatorWidth, height: floor(menuScrollViewHeight * separatorPercentageHeight)))
        menuItemSeparator!.backgroundColor = menuItemSeparatorColor
        
        if separatorRoundEdges {
            menuItemSeparator!.layer.cornerRadius = menuItemSeparator!.frame.width / 2
        }
        
        menuItemSeparator?.isHidden = true
        self.addSubview(menuItemSeparator!)
        self.addSubview(lblTitle!)
    }
    
    func setTitleText(text: String) {
        if lblTitle != nil {
            lblTitle!.text = text as String
            lblTitle!.numberOfLines = 0
            lblTitle!.sizeToFit()
        }
    }
}

public enum HCPageMenuOption {
    case SelectionIndicatorHeight(CGFloat)
    case MenuItemSeparatorWidth(CGFloat)
    case ScrollMenuBackgroundColor(UIColor)
    case ViewBackgroundColor(UIColor)
    case BottomMenuHairlineColor(UIColor)
    case SelectionIndicatorColor(UIColor)
    case MenuItemSeparatorColor(UIColor)
    case MenuMargin(CGFloat)
    case MenuItemMargin(CGFloat)
    case MenuHeight(CGFloat)
    case SelectedMenuItemLabelColor(UIColor)
    case UnselectedMenuItemLabelColor(UIColor)
    case UseMenuLikeSegmentedControl(Bool)
    case MenuItemSeparatorRoundEdges(Bool)
    case MenuItemFont(UIFont)
    case MenuItemSeparatorPercentageHeight(CGFloat)
    case MenuItemWidth(CGFloat)
    case EnableHorizontalBounce(Bool)
    case AddBottomMenuHairline(Bool)
    case MenuItemWidthBasedOnTitleTextWidth(Bool)
    case TitleTextSizeBasedOnMenuItemWidth(Bool)
    case ScrollAnimationDurationOnMenuItemTap(Int)
    case CenterMenuItems(Bool)
    case HideTopMenuBar(Bool)
}

public class HCPageMenu: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    let menuScrollView = UIScrollView()
    let controllerScrollView = UIScrollView()
    var controllerArray: [UIViewController] = []
    var menuItems: [MenuItemView] = []
    var menuItemWidths: [CGFloat] = []
    
    public var menuHeight: CGFloat = 34.0
    public var menuMargin: CGFloat = 15.0
    public var menuItemWidth: CGFloat = 111.0
    public var selectionIndicatorHeight: CGFloat = 3.0
    var totalMenuItemWidthIfDifferentWidths: CGFloat = 0.0
    public var scrollAnimationDurationOnMenuItemTap: Int = 500
    var startingMenuMargin: CGFloat = 0.0
    var menuItemMargin: CGFloat = 0.0
    var selectionIndicatorView: UIView = UIView()
    var currentPageIndex: Int = 0
    var lastPageIndex: Int = 0
    
    public var selectionIndicatorColor: UIColor = UIColor.white
    public var selectedMenuItemLabelColor: UIColor = UIColor.white
    public var unselectedMenuItemLabelColor: UIColor = UIColor.lightGray
    public var scrollMenuBackgroundColor: UIColor = UIColor.black
    public var viewBackgroundColor: UIColor = UIColor.white
    public var bottomMenuHairlineColor: UIColor = UIColor.white
    public var menuItemSeparatorColor: UIColor = UIColor.lightGray
    
    public var menuItemFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    public var menuItemSeparatorPercentageHeight: CGFloat = 0.2
    public var menuItemSeparatorWidth: CGFloat = 0.5
    public var menuItemSeparatorRoundEdges: Bool = false
    
    public var addBottomMenuHairline: Bool = true
    public var menuItemWidthBasedOnTitleTextWidth: Bool = false
    public var titleTextSizeBasedOnMenuItemWidth: Bool = false
    public var useMenuLikeSegmentedControl: Bool = false
    public var centerMenuItems: Bool = true
    public var enableHorizontalBounce: Bool = false
    public var hideTopMenuBar: Bool = false
    
    var currentOrientationIsPortrait: Bool = true
    var pageIndexForOrientationChange: Int = 0
    var didLayoutSubviewsAfterRotation: Bool = false
    var didScrollAlready: Bool = false
    var lastControllerScrollViewContentOffset: CGFloat = 0.0
    var lastScrollDirection: HCPageMenuScrollDirection = .Other
    var startingPageForScroll: Int = 0
    var didTapMenuItemToScroll: Bool = false
    var pagesAddedDictionary: [Int:Int] = [:]
    
    public weak var delegate: HCPageMenuDelegate?
    var tapTimer: Timer?
    
    enum HCPageMenuScrollDirection: Int {
        case Left
        case Right
        case Other
    }
    
    public init(viewControllers: [UIViewController], frame: CGRect, options: [String:AnyObject]?) {
        super.init(nibName: nil, bundle: nil)
        controllerArray = viewControllers
        self.view.frame = frame
    }
    
    public convenience init(viewControllers: [UIViewController], frame: CGRect, pageMenuOptions: [HCPageMenuOption]?) {
        self.init(viewControllers:viewControllers, frame:frame, options:nil)
        
        if let options = pageMenuOptions {
            for option in options {
                switch (option) {
                case let .SelectionIndicatorHeight(value):
                    selectionIndicatorHeight = value
                case let .MenuItemSeparatorWidth(value):
                    menuItemSeparatorWidth = value
                case let .ScrollMenuBackgroundColor(value):
                    scrollMenuBackgroundColor = value
                case let .ViewBackgroundColor(value):
                    viewBackgroundColor = value
                case let .BottomMenuHairlineColor(value):
                    bottomMenuHairlineColor = value
                case let .SelectionIndicatorColor(value):
                    selectionIndicatorColor = value
                case let .MenuItemSeparatorColor(value):
                    menuItemSeparatorColor = value
                case let .MenuMargin(value):
                    menuMargin = value
                case let .MenuItemMargin(value):
                    menuItemMargin = value
                case let .MenuHeight(value):
                    menuHeight = value
                case let .SelectedMenuItemLabelColor(value):
                    selectedMenuItemLabelColor = value
                case let .UnselectedMenuItemLabelColor(value):
                    unselectedMenuItemLabelColor = value
                case let .UseMenuLikeSegmentedControl(value):
                    useMenuLikeSegmentedControl = value
                case let .MenuItemSeparatorRoundEdges(value):
                    menuItemSeparatorRoundEdges = value
                case let .MenuItemFont(value):
                    menuItemFont = value
                case let .MenuItemSeparatorPercentageHeight(value):
                    menuItemSeparatorPercentageHeight = value
                case let .MenuItemWidth(value):
                    menuItemWidth = value
                case let .EnableHorizontalBounce(value):
                    enableHorizontalBounce = value
                case let .AddBottomMenuHairline(value):
                    addBottomMenuHairline = value
                case let .MenuItemWidthBasedOnTitleTextWidth(value):
                    menuItemWidthBasedOnTitleTextWidth = value
                case let .TitleTextSizeBasedOnMenuItemWidth(value):
                    titleTextSizeBasedOnMenuItemWidth = value
                case let .ScrollAnimationDurationOnMenuItemTap(value):
                    scrollAnimationDurationOnMenuItemTap = value
                case let .CenterMenuItems(value):
                    centerMenuItems = value
                case let .HideTopMenuBar(value):
                    hideTopMenuBar = value
                }
            }
            
            if hideTopMenuBar {
                addBottomMenuHairline = false
                menuHeight = 0.0
            }
        }
        
        self.setupUserInterface()
        
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUserInterface() {
        let viewsDictionary = ["menuScrollView":menuScrollView, "controllerScrollView":controllerScrollView]
        
        controllerScrollView.isPagingEnabled = true
        controllerScrollView.translatesAutoresizingMaskIntoConstraints = false
        controllerScrollView.alwaysBounceHorizontal = enableHorizontalBounce
        controllerScrollView.bounces = enableHorizontalBounce
        
        controllerScrollView.frame = CGRect(x:0.0,y: menuHeight,width: self.view.frame.width,height: self.view.frame.height)
        
        self.view.addSubview(controllerScrollView)
        
        let controllerScrollView_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[controllerScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let controllerScrollView_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|[controllerScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(controllerScrollView_constraint_H)
        self.view.addConstraints(controllerScrollView_constraint_V)
        
        menuScrollView.translatesAutoresizingMaskIntoConstraints = false
        menuScrollView.frame = CGRect(x: 0.0,y: 0.0,width: self.view.frame.width, height: menuHeight)
        self.view.addSubview(menuScrollView)
        
        let menuScrollView_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let menuScrollView_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:[menuScrollView(\(menuHeight))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        self.view.addConstraints(menuScrollView_constraint_H)
        self.view.addConstraints(menuScrollView_constraint_V)
        
        if addBottomMenuHairline {
            let menuBottomHairline : UIView = UIView()
            
            menuBottomHairline.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(menuBottomHairline)
            
            let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuBottomHairline]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(menuHeight)-[menuBottomHairline(0.5)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            
            self.view.addConstraints(menuBottomHairline_constraint_H)
            self.view.addConstraints(menuBottomHairline_constraint_V)
            
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
        }
        
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        controllerScrollView.showsHorizontalScrollIndicator = false
        controllerScrollView.showsVerticalScrollIndicator = false
        
        self.view.backgroundColor = viewBackgroundColor
        menuScrollView.backgroundColor = scrollMenuBackgroundColor
    }
    
    func configureUserInterface() {
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuItemTap(gestureRecognizer:)))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        
        controllerScrollView.delegate = self
        
        menuScrollView.scrollsToTop = false;
        controllerScrollView.scrollsToTop = false;
        
        if useMenuLikeSegmentedControl {
            menuScrollView.isScrollEnabled = false
            menuScrollView.contentSize = CGSize(width: self.view.frame.width, height: menuHeight)
            menuMargin = 0.0
        } else {
            menuScrollView.contentSize = CGSize(width: (menuItemWidth + menuMargin) * CGFloat(controllerArray.count) + menuMargin,height: menuHeight)
        }
        
        controllerScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(controllerArray.count),height: 0.0)
        
        var index : CGFloat = 0.0
        for controller in controllerArray {
            if index == 0.0 {
                addPageAtIndex(index: 0)
            }
            
            var menuItemFrame : CGRect = CGRect()
            if useMenuLikeSegmentedControl {
                if menuItemMargin > 0 {
                    let marginSum = menuItemMargin * CGFloat(controllerArray.count + 1)
                    let menuItemWidth = (self.view.frame.width - marginSum) / CGFloat(controllerArray.count)
                    menuItemFrame = CGRect(x: CGFloat(menuItemMargin * (index + 1)) + menuItemWidth * CGFloat(index),y: 0.0,width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count),height: menuHeight)
                } else {
                    menuItemFrame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index),y: 0.0,width: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count),height: menuHeight)
                }
            } else if menuItemWidthBasedOnTitleTextWidth {
                let controllerTitle : String? = controller.title
                
                let titleText : String = controllerTitle != nil ? controllerTitle! : "Menu \(Int(index) + 1)"
                
                let itemWidthRect : CGRect = (titleText as NSString).boundingRect(with: CGSize(width: 1000,height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                
                menuItemWidth = itemWidthRect.width
                
                menuItemFrame = CGRect(x: totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * index),y: 0.0,width: menuItemWidth, height: menuHeight)
                
                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            } else {
                if centerMenuItems && index == 0.0  {
                    startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * menuItemWidth) + (CGFloat(controllerArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                    
                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }
                    
                    menuItemFrame = CGRect(x: startingMenuMargin + menuMargin,y: 0.0,width: menuItemWidth,height: menuHeight)
                } else {
                    menuItemFrame = CGRect(x: menuItemWidth * index + menuMargin * (index + 1) + startingMenuMargin,y: 0.0,width: menuItemWidth,height: menuHeight)
                }
            }
            
            let menuItemView : MenuItemView = MenuItemView(frame: menuItemFrame)
            if useMenuLikeSegmentedControl {
                if menuItemMargin > 0 {
                    let marginSum = menuItemMargin * CGFloat(controllerArray.count + 1)
                    let menuItemWidth = (self.view.frame.width - marginSum) / CGFloat(controllerArray.count)
                    menuItemView.setupMenuItemView(menuItemWidth: menuItemWidth, menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
                } else {
                    menuItemView.setupMenuItemView(menuItemWidth: CGFloat(self.view.frame.width) / CGFloat(controllerArray.count), menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
                }
            } else {
                menuItemView.setupMenuItemView(menuItemWidth: menuItemWidth, menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight, separatorPercentageHeight: menuItemSeparatorPercentageHeight, separatorWidth: menuItemSeparatorWidth, separatorRoundEdges: menuItemSeparatorRoundEdges, menuItemSeparatorColor: menuItemSeparatorColor)
            }
            
            menuItemView.lblTitle!.font = menuItemFont
            menuItemView.lblTitle!.textAlignment = NSTextAlignment.center
            menuItemView.lblTitle!.textColor = unselectedMenuItemLabelColor
            
            menuItemView.lblTitle!.adjustsFontSizeToFitWidth = titleTextSizeBasedOnMenuItemWidth
            
            if controller.title != nil {
                menuItemView.lblTitle!.text = controller.title!
            } else {
                menuItemView.lblTitle!.text = "Menu \(Int(index) + 1)"
            }
            
            if useMenuLikeSegmentedControl {
                if Int(index) < controllerArray.count - 1 {
                    menuItemView.menuItemSeparator!.isHidden = false
                }
            }
            
            menuScrollView.addSubview(menuItemView)
            menuItems.append(menuItemView)
            
            index += 1
        }
        
        if menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSize(width: (totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(controllerArray.count) * menuMargin,height: menuHeight)
        }
        
        if menuItems.count > 0 {
            if menuItems[currentPageIndex].lblTitle != nil {
                menuItems[currentPageIndex].lblTitle!.textColor = selectedMenuItemLabelColor
            }
        }
        
        var selectionIndicatorFrame : CGRect = CGRect()
        if useMenuLikeSegmentedControl {
            selectionIndicatorFrame = CGRect(x: 0.0,y: menuHeight - selectionIndicatorHeight,width: self.view.frame.width / CGFloat(controllerArray.count),height: selectionIndicatorHeight)
        } else if menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRect(x: menuMargin,y: menuHeight - selectionIndicatorHeight,width: menuItemWidths[0], height: selectionIndicatorHeight)
        } else {
            if centerMenuItems  {
                selectionIndicatorFrame = CGRect(x: startingMenuMargin + menuMargin,y: menuHeight - selectionIndicatorHeight, width: menuItemWidth,height: selectionIndicatorHeight)
            } else {
                selectionIndicatorFrame = CGRect(x: menuMargin,y: menuHeight - selectionIndicatorHeight,width: menuItemWidth, height: selectionIndicatorHeight)
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
        
        if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
            self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            selectionIndicatorView.frame = CGRect(x: leadingAndTrailingMargin,y:  menuHeight - selectionIndicatorHeight,width: menuItemWidths[0], height: selectionIndicatorHeight)
        }
    }
    
    private func configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() {
        if menuScrollView.contentSize.width < self.view.bounds.width {
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            for (index, menuItem) in menuItems.enumerated() {
                let controllerTitle = controllerArray[index].title!
                
                let itemWidthRect = controllerTitle.boundingRect(with: CGSize(width: 1000,height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:menuItemFont], context: nil)
                
                menuItemWidth = itemWidthRect.width
                
                var margin: CGFloat
                if index == 0 {
                    margin = leadingAndTrailingMargin
                } else {
                    let previousMenuItem = menuItems[index-1]
                    let previousX = previousMenuItem.frame.maxX
                    margin = previousX + menuMargin
                }
                
                menuItem.frame = CGRect(x: margin,y: 0.0,width: menuItemWidth, height: menuHeight)
            }
        } else {
            for (index, menuItem) in menuItems.enumerated() {
                var menuItemX: CGFloat
                if index == 0 {
                    menuItemX = menuMargin
                } else {
                    menuItemX = menuItems[index-1].frame.maxX + menuMargin
                }
                
                menuItem.frame = CGRect(x: menuItemX,y: 0.0,width: menuItem.bounds.width,height: menuItem.bounds.height)
            }
        }
    }
    
    private func getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() -> CGFloat {
        let menuItemsTotalWidth = menuScrollView.contentSize.width - menuMargin * 2
        let leadingAndTrailingMargin = (self.view.bounds.width - menuItemsTotalWidth) / 2
        
        return leadingAndTrailingMargin
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !didLayoutSubviewsAfterRotation {
            if scrollView.isEqual(controllerScrollView) {
                if scrollView.contentOffset.x >= 0.0 && scrollView.contentOffset.x <= (CGFloat(controllerArray.count - 1) * self.view.frame.width) {
                    if (currentOrientationIsPortrait && UIApplication.shared.statusBarOrientation.isPortrait) || (!currentOrientationIsPortrait && UIApplication.shared.statusBarOrientation.isLandscape) {
                        if !didTapMenuItemToScroll {
                            if didScrollAlready {
                                var newScrollDirection : HCPageMenuScrollDirection = .Other
                                
                                if (CGFloat(startingPageForScroll) * scrollView.frame.width > scrollView.contentOffset.x) {
                                    newScrollDirection = .Right
                                } else if (CGFloat(startingPageForScroll) * scrollView.frame.width < scrollView.contentOffset.x) {
                                    newScrollDirection = .Left
                                }
                                
                                if newScrollDirection != .Other {
                                    if lastScrollDirection != newScrollDirection {
                                        let index : Int = newScrollDirection == .Left ? currentPageIndex + 1 : currentPageIndex - 1
                                        
                                        if index >= 0 && index < controllerArray.count {
                                            if pagesAddedDictionary[index] != index {
                                                addPageAtIndex(index: index)
                                                pagesAddedDictionary[index] = index
                                            }
                                        }
                                    }
                                }
                                
                                lastScrollDirection = newScrollDirection
                            }
                            
                            if !didScrollAlready {
                                if (lastControllerScrollViewContentOffset > scrollView.contentOffset.x) {
                                    if currentPageIndex != controllerArray.count - 1 {
                                        let index : Int = currentPageIndex - 1
                                        
                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPageAtIndex(index: index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        lastScrollDirection = .Right
                                    }
                                } else if (lastControllerScrollViewContentOffset < scrollView.contentOffset.x) {
                                    if currentPageIndex != 0 {
                                        let index : Int = currentPageIndex + 1
                                        
                                        if pagesAddedDictionary[index] != index && index < controllerArray.count && index >= 0 {
                                            addPageAtIndex(index: index)
                                            pagesAddedDictionary[index] = index
                                        }
                                        lastScrollDirection = .Left
                                    }
                                }
                                didScrollAlready = true
                            }
                            lastControllerScrollViewContentOffset = scrollView.contentOffset.x
                        }
                        
                        var ratio : CGFloat = 1.0
                        
                        ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                        
                        if menuScrollView.contentSize.width > self.view.frame.width {
                            var offset : CGPoint = menuScrollView.contentOffset
                            offset.x = controllerScrollView.contentOffset.x * ratio
                            menuScrollView.setContentOffset(offset, animated: false)
                        }
                        
                        let width : CGFloat = controllerScrollView.frame.size.width;
                        let page : Int = Int((controllerScrollView.contentOffset.x + (0.5 * width)) / width)
                        
                        if page != currentPageIndex {
                            lastPageIndex = currentPageIndex
                            currentPageIndex = page
                            
                            if pagesAddedDictionary[page] != page && page < controllerArray.count && page >= 0 {
                                addPageAtIndex(index: page)
                                pagesAddedDictionary[page] = page
                            }
                            
                            if !didTapMenuItemToScroll {
                                if pagesAddedDictionary[lastPageIndex] != lastPageIndex {
                                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                                }
                                
                                let indexLeftTwo : Int = page - 2
                                if pagesAddedDictionary[indexLeftTwo] == indexLeftTwo {
                                    pagesAddedDictionary.removeValue(forKey: indexLeftTwo)
                                    removePageAtIndex(index: indexLeftTwo)
                                }
                                let indexRightTwo : Int = page + 2
                                if pagesAddedDictionary[indexRightTwo] == indexRightTwo {
                                    pagesAddedDictionary.removeValue(forKey: indexRightTwo)
                                    removePageAtIndex(index: indexRightTwo)
                                }
                            }
                        }
                        
                        moveSelectionIndicator(pageIndex: page)
                    }
                } else {
                    var ratio : CGFloat = 1.0
                    
                    ratio = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
                    
                    if menuScrollView.contentSize.width > self.view.frame.width {
                        var offset : CGPoint = menuScrollView.contentOffset
                        offset.x = controllerScrollView.contentOffset.x * ratio
                        menuScrollView.setContentOffset(offset, animated: false)
                    }
                }
            }
        } else {
            didLayoutSubviewsAfterRotation = false
            moveSelectionIndicator(pageIndex: currentPageIndex)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(controllerScrollView) {
            // Call didMoveToPage delegate function
            let currentController = controllerArray[currentPageIndex]
            delegate?.didMoveToPage?(controller: currentController, index: currentPageIndex)
            
            // Remove all but current page after decelerating
            for key in pagesAddedDictionary.keys {
                if key != currentPageIndex {
                    removePageAtIndex(index: key)
                }
            }
            
            didScrollAlready = false
            startingPageForScroll = currentPageIndex
            
            
            // Empty out pages in dictionary
            pagesAddedDictionary.removeAll(keepingCapacity: false)
        }
    }
    
    func scrollViewDidEndTapScrollingAnimation() {
        let currentController = controllerArray[currentPageIndex]
        delegate?.didMoveToPage?(controller: currentController, index: currentPageIndex)
        
        for key in pagesAddedDictionary.keys {
            if key != currentPageIndex {
                removePageAtIndex(index: key)
            }
        }
        startingPageForScroll = currentPageIndex
        didTapMenuItemToScroll = false
        pagesAddedDictionary.removeAll(keepingCapacity: false)
    }
    
    func moveSelectionIndicator(pageIndex: Int) {
        if pageIndex >= 0 && pageIndex < controllerArray.count {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                var selectionIndicatorWidth : CGFloat = self.selectionIndicatorView.frame.width
                var selectionIndicatorX : CGFloat = 0.0
                
                if self.useMenuLikeSegmentedControl {
                    selectionIndicatorX = CGFloat(pageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                    selectionIndicatorWidth = self.view.frame.width / CGFloat(self.controllerArray.count)
                } else if self.menuItemWidthBasedOnTitleTextWidth {
                    selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                    selectionIndicatorX = self.menuItems[pageIndex].frame.minX
                } else {
                    if self.centerMenuItems && pageIndex == 0 {
                        selectionIndicatorX = self.startingMenuMargin + self.menuMargin
                    } else {
                        selectionIndicatorX = self.menuItemWidth * CGFloat(pageIndex) + self.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                    }
                }
                
                self.selectionIndicatorView.frame = CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth,height: self.selectionIndicatorView.frame.height)
                
                if self.menuItems.count > 0 {
                    if self.menuItems[self.lastPageIndex].lblTitle != nil && self.menuItems[self.currentPageIndex].lblTitle != nil {
                        self.menuItems[self.lastPageIndex].lblTitle!.textColor = self.unselectedMenuItemLabelColor
                        self.menuItems[self.currentPageIndex].lblTitle!.textColor = self.selectedMenuItemLabelColor
                    }
                }
            })
        }
    }
    
    func handleMenuItemTap(gestureRecognizer : UITapGestureRecognizer) {
        let tappedPoint : CGPoint = gestureRecognizer.location(in: menuScrollView)
        if tappedPoint.y < menuScrollView.frame.height {
            var itemIndex : Int = 0
            
            if useMenuLikeSegmentedControl {
                itemIndex = Int(tappedPoint.x / (self.view.frame.width / CGFloat(controllerArray.count)))
            } else if menuItemWidthBasedOnTitleTextWidth {
                var menuItemLeftBound: CGFloat
                var menuItemRightBound: CGFloat
                if centerMenuItems {
                    menuItemLeftBound = menuItems[0].frame.minX
                    menuItemRightBound = menuItems[menuItems.count-1].frame.maxX
                    
                    if (tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        for (index, _) in controllerArray.enumerated() {
                            menuItemLeftBound = menuItems[index].frame.minX
                            menuItemRightBound = menuItems[index].frame.maxX
                            
                            if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                                itemIndex = index
                                break
                            }
                        }
                    }
                } else {
                    menuItemLeftBound = 0.0
                    menuItemRightBound = menuItemWidths[0] + menuMargin + (menuMargin / 2)
                    
                    if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                        for i in 1...controllerArray.count - 1 {
                            menuItemLeftBound = menuItemRightBound + 1.0
                            menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + menuMargin
                            
                            if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                                itemIndex = i
                                break
                            }
                        }
                    }
                }
            } else {
                let rawItemIndex : CGFloat = ((tappedPoint.x - startingMenuMargin) - menuMargin / 2) / (menuMargin + menuItemWidth)
                
                if rawItemIndex < 0 {
                    itemIndex = -1
                } else {
                    itemIndex = Int(rawItemIndex)
                }
            }
            
            if itemIndex >= 0 && itemIndex < controllerArray.count {
                if itemIndex != currentPageIndex {
                    startingPageForScroll = itemIndex
                    lastPageIndex = currentPageIndex
                    currentPageIndex = itemIndex
                    didTapMenuItemToScroll = true
                    
                    let smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                    let largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex
                    
                    if smallerIndex + 1 != largerIndex {
                        for index in (smallerIndex + 1)...(largerIndex - 1) {
                            if pagesAddedDictionary[index] != index {
                                addPageAtIndex(index: index)
                                pagesAddedDictionary[index] = index
                            }
                        }
                    }
                    
                    addPageAtIndex(index: itemIndex)
                    pagesAddedDictionary[lastPageIndex] = lastPageIndex
                }
                let duration : Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
                
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    let xOffset : CGFloat = CGFloat(itemIndex) * self.controllerScrollView.frame.width
                    self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
                })
                
                if tapTimer != nil {
                    tapTimer!.invalidate()
                }
                
                let timerInterval : TimeInterval = Double(scrollAnimationDurationOnMenuItemTap) * 0.001
                tapTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(scrollViewDidEndTapScrollingAnimation) , userInfo: nil, repeats: false)
            }
        }
    }
    
    func addPageAtIndex(index : Int) {
        let currentController = controllerArray[index]
        delegate?.willMoveToPage?(controller: currentController, index: index)
        let newVC = controllerArray[index]
        newVC.willMove(toParentViewController: self)
        newVC.view.frame = CGRect(x: self.view.frame.width * CGFloat(index),y: menuHeight,width: self.view.frame.width,height: self.view.frame.height - menuHeight)
        self.addChildViewController(newVC)
        self.controllerScrollView.addSubview(newVC.view)
        newVC.didMove(toParentViewController: self)
    }
    
    func removePageAtIndex(index : Int) {
        let oldVC = controllerArray[index]
        oldVC.willMove(toParentViewController: nil)
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParentViewController()
    }
    
    override public func viewDidLayoutSubviews() {
        controllerScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(controllerArray.count),height: self.view.frame.height - menuHeight)
        
        let oldCurrentOrientationIsPortrait : Bool = currentOrientationIsPortrait
        currentOrientationIsPortrait = UIApplication.shared.statusBarOrientation.isPortrait
        
        if (oldCurrentOrientationIsPortrait && UIDevice.current.orientation.isLandscape) || (!oldCurrentOrientationIsPortrait && UIDevice.current.orientation.isPortrait) {
            didLayoutSubviewsAfterRotation = true
            
            if useMenuLikeSegmentedControl {
                menuScrollView.contentSize = CGSize(width: self.view.frame.width, height: menuHeight)
                
                let selectionIndicatorX : CGFloat = CGFloat(currentPageIndex) * (self.view.frame.width / CGFloat(self.controllerArray.count))
                let selectionIndicatorWidth : CGFloat = self.view.frame.width / CGFloat(self.controllerArray.count)
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth,height: self.selectionIndicatorView.frame.height)
                
                var index : Int = 0
                
                for item : MenuItemView in menuItems as [MenuItemView] {
                    item.frame = CGRect(x: self.view.frame.width / CGFloat(controllerArray.count) * CGFloat(index),y: 0.0, width: self.view.frame.width / CGFloat(controllerArray.count),height: menuHeight)
                    item.lblTitle!.frame = CGRect(x: 0.0,y: 0.0,width: self.view.frame.width / CGFloat(controllerArray.count),height: menuHeight)
                    item.menuItemSeparator!.frame = CGRect(x: item.frame.width - (menuItemSeparatorWidth / 2),y: item.menuItemSeparator!.frame.origin.y,width: item.menuItemSeparator!.frame.width,height: item.menuItemSeparator!.frame.height)
                    
                    index += 1
                }
            } else if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
                self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
                let selectionIndicatorX = menuItems[currentPageIndex].frame.minX
                selectionIndicatorView.frame = CGRect(x: selectionIndicatorX,y: menuHeight - selectionIndicatorHeight,width: menuItemWidths[currentPageIndex],height: selectionIndicatorHeight)
            } else if centerMenuItems {
                startingMenuMargin = ((self.view.frame.width - ((CGFloat(controllerArray.count) * menuItemWidth) + (CGFloat(controllerArray.count - 1) * menuMargin))) / 2.0) -  menuMargin
                
                if startingMenuMargin < 0.0 {
                    startingMenuMargin = 0.0
                }
                
                let selectionIndicatorX : CGFloat = self.menuItemWidth * CGFloat(currentPageIndex) + self.menuMargin * CGFloat(currentPageIndex + 1) + self.startingMenuMargin
                selectionIndicatorView.frame =  CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y,width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
                
                // Recalculate frame for menu items if centered
                var index : Int = 0
                
                for item : MenuItemView in menuItems as [MenuItemView] {
                    if index == 0 {
                        item.frame = CGRect(x: startingMenuMargin + menuMargin, y: 0.0,width: menuItemWidth,height: menuHeight)
                    } else {
                        item.frame = CGRect(x: menuItemWidth * CGFloat(index) + menuMargin * CGFloat(index + 1) + startingMenuMargin,y: 0.0,width: menuItemWidth,height: menuHeight)
                    }
                    
                    index += 1
                }
            }
            
            for view : UIView in controllerScrollView.subviews {
                view.frame = CGRect(x: self.view.frame.width * CGFloat(currentPageIndex),y: menuHeight,width: controllerScrollView.frame.width,height: self.view.frame.height - menuHeight)
            }
            
            let xOffset : CGFloat = CGFloat(self.currentPageIndex) * controllerScrollView.frame.width
            controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: controllerScrollView.contentOffset.y), animated: false)
            
            let ratio : CGFloat = (menuScrollView.contentSize.width - self.view.frame.width) / (controllerScrollView.contentSize.width - self.view.frame.width)
            
            if menuScrollView.contentSize.width > self.view.frame.width {
                var offset : CGPoint = menuScrollView.contentOffset
                offset.x = controllerScrollView.contentOffset.x * ratio
                menuScrollView.setContentOffset(offset, animated: false)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    public func moveToPage(index: Int) {
        if index >= 0 && index < controllerArray.count {
            if index != currentPageIndex {
                startingPageForScroll = index
                lastPageIndex = currentPageIndex
                currentPageIndex = index
                didTapMenuItemToScroll = true
                
                let smallerIndex : Int = lastPageIndex < currentPageIndex ? lastPageIndex : currentPageIndex
                let largerIndex : Int = lastPageIndex > currentPageIndex ? lastPageIndex : currentPageIndex
                
                if smallerIndex + 1 != largerIndex {
                    for i in (smallerIndex + 1)...(largerIndex - 1) {
                        if pagesAddedDictionary[i] != i {
                            addPageAtIndex(index: i)
                            pagesAddedDictionary[i] = i
                        }
                    }
                }
                
                addPageAtIndex(index: index)
                pagesAddedDictionary[lastPageIndex] = lastPageIndex
            }
            let duration : Double = Double(scrollAnimationDurationOnMenuItemTap) / Double(1000)
            
            UIView.animate(withDuration: duration, animations: { () -> Void in
                let xOffset : CGFloat = CGFloat(index) * self.controllerScrollView.frame.width
                self.controllerScrollView.setContentOffset(CGPoint(x: xOffset, y: self.controllerScrollView.contentOffset.y), animated: false)
            })
        }
    }
}
