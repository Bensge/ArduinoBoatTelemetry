//
//  TCTrackRecorder.swift
//  TelemetryCenter
//
//  Created by Benno Krauss on 07.01.16.
//  Copyright © 2016 Benno Krauss. All rights reserved.
//

import Foundation

enum TCTrackRecorderError : ErrorType {
	case RecordingAlreadyExists
	case FileCreationFailed
	case FileWritingFailed
	case PacketInconsistency
}

class TCTrackRecorder
{
	private var recording = false
	private var file: NSFileHandle?
	
	func isRecording() -> Bool
	{
		return recording
	}
	
	func startRecording() throws
	{
		recording = true;
		
		let f = NSDateFormatter()
		f.dateFormat = "yyyy_MM_dd-HH-mm-ss";
		let recordingName = f.stringFromDate(NSDate()) + ".trk"
		let filePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] + "/" + recordingName
		
		if !NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
		{
			throw TCTrackRecorderError.FileCreationFailed
		}
		
		guard let unwrappedFile = NSFileHandle(forWritingAtPath: filePath) else {
			throw TCTrackRecorderError.FileCreationFailed
		}
		file = unwrappedFile
		
		try saveHeader()
	}
	
	private func saveHeader() throws
	{
		if sizeof(BTPacket) != 44
		{
			throw TCTrackRecorderError.PacketInconsistency
		}
		let header = "numberOfSatellites;time;speed;longitude;latitude;altitude;hdop;course;temperature;mainVoltage;arduinoVoltage";
		
		writeLine(header)
	}
	
	private func writeLine(s: String!)
	{
		file?.writeData((s + "\n").dataUsingEncoding(NSUTF8StringEncoding)!)
	}
	
	func stopRecording()
	{
		if recording
		{
			file!.synchronizeFile()
			file!.closeFile()
			file = nil
			
			recording = false;
		}
	}
	
	func packetReceived(p: BTPacket)
	{
		if recording {
			let data = String(format: "%u;%u;%f;%f;%f;%f;%i;%f;%f;%f;%f",p.numberOfSatellites,p.time,p.speed,p.longitude,p.latitude,p.altitude,p.hdop,p.course,p.temperature,p.mainVoltage,p.arduinoVoltage);
			writeLine(data)
		}
	}
}