//
//  GradientTabBar.swift
//  openBanking
//
//  Created by Rabah Zeineddine on 06/10/17.
//  Copyright © 2017 Rabah Zeineddine. All rights reserved.
//

import UIKit




@IBDesignable class GradientTabBar: UITabBar {
    
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    override func draw(_ rect: CGRect) {
        let layerGradient: CAGradientLayer = CAGradientLayer()
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = CGRect(x: CGFloat(0),
                                y: CGFloat(0),
                                width: superview!.frame.size.width,
                                height: superview!.frame.size.height)
        layerGradient.colors = [startColor.cgColor, endColor.cgColor]
        layerGradient.zPosition = -1
        layer.addSublayer(layerGradient)
        self.tintColor = .white
        
        
    }
    
}
