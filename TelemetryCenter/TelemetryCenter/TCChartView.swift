//
//  TCChartView.swift
//  TelemetryCenter
//
//  Created by Benno Krauss on 03/01/16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

import UIKit

@IBDesignable
class TCChartView: UIView
{
	private var path: UIBezierPath? {
		didSet {
//			let anim = CABasicAnimation(keyPath: "path")
//			anim.duration = 0.2
//			anim.removedOnCompletion = true
//			anim.toValue = path?.CGPath ?? nil
//			self.layer.addAnimation(anim, forKey: "path animation")
			self.layer.path = path?.CGPath ?? nil
		}
	}
	
	internal var dataPoints: [(CGFloat, CGFloat)] = [] {
		didSet {
			setNeedsLayout()
		}
	}
	
	@IBInspectable internal var strokeColor: UIColor? {
		didSet {
			self.layer.strokeColor = strokeColor?.CGColor
		}
	}
	
	@IBInspectable internal var lineWidth: CGFloat? {
		didSet {
			self.layer.lineWidth = lineWidth!
		}
	}
	
	private func commonInit()
	{
		self.layer.lineWidth = 3
		self.layer.strokeColor = UIColor.redColor().CGColor
		self.layer.fillColor = nil
		self.layer.masksToBounds = true
	}
	
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		commonInit()
	}
	
	override class func layerClass() -> AnyClass {
		return CAShapeLayer.self
	}
	
	override internal var layer: CAShapeLayer {
		get {
			return super.layer as! CAShapeLayer
		}
	}
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		if (dataPoints.count <= 1) {
			return
		}
		
		let maxY = dataPoints.sort { ( p1: (CGFloat, CGFloat), p2: (CGFloat, CGFloat)) -> Bool in
			return p1.1 > p2.1
		}[0].1
		
		let maxX = dataPoints.sort { ( p1: (CGFloat, CGFloat), p2: (CGFloat, CGFloat)) -> Bool in
			return p1.0 > p2.0
		}[0].0
		
		let minX = dataPoints.sort { ( p1: (CGFloat, CGFloat), p2: (CGFloat, CGFloat)) -> Bool in
			return p1.0 < p2.0
		}[0].0
		
		let path = UIBezierPath()
		
		let graphFrame = CGRectInset(frame, 0, 12)
		
		let xRange = maxX - minX
		let yRange = maxY
		
		let xFactor = graphFrame.size.width / xRange
		let yFactor = graphFrame.size.height / yRange
		
		var cp1: CGPoint
		var cp2: CGPoint
		
		var p0: CGPoint
		var p1: CGPoint
		var p2: CGPoint
		var p3: CGPoint
		var tensionBezier1: CGFloat = 0.3;
		var tensionBezier2: CGFloat = 0.3;
		
		var previousPoint1: CGPoint = CGPointZero
		var previousPoint2: CGPoint
		
		func viewPoint(point: (CGFloat, CGFloat)) -> CGPoint
		{
			return CGPointMake((point.0 - minX) * xFactor,graphFrame.size.height - point.1 * yFactor)
		}
		
		path.moveToPoint(viewPoint(dataPoints[0]))
		
		for (index, point) in dataPoints.enumerate()
		{
			let viewPoint = viewPoint(point)
			if index == 0 {
				path.moveToPoint(viewPoint)
			}
			else {
				path.addLineToPoint(viewPoint)
			}
		}
//		for (var i = 0; i < dataPoints.count - 1; i++)
//		{
//			p1 = viewPoint(dataPoints[i])
//			p2 = viewPoint(dataPoints[i+1])
//			
//			let maxTension: CGFloat = 1.0 / 3.0;
//			tensionBezier1 = CGFloat(maxTension)
//			tensionBezier2 = CGFloat(maxTension)
//			
//			if i > 0 {
//				p0 = previousPoint1
//				if (p2.y - p1.y == p1.y - p0.y) {
//					tensionBezier1 = 0
//				}
//			}
//			else {
//				tensionBezier1 = 0
//				p0 = p1
//			}
//			
//			if i < dataPoints.count - 2
//			{
//				p3 = viewPoint(dataPoints[i + 2])
//				if (p3.y - p2.y == p2.y - p1.y)
//				{
//					tensionBezier2 = 0
//				}
//			}
//			else {
//				p3 = p2
//				tensionBezier2 = 0
//			}
//			
//			// The tension should never exceed 0.3
//			if (tensionBezier1 > maxTension) {
//				tensionBezier1 = maxTension
//			}
//			if (tensionBezier2 > maxTension) {
//				tensionBezier2 = maxTension
//			}
//			
//			// First control point
//			let Xcp1 = p1.x + (p2.x - p1.x)/3
//			let Ycp1 = p1.y - (p1.y - p2.y)/3 - (p0.y - p1.y)*tensionBezier1
//			cp1 = CGPointMake(Xcp1, Ycp1)
//			
//			// Second control point
//			let Xcp2 = p1.x + 2*(p2.x - p1.x)/3
//			let Ycp2 = (p1.y - 2*(p1.y - p2.y)/3) + (p2.y - p3.y)*tensionBezier2
//			cp2 = CGPointMake(Xcp2,Ycp2);
//			
//			path.addCurveToPoint(p2, controlPoint1:cp1, controlPoint2:cp2);
//			
//			previousPoint1 = p1;
//			previousPoint2 = p2;
//		}
		
		self.path = path
	}
	
	override func prepareForInterfaceBuilder() {
		dataPoints = [
			(-1, 0),
			(1,1),
			(2,1),
			(3,3),
			(4,1),
			(5,4)
		]
		layoutSubviews()
	}
}



















