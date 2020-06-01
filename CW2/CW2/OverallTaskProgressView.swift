//
//  OverallTaskProgressView.swift
//  CW2
//
//  Created by Guest 1 on 01/06/2020.
//  Copyright © 2020 Adam Ayub. All rights reserved.
//

import UIKit

class OverallTaskProgressView: UIView {
    
    // REFERENCED FROM https://www.youtube.com/watch?v=Qh1Sxict3io&t=697s
    
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    var progressColour = UIColor.green {
        didSet {
            progressLayer.strokeColor = progressColour.cgColor
        }
    }
    
    var trackColor = UIColor.red {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    
    
    func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/3
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/3, y: frame.size.height/2), radius: (frame.size.width - 1.5)/3, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColour.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.4
        layer.addSublayer(progressLayer)
        
    }
    
    func setProgressAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
}
