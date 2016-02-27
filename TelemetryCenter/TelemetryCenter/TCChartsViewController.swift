//
//  TCStatusViewController.swift
//  TelemetryCenter
//
//  Created by Benno Krauss on 02/01/16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

import Foundation
import SwiftCharts

@objc class TCChartsViewController: UIViewController
{
	var values: [BTPacket]
	
	@IBOutlet weak var speedChartView: TCChartView!
	@IBOutlet weak var hdopChartView: TCChartView!
	@IBOutlet weak var altChartView: TCChartView!
	
	@IBOutlet weak var hdopChartContainerView: UIStackView!
	@IBOutlet weak var hdopChartSeparatorView: UIView!
	
	required init?(coder aDecoder: NSCoder)
	{
		values = []
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.whiteColor()
		updateViewLayout()
		
		render()
	}
	
	internal func packetReceived(p: BTPacket)
	{
		if (values.count > 0 && (p.time == values.last!.time || p.time == 0)) {
			return;
		}
		NSLog("ChartsVC: received t=%u y=%.2f",p.time,p.speed)
		values.append(p)
		
		render()
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		render()
	}
	
	var speedGraph: Chart?
	
	private func render()
	{
		if (values.count < 2)
		{
			return
		}
		
		var packet = values.last!
		let latestTimeSeconds = BTPacketGetTimeCentiseconds(&packet)
		
		let valuesToDisplay: [BTPacket] = values.filter { (p: BTPacket) -> Bool in
			var pp = p
			let totalSeconds = BTPacketGetTimeCentiseconds(&pp)
			return latestTimeSeconds - totalSeconds < 2000
		}
		
		var speedChartPoints: [(CGFloat, CGFloat)] = []
		for p in valuesToDisplay
		{
			var pp = p
			let point = (CGFloat((CGFloat(BTPacketGetTimeCentiseconds(&pp)) - (CGFloat(latestTimeSeconds) * 100.0) + 2000.0) / 100.0), CGFloat(p.speed));
			speedChartPoints.append(point)
		}
		
		var hdopChartPoints: [(CGFloat, CGFloat)] = []
		for p in valuesToDisplay
		{
			var pp = p
			let point = (CGFloat((CGFloat(BTPacketGetTimeCentiseconds(&pp)) - (CGFloat(latestTimeSeconds) * 100.0) + 2000.0) / 100.0), CGFloat(p.hdop));
			hdopChartPoints.append(point)
		}
		
		var altChartPoints: [(CGFloat, CGFloat)] = []
		for p in valuesToDisplay
		{
			var pp = p
			let point = (CGFloat((CGFloat(BTPacketGetTimeCentiseconds(&pp)) - (CGFloat(latestTimeSeconds) * 100.0) + 2000.0) / 100.0), CGFloat(p.altitude - 350.0));
			altChartPoints.append(point)
		}

		//print("points: \( speedChartPoints )")
		
		speedChartView.dataPoints = speedChartPoints
		hdopChartView.dataPoints = hdopChartPoints
		altChartView.dataPoints = altChartPoints

	}
	
	override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateViewLayout()
		
	}
	
	private func updateViewLayout(){
		print("updateViewLayout")
		hdopChartContainerView.hidden = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact
		hdopChartSeparatorView.hidden = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact
	}
}