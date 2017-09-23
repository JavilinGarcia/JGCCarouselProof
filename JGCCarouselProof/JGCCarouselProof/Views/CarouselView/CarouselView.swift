//
//  CarouselView.swift
//  JGCCarouselProof
//
//  Created by Javier Garcia Castro on 23/9/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

@objc protocol CarouselViewDataSource {
    
    func viewsForCarouselView(carouselView: CarouselView) -> [UIView]
    func sizeForViewForCarouselView(carouselView: CarouselView) -> CGSize
    func marginWidthForCarouselView(carouselView: CarouselView) -> CGFloat
    
    @objc optional func navigateToIndexForCarouselView(carouselView: CarouselView) -> Int
    @objc optional func showButtonsForCarouselView(carouselView: CarouselView) -> Bool
    @objc optional func pagingEnabledForCarouselView(carouselView: CarouselView) -> Bool
    @objc optional func hasCollectionView(carouselView: CarouselView) -> Bool
    @objc optional func layerEnableSideViews(carouselView: CarouselView) -> Bool
    @objc optional func scrollingIsEnable(carouselView: CarouselView) -> Bool
}

@objc protocol CarouselViewDelegate {
    
    @objc optional func userDidChangeViewAtIndex(carousel: CarouselView, index: Int)
    @objc optional func userDidTapAtIndex(carousel: CarouselView, index: Int)
    @objc optional func userDidTapAtView(carousel: CarouselView, view: UIView)
}

class CarouselView: UIView, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var widthCollectionViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var buttonsContainerView: UIView!
    
    @IBOutlet weak var heightScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerXScrollViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthButtonsContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerXCollectionViewConstraint: NSLayoutConstraint!
    
    var viewSize: CGSize?
    var pageWidth: CGFloat?
    var marginWidth: CGFloat?
    
    var currentPage: Int? {
        get {
            return Int(floor((self.scrollView.contentOffset.x - (self.pageWidth! + self.marginWidth!) / 2) / (self.pageWidth! + self.marginWidth!)) + 1)
        }
        set {
            self.currentPage = newValue
        }
    }
    
    var pagingEnabled: Bool = false
    var hasCollectionView: Bool = false
    var layerEnableSideViews:Bool = false
    
    var circular: Bool = false
    var delegate: CarouselViewDelegate?
    var dataSource: CarouselViewDataSource?
    
    var atIndex: Int = 0
    var views: [UIView]?
    
    var view:UIView!
    
    // MARK: Initialize
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    convenience init(views: Array<UIView>, delegate: CarouselViewDelegate, viewSize: CGSize, marginWidth: CGFloat, atIndex: Int, showButtons: Bool, pagingEnabled: Bool) {
        
        self.init()
        
        self.delegate = delegate
        self.views = views
        self.viewSize = viewSize
        self.pageWidth = size.width
        self.marginWidth = marginWidth
        self.atIndex = atIndex
        self.pagingEnabled = pagingEnabled
        
        if !showButtons {
            self.buttonsContainerView.removeFromSuperview()
        }
        
        DispatchQueue.main.async {
            self.initialize()
        }
    }
    
    convenience init(delegate: CarouselViewDelegate, dataSource: CarouselViewDataSource) {
        
        self.init()
        
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        
        self.delegate = delegate
        self.dataSource = dataSource
        
        DispatchQueue.main.async {
            self.initialize()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let child: UIView = super.hitTest(point, with: event)!
        
        if child == self && self.subviews.count > 0 {
            return self.subviews[0]
        }
        
        return child
    }
    
    @objc func handleTap(tap: UIGestureRecognizer) {
        userDidTapOnView(view: tap.view!)
    }
    
    func willMoveToSuperview(newSuperView: UIView?) {
        
        if newSuperView != nil {
            initialize()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func userDidTapOnPreviousButton(_ sender: AnyObject) {
        movePrevious()
    }
    
    @IBAction func userDidTapOnNextButton(_ sender: AnyObject) {
        moveNext()
    }
    
    // MARK: - Public Methods
    
    func userDidTapOnView(view: UIView) {
        self.delegate?.userDidTapAtView?(carousel: self, view: view) // 👻if let
        self.delegate?.userDidTapAtIndex?(carousel: self, index: self.atIndex) // 👻if let
    }
    
    func movePrevious() {
        
        let previousPage: Int = currentPage! - 1
        self.scrollView.setContentOffset(CGPoint.init(x: CGFloat(previousPage) * (self.pageWidth! + self.marginWidth!), y: 0), animated: true)
        self.userDidChangeViewAtIndex(atIndex: previousPage)
    }
    
    func moveNext() {
        
        let nextPage: Int = currentPage! + 1
        
        assert((nextPage <= self.views!.count), "CarouselView out of bounds")
        
        scrollView.setContentOffset(CGPoint.init(x: CGFloat(nextPage) * (self.pageWidth! + self.marginWidth!), y: 0), animated: true)
        userDidChangeViewAtIndex(atIndex: nextPage)
    }
    
    func moveTo(index: Int) {
        
        assert(index <= self.views!.count, "CarouselView out of bounds")
        assert(index >= 0, "CarouselView out of bounds")
        
        scrollView.setContentOffset(CGPoint.init(x: CGFloat(index) * (self.pageWidth! + self.marginWidth!), y: 0), animated: true)
        userDidChangeViewAtIndex(atIndex: index)
    }
    
    func setBackgroundColor(color: UIColor) {
        self.view.backgroundColor = color
    }
    
    // MARK: - Private Methods
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        
        let nib = UINib(nibName: "CarouselView", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    func initialize() {
        
        self.configureDataSource()
        
        self.scrollView.isPagingEnabled = self.pagingEnabled
        
        self.scrollView.delegate = self
        
        self.scrollView.contentSize = CGSize.init(width: (self.pageWidth! + self.marginWidth!) * CGFloat((self.views?.count)!), height: (self.viewSize?.height)!)
        
        self.centerXScrollViewConstraint.constant = -self.marginWidth! / 2
        
        self.widthScrollViewConstraint.constant = (self.pagingEnabled) ? self.pageWidth! + self.marginWidth! : (self.pageWidth! + self.marginWidth!) * CGFloat((self.views?.count)!)
        
        self.widthButtonsContainerConstraint.constant = self.pageWidth!
        
        self.heightScrollViewConstraint.constant = (self.viewSize?.height)!
        
        self.addSubviews()
        
        if (self.layerEnableSideViews)
        {
            self.applyLayerEnableViews()
        }
        
        if (self.atIndex > 0)
        {
            assert(self.atIndex <= self.views!.count, "index out of bounds")
            self.scrollView.setContentOffset(CGPoint.init(x: CGFloat(self.atIndex) * (self.pageWidth! + self.marginWidth!), y: 0), animated: true)
        }
        
        self.updateButtons(atIndex: self.atIndex)
        
        
        if (self.hasCollectionView)
        {
            let nib = UINib.init(nibName: "CarouselCollectionViewCell", bundle: nil)
            
            self.collectionView.register(nib, forCellWithReuseIdentifier: CarouselCollectionViewCell.reuseIdentifier())
            
            self.widthCollectionViewConstraint.constant = CGFloat(self.views!.count * 20)
            
            //Center collectionView according to number of views
            self.centerXCollectionViewConstraint.constant = (self.views!.count % 2 != 0) ? centerXCollectionViewConstraint.constant + 10.0 : centerXCollectionViewConstraint.constant
            
            print("centerX \(centerXCollectionViewConstraint.constant)")
            
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            
            self.collectionView.reloadData()
        }
        else
        {
            self.collectionView.removeFromSuperview()
            self.collectionContainerView.removeFromSuperview()
        }
    }
    
    func configureDataSource() {
        
        if self.dataSource == nil {
            return
        }
        
        self.views = self.dataSource?.viewsForCarouselView(carouselView: self)
        self.viewSize = self.dataSource?.sizeForViewForCarouselView(carouselView: self)
        self.marginWidth = self.dataSource?.marginWidthForCarouselView(carouselView: self)
        self.pageWidth = self.viewSize?.width
        
        if let i:Int = self.dataSource?.navigateToIndexForCarouselView!(carouselView: self) {
            self.atIndex =  i
        }
        else {
            self.atIndex = 0
        }
        
        var ashow:Bool = false
        
        if let show:Bool? = self.dataSource?.showButtonsForCarouselView?(carouselView: self)
        {
            ashow = show!
        }
        else {
            ashow = false
        }
        
        if !ashow {
            self.buttonsContainerView.removeFromSuperview()
        }
        
        if let pEnabled:Bool = self.dataSource?.pagingEnabledForCarouselView?(carouselView: self) {
            self.pagingEnabled = pEnabled
        }
        else {
            self.pagingEnabled = true
        }
        
        if let has:Bool = self.dataSource?.hasCollectionView?(carouselView: self) {
            self.hasCollectionView = has
        }
        else {
            self.hasCollectionView = false
        }
        
        if let layerEnable:Bool = self.dataSource?.layerEnableSideViews?(carouselView: self) {
            self.layerEnableSideViews = layerEnable
        }
        else {
            self.layerEnableSideViews = false
        }
        
        if let scrollEnable:Bool = self.dataSource?.scrollingIsEnable?(carouselView: self) {
            self.scrollView.isScrollEnabled = scrollEnable
        }
        else {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    func addSubviews() {
        
        for i in 0 ..< self.views!.count {
            
            let tapMainView: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleTap))
            
            let view: UIView = self.views![i]
            
            view.addGestureRecognizer(tapMainView)
            
            let containerView: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(view)
            
            self.scrollView.addSubview(containerView)
            
            
            let constraints: NSMutableArray = NSMutableArray.init()
            
            let metrics:[String:Any] = ["margin":Float(self.marginWidth!), "pageWidth":Float(self.pageWidth!), "pageHeight":Float((self.viewSize?.height)!)]
            
            if i == 0 {
                constraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[containerView(pageWidth)]", options: [], metrics: metrics, views: ["containerView":containerView]))
            }
            else {
                let previousView: UIView = self.views![i-1]
                let previousContainerView: UIView = previousView.superview!
                
                if i == self.views!.count - 1 {
                    constraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "H:[previousContainerView]-margin-[containerView(pageWidth)]|", options: [], metrics: metrics, views: ["previousContainerView":previousContainerView, "containerView":containerView]))
                }
                else {
                    constraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "H:[previousContainerView]-margin-[containerView(pageWidth)]", options: [], metrics: metrics, views: ["previousContainerView":previousContainerView, "containerView":containerView]))
                }
            }
            
            constraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView(pageHeight)]", options: [], metrics: metrics, views: ["containerView":containerView]))
            
            UIView.embedView(view: view)
            containerView.superview?.addConstraints(constraints as Array as! [NSLayoutConstraint])
        }
        self.layoutSubviews()
    }
    
    func userDidChangeViewAtIndex(atIndex: Int) {
        
        self.atIndex = atIndex
        
        if self.layerEnableSideViews {
            self.applyLayerEnableViews()
        }
        
        self.delegate?.userDidChangeViewAtIndex?(carousel: self, index: atIndex) // 👻if let
        
        updateButtons(atIndex: atIndex)
        
        if self.hasCollectionView {
            self.collectionView.reloadData()
        }
    }
    
    func updateButtons(atIndex: Int) {
        //        if atIndex > 0 {
        //            self.previousButton.isEnabled = (atIndex != 0)
        //            self.nextButton.isEnabled = (atIndex != self.views!.count - 1)
        //        }
    }
    
    func applyLayerEnableViews() {
        for i in 0 ..< self.views!.count {
            let view: UIView = self.views![i]
            view.alpha = (i == self.self.atIndex) ? 1.0 : 0.3
        }
    }
    
    // MARK: - DELEGATES
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        userDidChangeViewAtIndex(atIndex: currentPage!)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.views!.count > 10) ? 10 : self.views!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CarouselCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCollectionViewCell.reuseIdentifier(), for: indexPath) as! CarouselCollectionViewCell
        
        cell.circleView.layer.borderColor = UIColor.clear.cgColor
        cell.circleView.backgroundColor = (indexPath.row == self.atIndex) ? UIColor.red : UIColor.gray
        cell.circleView.cornerRadius = cell.circleView.height/2
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 10.0, height: 20.0)
    }
}
