//
//  ViewController.swift
//  JGCCarouselProof
//
//  Created by Javier Garcia Castro on 23/9/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var carouselContainerView: UIView!
    
    var carouselView: CarouselView?
    var elements: Array<UIView> = Array<UIView>.init()
    var indexSelected: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        indexSelected = 4
        initialize()
    }

    // MARK: - Private Methods
    
    func initialize() {
        
        for v in carouselContainerView.subviews {
            
            if v.isKind(of: NumberView.classForCoder()) {
                carouselView?.removeFromSuperview()
            }
        }
        
        carouselView = CarouselView.init(delegate: self, dataSource: self)
        carouselView?.setBackgroundColor(color: .white)
        
        carouselContainerView.addSubview(carouselView!)
        UIView.embedView(view: carouselView!)
        
        viewsForCarousel()
    }

    func viewsForCarousel() {
        elements = Array<UIView>()
        for i in 0..<10 {
            let numberView: NumberView = NumberView.loadNib()
            numberView.tag = i
            numberView.label.text = "\(i)"
            numberView.label.textColor = UIColor.gray
            
            if i == indexSelected {  numberView.setForCurrentView() }
            
            elements.append(numberView)
        }
    }
}

extension ViewController: CarouselViewDataSource, CarouselViewDelegate {

    // MARK: - CarouselViewDataSource
    
    func viewsForCarouselView(carouselView: CarouselView) -> [UIView] {
        return elements
    }
    
    func sizeForViewForCarouselView(carouselView: CarouselView) -> CGSize {
        return CGSize(width: 80.0, height: 80.0)
    }
    
    func marginWidthForCarouselView(carouselView: CarouselView) -> CGFloat {
        return 20.0
    }
    
    func navigateToIndexForCarouselView(carouselView: CarouselView) -> Int {
        return indexSelected
    }
    
    func hasCollectionView(carouselView: CarouselView) -> Bool {
        return true
    }
    
    // MARK: - CarouselViewDelegate
    
    func userDidChangeViewAtIndex(carousel: CarouselView, index: Int) {
        
        let view: NumberView = elements[index] as! NumberView
        let lastView: NumberView = elements[indexSelected] as! NumberView
        
        lastView.setForNotCurrentView()
        view.setForCurrentView()
        
        indexSelected = index
    }
    
    func layerEnableSideViews(carouselView: CarouselView) -> Bool {
        return true
    }
    
}


