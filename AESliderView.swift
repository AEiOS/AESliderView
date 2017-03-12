//
//  AESliderView.swift
//
//  Created by AirEDoctor on 11/03/2017.
//  Copyright © 2017 AirEDoctor. All rights reserved.
//

import UIKit

@objc protocol AESliderViewDelegate {
    func numberOfViews(in sliderView: AESliderView) -> Int;
    func sliderView(_ sliderView: AESliderView,viewAtIndex index: Int) -> UIView;
}

class AESliderView: UIView, UIScrollViewDelegate {

    private let contentView = UIScrollView()
    private var viewIndex = 0
    private var currentView: UIView?
    private var successorView: UIView?
    var delegate: AESliderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.black
        
        contentView.delegate = self
        contentView.bounces = false
        contentView.isPagingEnabled = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.showsHorizontalScrollIndicator = false
        addSubview(contentView)
        addConstraint(NSLayoutConstraint(item:contentView, attribute:.leading, relatedBy:.equal, toItem:self, attribute:.leading, multiplier:1.0, constant:0.0))
        addConstraint(NSLayoutConstraint(item:contentView, attribute:.trailing, relatedBy:.equal, toItem:self, attribute:.trailing, multiplier:1.0, constant:0.0))
        addConstraint(NSLayoutConstraint(item:contentView, attribute:.top, relatedBy:.equal, toItem:self, attribute:.top, multiplier:1.0, constant:0.0))
        addConstraint(NSLayoutConstraint(item:contentView, attribute:.bottom, relatedBy:.equal, toItem:self, attribute:.bottom, multiplier:1.0, constant:0.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width
        if currentView == nil {
            if let view = self.delegate?.sliderView(self, viewAtIndex: viewIndex) {
                currentView = view
                var frame = bounds
                frame.origin.x = width
                view.frame = frame
                contentView.addSubview(view)
            }
        }
        
        
        contentView.contentSize = CGSize(width: width * 3.0, height: 0.0)
        contentView.contentOffset = CGPoint(x: width, y: 0.0)
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = bounds.width
        let offsetX = scrollView.contentOffset.x
        var shouldAddOrChangSuccessorView = false
        if let view = successorView {
            shouldAddOrChangSuccessorView = view.frame.midX < width
        }
        else {
            shouldAddOrChangSuccessorView = true
        }
        
        if shouldAddOrChangSuccessorView {
            if offsetX < width { // slide left
                if let view = delegate?.sliderView(self, viewAtIndex: successorViewIndex(true)) {
                    view.frame = bounds
                    contentView.addSubview(view)
                    
                    successorView = view
                }
            }
            else if offsetX > width { // slide right
                if let view = delegate?.sliderView(self, viewAtIndex: successorViewIndex(false)) {
                    var frame = bounds
                    frame.origin.x = width * 2.0
                    view.frame = frame
                    contentView.addSubview(view)
                    
                    successorView = view
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let width = bounds.width
        if abs(offsetX - width) > 1.0 {
            if let numberOfViews = delegate?.numberOfViews(in: self) {
                if offsetX < width {
                    viewIndex -= 1
                    if viewIndex < 0 {
                        viewIndex = numberOfViews - 1
                    }
                }
                else {
                    viewIndex += 1
                    if viewIndex >= numberOfViews {
                        viewIndex = 0
                    }
                }
            }
            
            scrollView.contentOffset = CGPoint(x: width, y: 0.0)
            var frame = bounds
            frame.origin.x = width
            successorView?.frame = frame
            
            currentView?.removeFromSuperview()
            currentView = successorView
        }
        successorView = nil
    }
    
    
    // MARK: private
    
    private func successorViewIndex(_ isSlidingLeft: Bool) -> Int {
        if let numberOfViews = delegate?.numberOfViews(in: self) {
            let maxIndex = numberOfViews - 1
            if isSlidingLeft {
                return viewIndex >= maxIndex ? 0 : viewIndex + 1
            }
            else {
                return viewIndex <= 0 ? maxIndex : viewIndex - 1
            }
        }
        
        return 0;
    }
    

}
