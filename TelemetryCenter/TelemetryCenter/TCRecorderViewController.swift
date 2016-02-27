//
//  TCRecorderViewController.swift
//  TelemetryCenter
//
//  Created by Benno Krauss on 24.01.16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

import Foundation
import UIKit

class TCRecorderViewController: UIViewController
{
	private var recorder: TCTrackRecorder
	@IBOutlet weak var statusLabel: TCStatusLabel!
	
	required init?(coder aDecoder: NSCoder)
	{
		recorder = TCTrackRecorder()
		
		super.init(coder: aDecoder)
	}
	
	
	@IBAction internal func toggleButtonTapped()
	{
		if (recorder.isRecording())
		{
			recorder.stopRecording()
			
			statusLabel.text = "Not recording"
		}
		else {
			do {
				try recorder.startRecording()
				statusLabel.text = "Recording..."
			}
			catch TCTrackRecorderError.FileCreationFailed {
				statusLabel.text = "Error: recording already exists"
			}
			catch TCTrackRecorderError.PacketInconsistency {
				statusLabel.text = "Error: packet inconsistent"
			}
			catch {
				statusLabel.text = "Error"
			}
		}
	}
	
	func packetReceived(p: BTPacket)
	{
		recorder.packetReceived(p)
	}
}