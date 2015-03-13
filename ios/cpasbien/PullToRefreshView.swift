//
//  @interface INSDefaultPullToRefresh : UIView <INSPullToRefreshBackgroundViewDelegate>  - (instancetype)initWithFrame:(CGRect)frame backImage:(UIImage *)backCircleImage frontImage:(UIImage *)frontCircleImage;  PullToRefreshView.swift
//  cpasbien
//
//  Created by David Tisserand on 06/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import INSPullToRefresh

class PullToRefreshView: UIView, INSPullToRefreshBackgroundViewDelegate {
    private var backCircleLayer: CAShapeLayer!
    private var frontCircleLayer: CAShapeLayer!
    private var pieLayer: CAShapeLayer!
    private var activityIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let color = UINavigationBar.appearance().barTintColor {
            self.tintColor = color
        }

        self.backCircleLayer = self.circleShapeLayer(24.0, lineWidth: 2.0, color: self.tintColor.lighterColor())
        self.frontCircleLayer = self.circleShapeLayer(24.0, lineWidth: 3.0, color: self.tintColor)
        self.pieLayer = CAShapeLayer()

        self.layer.addSublayer(self.backCircleLayer)
        self.layer.addSublayer(self.frontCircleLayer)
        self.layer.addSublayer(self.pieLayer)

        self.frontCircleLayer.mask = self.pieLayer;

        self.activityIndicator = UIActivityIndicatorView(frame: frame)
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.activityIndicator.hidden = true
        self.addSubview(self.activityIndicator)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let v = self.superview {
            self.center = CGPoint(x: CGRectGetMidX(v.bounds), y: CGRectGetMidY(v.bounds))
        }
        
        self.backCircleLayer.frame = self.bounds
        self.frontCircleLayer.frame = self.bounds
        self.pieLayer.frame = self.bounds
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func circleShapeLayer(radius: Float, lineWidth: Float, color: UIColor) -> CAShapeLayer {
        let path = UIBezierPath()
        path.addArcWithCenter(CGPoint(x: CGFloat(radius), y: CGFloat(radius)), radius: CGFloat(radius), startAngle: 0.0, endAngle: CGFloat(M_PI_2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: CGRectInset(self.bounds, 1.0, 1.0)).CGPath
        shapeLayer.strokeColor = color.CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.lineWidth = CGFloat(lineWidth)
        shapeLayer.shouldRasterize = true
        shapeLayer.rasterizationScale = UIScreen.mainScreen().scale * 2.0
        
        return shapeLayer
    }
    
    private func updatePie(layer: CAShapeLayer, forAngle degrees:CGFloat) {
        let angle: CGFloat = -90 * (CGFloat(M_PI) / 180.0);
        let center_: CGPoint = CGPointMake(CGRectGetWidth(layer.frame)/2.0, CGRectGetWidth(layer.frame)/2.0);
        let radius: CGFloat = CGRectGetWidth(layer.frame)/2.0;
        
        let piePath: UIBezierPath = UIBezierPath()
        piePath.moveToPoint(center_)
        piePath.addLineToPoint(CGPoint(x: center_.x, y: center_.y - radius))
        let endAngle: CGFloat = (degrees - 90.0) * (CGFloat(M_PI) / 180.0)
        piePath.addArcWithCenter(center_, radius: radius, startAngle: angle, endAngle: endAngle, clockwise: true)
        
        piePath.addLineToPoint(center_)
        piePath.closePath()
        
        layer.path = piePath.CGPath;
    }
    
    private func handleProgress(progress: CGFloat, forState state: INSPullToRefreshBackgroundViewState) {
        if progress > 0 && state == INSPullToRefreshBackgroundViewState.None {
            self.frontCircleLayer.hidden = false
            self.backCircleLayer.hidden = false
            self.pieLayer.hidden = false
        }
    
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.updatePie(self.pieLayer, forAngle:progress * 360.0)
        self.frontCircleLayer.mask = self.pieLayer
        CATransaction.commit()
    }

    private func handleStateChange(state: INSPullToRefreshBackgroundViewState) {
        if state == INSPullToRefreshBackgroundViewState.None {
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.activityIndicator.alpha = 0.0
                }, completion: nil)
            self.updatePie(self.pieLayer, forAngle: 0.0)
            self.frontCircleLayer.mask = self.pieLayer
        }
        else {
            self.frontCircleLayer.hidden = true
            self.backCircleLayer.hidden = true
            self.pieLayer.hidden = true
            self.activityIndicator.alpha = 1.0
            self.activityIndicator.startAnimating()
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - INSPullToRefreshBackgroundViewDelegate
    // -------------------------------------------------------------------------
    func pullToRefreshBackgroundView(pullToRefreshBackgroundView: INSPullToRefreshBackgroundView!, didChangeState state: INSPullToRefreshBackgroundViewState) {
        
        self.handleStateChange(state)
    }
    
    func pullToRefreshBackgroundView(pullToRefreshBackgroundView: INSPullToRefreshBackgroundView!, didChangeTriggerStateProgress progress: CGFloat) {
        
        self.handleProgress(progress, forState: pullToRefreshBackgroundView.state)
    }
}
