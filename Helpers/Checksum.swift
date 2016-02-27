#!/usr/bin/swift


import Foundation



extension String {

    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a NSData object. Note, if the string has any spaces, those are removed. Also if the string started with a '<' or ended with a '>', those are removed, too. This does no validation of the string to ensure it's a valid hexadecimal string
    ///
    /// The use of `strtoul` inspired by Martin R at http://stackoverflow.com/a/26284562/1271826
    ///
    /// - returns: NSData represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range.

    func dataFromHexadecimalString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")

        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them

        let regex = try! NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive)

        let found = regex.firstMatchInString(trimmedString, options: [], range: NSMakeRange(0, trimmedString.characters.count))
        if found == nil || found?.range.location == NSNotFound || trimmedString.characters.count % 2 != 0 {
            return nil
        }

        // everything ok, so now let's build NSData

        let data = NSMutableData(capacity: trimmedString.characters.count / 2)

        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }

        return data
    }
}


func calculateChecksum(data: NSData) -> (UInt8, UInt8)
{
	let count = data.length;// / sizeof(UInt8)

	// create array of appropriate length:
	var array = [UInt8](count: count, repeatedValue: 0)

	// copy bytes into array
	data.getBytes(&array, length:count * sizeof(UInt8))

  	var ck_a: UInt8 = 0
	var ck_b: UInt8 = 0
  	for(var i = 0; i < count; ++i)
  	{
    	ck_a =  ck_a &+ array[i];
    	ck_b = ck_b &+ ck_a;
  	}

	return (ck_a, ck_b)
}

//print("Test")
//var a: UInt8 = 255
//a += 1
//print("Result: \(a)")

let input = Process.arguments[1]
print("Arg: \(input)")

let data = input.dataFromHexadecimalString()
let checksum = calculateChecksum(data!)

print("Checksum: (\(String(format:"%2X", checksum.0)),\(String(format:"%2X", checksum.1)))")
