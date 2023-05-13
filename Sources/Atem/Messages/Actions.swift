//
//  MessageTypes.swift
//  Atem
//
//  Created by Damiaan on 26/05/18.
//

extension Message.Do {
	/// Performs a cut on the atem
	public struct Cut: SerializableMessage {
		public static let title = Message.Title(string: "DCut")
		public let debugDescription = "cut"
		public let atemSize: AtemSize

		public init(with bytes: ArraySlice<UInt8>) {
			atemSize = AtemSize(rawValue: bytes.first!)!
		}

		public init(in atemSize: AtemSize) {
			self.atemSize = atemSize
		}

		public var dataBytes: [UInt8] {
			return [atemSize.rawValue] + [0,0,0]
		}
	}
}

extension Message.Do {
	/// Performs a auto transition on the atem
	public struct Auto: SerializableMessage {
		public static let title = Message.Title(string: "DAut")
		public let debugDescription = "auto"
		public let atemSize: AtemSize

		public init(with bytes: ArraySlice<UInt8>) {
			atemSize = AtemSize(rawValue: bytes.first!)!
		}

		public init(in atemSize: AtemSize) {
			self.atemSize = atemSize
		}

		public var dataBytes: [UInt8] {
			return [atemSize.rawValue] + [0,0,0]
		}
	}
}

public struct FairlightAudioMixOption: OptionSet, SingleValueDescribable {

	public let rawValue: UInt8



	public init(rawValue: UInt8) {

	self.rawValue = rawValue

	}



	public static let off = Self(rawValue: 1 << 0)

	public static let on = Self(rawValue: 1 << 1)

	public static let audioFollowVideo = Self(rawValue: 1 << 2)

	

	public func describe() -> String? {

	switch self {

	case .off:	return "off"

	case .on:	return "on"

	case .audioFollowVideo: return "audioFollowVideo"

	default:       	return "Unknown"

	}

	}

}

extension Message.Do {

	/// Informs a switcher that the settings for an audio source should be changed

	public struct ChangeFairlightMixerSource: SerializableMessage {

	public static let title = Message.Title(string: "CFSP")



	public let changedElements: ChangeMask

	public let index: AudioSource

	public let sourceId: Int64

	public let framesDelay: UInt8

	public let gain: Int32

	public let stereoSimulation: Int16

	public let equalizerEnabled: Bool

	public let equalizerGain: Int32

	public let makeUpGain: Int32

	public let balance: Int16

	public let faderGain: Int32

	public let mixOption: FairlightAudioMixOption

	



	public init(with bytes: ArraySlice<UInt8>) throws {

	self.changedElements = ChangeMask(rawValue: UInt16(from: bytes[relative: Position.changedElements]))

	self.index = AudioSource(rawValue: UInt16(from: bytes[relative: Position.index]))

	self.sourceId = Int64(from: bytes[relative: Position.sourceId])

	self.framesDelay = bytes[relative: Position.framesDelay]

	self.gain = Int32(from: bytes[relative: Position.gain])

	self.stereoSimulation = Int16(from: bytes[relative: Position.stereoSimulation])

	self.equalizerEnabled = bytes[relative: Position.equalizerEnabled].firstBit

	self.equalizerGain = Int32(from: bytes[relative: Position.equalizerGain])

	self.makeUpGain = Int32(from: bytes[relative: Position.makeUpGain])

	self.balance = Int16(from: bytes[relative: Position.balance])

	self.faderGain = Int32(from: bytes[relative: Position.faderGain])

	self.mixOption = FairlightAudioMixOption(rawValue: bytes[relative: Position.mixOption])

	}



	public init(changedElements: ChangeMask, index: AudioSource, sourceId: Int64, framesDelay: UInt8, gain: Int32, stereoSimulation: Int16, equalizerEnabled: Bool, equalizerGain: Int32, makeUpGain: Int32, balance: Int16, faderGain: Int32, mixOption: FairlightAudioMixOption) {

	self.changedElements = changedElements

	self.index = index

	self.sourceId = sourceId

	self.framesDelay = framesDelay

	self.gain = gain

	self.stereoSimulation = stereoSimulation

	self.equalizerEnabled = equalizerEnabled

	self.equalizerGain = equalizerGain

	self.makeUpGain = makeUpGain

	self.balance = balance

	self.faderGain = faderGain

	self.mixOption = mixOption

	}



	public var dataBytes: [UInt8] {

	.init(unsafeUninitializedCapacity: 48) { (buffer, count) in

	buffer.write(changedElements.rawValue.bigEndian, at: Position.changedElements.lowerBound)

	buffer.write(index.rawValue.bigEndian, at: Position.index.lowerBound)

	buffer.write(sourceId.bigEndian, at: Position.sourceId.lowerBound)

	

	if changedElements.contains(.framesDelay) {

	buffer[Position.framesDelay] = framesDelay

	}

	

	if changedElements.contains(.gain) {

	buffer.write(gain.bigEndian, at: Position.gain.lowerBound)

	}

	

	if changedElements.contains(.stereoSimulation) {

	buffer.write(stereoSimulation.bigEndian, at: Position.stereoSimulation.lowerBound)

	}

	

	if changedElements.contains(.equalizerEnabled) {

	buffer[Position.equalizerEnabled] = equalizerEnabled ? 1 : 0

	}

	

	if changedElements.contains(.equalizerGain) {

	buffer.write(equalizerGain.bigEndian, at: Position.equalizerGain.lowerBound)

	}

	

	if changedElements.contains(.makeUpGain) {

	buffer.write(makeUpGain.bigEndian, at: Position.makeUpGain.lowerBound)

	}

	

	if changedElements.contains(.balance) {

	buffer.write(balance.bigEndian, at: Position.balance.lowerBound)

	}

	

	if changedElements.contains(.faderGain) {

	buffer.write(faderGain.bigEndian, at: Position.faderGain.lowerBound)

	}

	

	if changedElements.contains(.mixOption) {

	buffer[Position.mixOption] = mixOption.rawValue

	}

	

	count = 48

	}

	}



	public var debugDescription: String { return """

Do.ChangeFairlightMixerSource {

	changedElements: \(changedElements),

	index: \(index),

	sourceId: \(sourceId),

	framesDelay: \(framesDelay),

	gain: \(gain),

	stereoSimulation: \(stereoSimulation),

	equalizerEnabled: \(equalizerEnabled),

	equalizerGain: \(equalizerGain),

	makeUpGain: \(makeUpGain),

	balance: \(balance),

	faderGain: \(faderGain),

	mixOption: \(mixOption)

}

"""

	}

	

	enum Position {

	static let changedElements = 0..<2

	static let index = 2..<4

	static let sourceId = 8..<16

	static let framesDelay = 16

	static let gain = 20..<24

	static let stereoSimulation = 24..<26

	static let equalizerEnabled = 26

	static let equalizerGain = 28..<32

	static let makeUpGain = 32..<36

	static let balance = 36..<38

	static let faderGain = 40..<44

	static let mixOption = 44

	}

	

	public struct ChangeMask: OptionSet {

	public let rawValue: UInt16



	public init(rawValue: UInt16) {

	self.rawValue = rawValue

	}



	public static let framesDelay = Self(rawValue: 1 << 0)

	public static let framesDelayOff = Self(rawValue: 0 << 0)

	public static let gain = Self(rawValue: 1 << 1)

	public static let gainOff = Self(rawValue: 0 << 1)

	public static let stereoSimulation = Self(rawValue: 1 << 2)

	public static let stereoSimulationOff = Self(rawValue: 0 << 2)

	public static let equalizerEnabled = Self(rawValue: 1 << 3)

	public static let equalizerEnabledOff = Self(rawValue: 0 << 3)

	public static let equalizerGain = Self(rawValue: 1 << 4)

	public static let equalizerGainOff = Self(rawValue: 0 << 4)

	public static let makeUpGain = Self(rawValue: 1 << 5)

	public static let makeUpGainOff = Self(rawValue: 0 << 5)

	public static let balance = Self(rawValue: 1 << 6)

	public static let balanceOff = Self(rawValue: 0 << 6)

	public static let faderGain = Self(rawValue: 1 << 7)

	public static let faderGainOff = Self(rawValue: 0 << 7)

	public static let mixOption = Self(rawValue: 1 << 8)

	public static let mixOptionOff = Self(rawValue: 0 << 8)

	public static let max = Self(rawValue: UInt16.max)

	}

	}

}

public enum AudioSource: RawRepresentable {

	public typealias RawValue = UInt16

	

	case input1

	case input2

	case input3

	case input4

	case input5

	case input6

	case input7

	case input8

	case input9

	case input10

	case input11

	case input12

	case input13

	case input14

	case input15

	case input16

	case input17

	case input18

	case input19

	case input20

	case input21

	case input22

	case input23

	case input24

	case input25

	case input26

	case input27

	case input28

	case input29

	case input30

	case input31

	case input32

	case input33

	case input34

	case input35

	case input36

	case input37

	case input38

	case input39

	case input40

	case xlr

	case aesbu

	case rca

	case mic1

	case mic2

	case mp1

	case mp2

	case mp3

	case mp4

	case trs(UInt16)

	case madi(UInt16)

	case madiEnd

	case unknown(UInt16)

	

	public init(rawValue: UInt16) {

	switch rawValue {

	case Base.input1.rawValue:

	self = .input1

	case Base.input2.rawValue:

	self = .input2

	case Base.input3.rawValue:

	self = .input3

	case Base.input4.rawValue:

	self = .input4

	case Base.input5.rawValue:

	self = .input5

	case Base.input6.rawValue:

	self = .input6

	case Base.input7.rawValue:

	self = .input7

	case Base.input8.rawValue:

	self = .input8

	case Base.input9.rawValue:

	self = .input9

	case Base.input10.rawValue:

	self = .input10

	case Base.input11.rawValue:

	self = .input11

	case Base.input12.rawValue:

	self = .input12

	case Base.input13.rawValue:

	self = .input13

	case Base.input14.rawValue:

	self = .input14

	case Base.input15.rawValue:

	self = .input15

	case Base.input16.rawValue:

	self = .input16

	case Base.input17.rawValue:

	self = .input17

	case Base.input18.rawValue:

	self = .input18

	case Base.input19.rawValue:

	self = .input19

	case Base.input20.rawValue:

	self = .input20

	case Base.input21.rawValue:

	self = .input21

	case Base.input22.rawValue:

	self = .input22

	case Base.input23.rawValue:

	self = .input23

	case Base.input24.rawValue:

	self = .input24

	case Base.input25.rawValue:

	self = .input25

	case Base.input26.rawValue:

	self = .input26

	case Base.input27.rawValue:

	self = .input27

	case Base.input28.rawValue:

	self = .input28

	case Base.input29.rawValue:

	self = .input29

	case Base.input30.rawValue:

	self = .input30

	case Base.input31.rawValue:

	self = .input31

	case Base.input32.rawValue:

	self = .input32

	case Base.input33.rawValue:

	self = .input33

	case Base.input34.rawValue:

	self = .input34

	case Base.input35.rawValue:

	self = .input35

	case Base.input36.rawValue:

	self = .input36

	case Base.input37.rawValue:

	self = .input37

	case Base.input38.rawValue:

	self = .input38

	case Base.input39.rawValue:

	self = .input39

	case Base.input40.rawValue:

	self = .input40

	case Base.xlr.rawValue:

	self = .xlr

	case Base.aesbu.rawValue:

	self = .aesbu

	case Base.rca.rawValue:

	self = .rca

	case Base.mic1.rawValue:

	self = .mic1

	case Base.mic2.rawValue:

	self = .mic2

	case Base.mp1.rawValue:

	self = .mp1

	case Base.mp2.rawValue:

	self = .mp2

	case Base.mp3.rawValue:

	self = .mp3

	case Base.mp4.rawValue:

	self = .mp4

	case .trs ..< .madi:

	self = .trs(rawValue - .trs)

	case .madi ..< .madiEnd:

	self = .madi(rawValue - .madi)

	case Base.madiEnd.rawValue:

	self = .madiEnd

	

	default:

	self = .unknown(rawValue)

	}

	}

	

	public var rawValue: UInt16 {

	switch self {

	case .input1:	return .input1 + 0

	case .input2:	return .input2 + 0

	case .input3:	return .input3 + 0

	case .input4:	return .input4 + 0

	case .input5:	return .input5 + 0

	case .input6:	return .input6 + 0

	case .input7:	return .input7 + 0

	case .input8:	return .input8 + 0

	case .input9:	return .input9 + 0

	case .input10:	return .input10 + 0

	case .input11:	return .input11 + 0

	case .input12:	return .input12 + 0

	case .input13:	return .input13 + 0

	case .input14:	return .input14 + 0

	case .input15:	return .input15 + 0

	case .input16:	return .input16 + 0

	case .input17:	return .input17 + 0

	case .input18:	return .input18 + 0

	case .input19:	return .input19 + 0

	case .input20:	return .input20 + 0

	case .input21:	return .input21 + 0

	case .input22:	return .input22 + 0

	case .input23:	return .input23 + 0

	case .input24:	return .input24 + 0

	case .input25:	return .input25 + 0

	case .input26:	return .input26 + 0

	case .input27:	return .input27 + 0

	case .input28:	return .input28 + 0

	case .input29:	return .input29 + 0

	case .input30:	return .input30 + 0

	case .input31:	return .input31 + 0

	case .input32:	return .input32 + 0

	case .input33:	return .input33 + 0

	case .input34:	return .input34 + 0

	case .input35:	return .input35 + 0

	case .input36:	return .input36 + 0

	case .input37:	return .input37 + 0

	case .input38:	return .input38 + 0

	case .input39:	return .input39 + 0

	case .input40:	return .input40 + 0

	case .xlr:	return .xlr + 0

	case .aesbu:	return .aesbu + 0

	case .rca:	return .rca + 0

	case .mic1:	return .mic1 + 0

	case .mic2:	return .mic2 + 0

	case .mp1:	return .mp1 + 0

	case .mp2:	return .mp2 + 0

	case .mp3:	return .mp3 + 0

	case .mp4:	return .mp4 + 0

	case .trs(let number):	return .trs + number

	case .madi(let number): return .madi + number

	case .madiEnd:	return .madiEnd + 0

	case .unknown(let rawValue):	return rawValue

	}

	}

	

	enum Base: UInt16 {

	case input1 = 1

	case input2 = 2

	case input3 = 3

	case input4 = 4

	case input5 = 5

	case input6 = 6

	case input7 = 7

	case input8 = 8

	case input9 = 9

	case input10 = 10

	case input11 = 11

	case input12 = 12

	case input13 = 13

	case input14 = 14

	case input15 = 15

	case input16 = 16

	case input17 = 17

	case input18 = 18

	case input19 = 19

	case input20 = 20

	case input21 = 21

	case input22 = 22

	case input23 = 23

	case input24 = 24

	case input25 = 25

	case input26 = 26

	case input27 = 27

	case input28 = 28

	case input29 = 29

	case input30 = 30

	case input31 = 31

	case input32 = 32

	case input33 = 33

	case input34 = 34

	case input35 = 35

	case input36 = 36

	case input37 = 37

	case input38 = 38

	case input39 = 39

	case input40 = 40

	case xlr = 1001

	case aesbu = 1101

	case rca = 1201

	case mic1 = 1301

	case mic2 = 1302

	case mp1 = 2001

	case mp2 = 2002

	case mp3 = 2003

	case mp4 = 2004

	case trs = 1400

	case madi = 1500

	case madiEnd = 1600

	

	static func + (left: Base, right: RawValue) -> RawValue {

	return left.rawValue + right

	}

	

	static func - (left: RawValue, right: Base) -> RawValue {

	return left - right.rawValue

	}

	

	static func ..< (lower: Base, upper: Base) -> CountableRange<RawValue> {

	return lower.rawValue ..< upper.rawValue

	}

	}

	

	public var videoSource: VideoSource? {

	if self.rawValue <= 40 {

	return VideoSource(rawValue: self.rawValue)

	

	} else {

	switch self {

	case .mp1:

	return VideoSource.mediaPlayer(0)

	case .mp2:

	return VideoSource.mediaPlayer(1)

	case .mp3:

	return VideoSource.mediaPlayer(2)

	case .mp4:

	return VideoSource.mediaPlayer(3)

	default:

	return nil

	}

	}

	}

}

extension AudioSource: Hashable {

	public var hashValue: Int {

	return Int(rawValue)

	}

}

// MARK: - Change Preview Bus
extension Message.Do {
	/// Informs a switcher that the preview bus should be changed
	public struct ChangePreviewBus: SerializableMessage {
		public static let title = Message.Title(string: "CPvI")

		public let mixEffect: UInt8
		public let previewBus: VideoSource

		public init(with bytes: ArraySlice<UInt8>) throws {
			mixEffect = bytes[relative: 0]
			let sourceNumber = UInt16(from: bytes[relative: 2..<4])
			self.previewBus = try VideoSource.decode(from: sourceNumber)
		}

		public init(to newPreviewBus: VideoSource, mixEffect: UInt8 = 0) {
			self.mixEffect = mixEffect
			previewBus = newPreviewBus
		}

		public var dataBytes: [UInt8] {
		return [mixEffect, 0] + previewBus.rawValue.bytes
		}

		public var debugDescription: String {return "Change preview bus to \(previewBus)"}
	}
}
extension Message.Did {
	/// Informs a controller that the preview bus has changed
	public struct ChangePreviewBus: SerializableMessage {
		public static let title = Message.Title(string: "PrvI")

		public let mixEffect: UInt8
		public let previewBus: VideoSource

		public init(with bytes: ArraySlice<UInt8>) throws {
			mixEffect = bytes[relative: 0]
			let sourceNumber = UInt16(from: bytes[relative: 2..<4])
			previewBus = try VideoSource.decode(from: sourceNumber)
		}

		public init(to newPreviewBus: VideoSource, mixEffect: UInt8 = 0) {
			self.mixEffect = mixEffect
			previewBus = newPreviewBus
		}

		public var dataBytes: [UInt8] {
			return [mixEffect, 0] + previewBus.rawValue.bytes + [0,0,0,0]
		}
		public var debugDescription: String {return "Preview bus changed to \(previewBus) on ME\(mixEffect)"}
	}
}

// MARK: - Change Program Bus
extension Message.Do {
	/// Informs a switcher that the program bus shoud be changed
	public struct ChangeProgramBus: SerializableMessage {
		public static let title = Message.Title(string: "CPgI")

		public let mixEffect: UInt8
		public let programBus: VideoSource

		public init(with bytes: ArraySlice<UInt8>) throws {
			mixEffect = bytes[relative: 0]
			let sourceNumber = UInt16(from: bytes[relative: 2..<4])
			self.programBus = try VideoSource.decode(from: sourceNumber)
		}

		public init(to newProgramBus: VideoSource, mixEffect: UInt8 = 0) {
			self.mixEffect = mixEffect
			programBus = newProgramBus
		}

		public var dataBytes: [UInt8] {
			return [mixEffect, 0] + programBus.rawValue.bytes
		}

		public var debugDescription: String {return "Change program bus to \(programBus)"}
	}
}
extension Message.Did {
	/// Informs a controller that the program bus has changed
	public struct ChangeProgramBus: SerializableMessage {
		public static let title = Message.Title(string: "PrgI")

		public let mixEffect: UInt8
		public let programBus: VideoSource

		public init(with bytes: ArraySlice<UInt8>) throws {
			mixEffect = bytes[relative: 0]
			let sourceNumber = UInt16(from: bytes[relative: 2..<4])
			self.programBus = try VideoSource.decode(from: sourceNumber)
		}

		public init(to newProgramBus: VideoSource, mixEffect: UInt8 = 0) {
			self.mixEffect = mixEffect
			programBus = newProgramBus
		}

		public var dataBytes: [UInt8] {
			return [mixEffect, 0] + programBus.rawValue.bytes
		}

		public var debugDescription: String {return "Program bus changed to \(programBus) on ME\(mixEffect)"}
	}
}

// MARK: - Change Auxiliary Output
extension Message.Do {
	/// Informs a switcher that a source should be assigned to the specified auxiliary output
	public struct ChangeAuxiliaryOutput: SerializableMessage {
		public static let title = Message.Title(string: "CAuS")

		/// The source that should be assigned to the auxiliary output
		public let source: VideoSource
		/// The auxiliary output that should be rerouted
		public let output: UInt8

		public init(with bytes: ArraySlice<UInt8>) throws {
			output = bytes[relative: 1]
			let sourceNumber = UInt16(from: bytes[relative: 2..<4])
			self.source = try VideoSource.decode(from: sourceNumber)
		}

		/// Create a message to reroute an auxiliary output.
		/// - Parameters:
		///   - output: The source that should be assigned to the auxiliary output
		///   - newSource: The auxiliary output that should be rerouted
		public init(_ output: UInt8, to newSource: VideoSource) {
			self.source = newSource
			self.output = output
		}

		public var dataBytes: [UInt8] {
			return [1, output] + source.rawValue.bytes
		}

		public var debugDescription: String {return "Change Aux \(output) source to source \(source)"}
	}
}
extension Message.Did {
	/// Informs a controller that a source has been routed to an auxiliary output
	public struct ChangeAuxiliaryOutput: SerializableMessage {
		public static let title = Message.Title(string: "AuxS")

		/// The source that has been routed to the auxiliary output
		public let source: VideoSource
		/// The auxiliary output that has received another route
		public let output: UInt8

		public init(with bytes: ArraySlice<UInt8>) throws {
			output = bytes[relative: 0]
			let sourceNumber = UInt16(from: bytes[relative: 2..<4])
			self.source = try VideoSource.decode(from: sourceNumber)
		}

		/// Create a message to inform that a source has been routed to an auxiliary output
		/// - Parameters:
		///   - source: The source that has been assigned to the auxiliary output
		///   - output: The auxiliary output that has been rerouted
		public init(source newSource: VideoSource, output newOutput: UInt8) {
			source = newSource
			output = newOutput
		}

		public var dataBytes: [UInt8] {
			return [output, 0] + source.rawValue.bytes
		}

		public var debugDescription: String {return "Aux \(output) source changed to source \(source)"}
	}
}

// MARK: - TimeCode
extension Message.Do {
	public struct GetTimecode: SerializableMessage {
		public static let title = Message.Title(string: "TiRq")

		public init(with bytes: ArraySlice<UInt8>) throws {}
		public init() {}

		public let dataBytes = [UInt8]()
		public let debugDescription = "Command: Request time code"
	}
}
extension Message.Did {
	/// Informs a controller that the switchers timecode has changed
	public struct GetTimecode: SerializableMessage {
		public typealias Timecode = (hour: UInt8, minute: UInt8, second: UInt8, frame: UInt8)
		public static let title = Message.Title(string: "Time")
		public let timecode: Timecode

		public init(hour: UInt8, minute: UInt8, second: UInt8, frame: UInt8) {
			timecode = (hour, minute, second, frame)
		}

		public init(with bytes: ArraySlice<UInt8>) throws {
			timecode = (
				bytes[relative: 0],
				bytes[relative: 1],
				bytes[relative: 2],
				bytes[relative: 3]
			)
		}

		public var dataBytes: [UInt8] {
			[
				timecode.hour,
				timecode.minute,
				timecode.second,
				timecode.frame,
				0,0,3,0xE8
			]
		}

		public var debugDescription: String { return "Switcher time \(timecode)" }
	}
}

// MARK: Transitions
extension Message.Do {
	/// Informs the switcher that it should update its transition position
	public struct ChangeTransitionPosition: SerializableMessage {
		public static let title = Message.Title(string: "CTPs")
		public let mixEffect: UInt8
		public let position: UInt16

		public init(with bytes: ArraySlice<UInt8>) throws {
			mixEffect = bytes[relative: 0]
			position = UInt16(from: bytes[relative: 2..<4])
		}

		public init(to position: UInt16, mixEffect: UInt8 = 0) {
			self.mixEffect = mixEffect
			self.position = position
		}

		public var dataBytes: [UInt8] {
			return [mixEffect, 0] + position.bytes
		}

		public var debugDescription: String { return "Change transition position of ME\(mixEffect+1) to \(position)"}
	}
}
extension Message.Did {
	/// Informs the controller that the transition position has changed
	public struct ChangeTransitionPosition: SerializableMessage {
		public static let title = Message.Title(string: "TrPs")
		public let mixEffect: UInt8
		public let position: UInt16
		public let inTransition: Bool
		public let remainingFrames: UInt8

		public init(with bytes: ArraySlice<UInt8>) throws {
			mixEffect = bytes[relative: 0]
			inTransition = bytes[relative: 1] == 1
			remainingFrames = bytes[relative: 2]
			position = UInt16(from: bytes[relative: 4..<6])
		}

		public init(to position: UInt16, remainingFrames: UInt8, inTransition: Bool? = nil, mixEffect: UInt8 = 0) {
			self.mixEffect = mixEffect
			self.position = position
			if let inTransition = inTransition {
				self.inTransition = inTransition
			} else {
				self.inTransition = (1..<9999).contains(position)
			}
			self.remainingFrames = remainingFrames
		}

		public var dataBytes: [UInt8] {
			return [mixEffect, inTransition ? 1:0, remainingFrames, 0] + position.bytes + [0, 0]
		}

		public var debugDescription: String { return "Change transition position of ME\(mixEffect+1) to \(position)"}
	}
}

extension Message.Did {
	/// Informs a controller that the some tally lights might have changed.
	public struct GetSourceTallies: SerializableMessage {
		public static let title = Message.Title(string: "TlSr")

		/// The state of the tally lights for each source of the Atem switcher
		public let tallies: [VideoSource:TallyLight]

		public init(with bytes: ArraySlice<UInt8>) throws {
			let sourceCount = Int(UInt16(from: bytes))
			precondition(sourceCount*3 <= bytes.count-2, "Message is too short, it cannot contain tally info for \(sourceCount) sources")

			var tallies = [VideoSource:TallyLight](minimumCapacity: sourceCount)
			for cursor in stride(from: 2, to: sourceCount*3 + 2, by: 3) {
				let source = try VideoSource.decode(from: UInt16(from: bytes[relative: cursor...]))
				tallies[source] = try TallyLight.decode(from: bytes[relative: cursor+2])
			}
			self.tallies = tallies
		}


		public init(tallies: [VideoSource:TallyLight]) {
			self.tallies = tallies
		}

		public var dataBytes: [UInt8] {
			var bytes = [UInt8]()
			bytes.reserveCapacity(2 + tallies.count*3)

			bytes.append(contentsOf: UInt16(tallies.count).bytes)
			// Todo: check if sources really need to be sorted
			for (source, tally) in tallies.sorted(by: {$0.0.rawValue < $1.0.rawValue}) {
				bytes.append(contentsOf: source.rawValue.bytes)
				bytes.append(tally.rawValue)
			}
			return bytes
		}

		public var debugDescription: String {
			return "Source tallies (\n" +
			"\(tallies.sorted{$0.0.rawValue < $1.0.rawValue}.map{"\t\($0.0): \($0.1)"}.joined(separator: "\n"))" +
			"\n)"
		}
	}
}

import Foundation
extension Message.Do {
	@available(OSX 10.12, iOS 10.0, *)
	public struct ChangeKeyDVE: SerializableMessage {
		public static let title = Message.Title(string: "CKDV")

		public let changedElements: ChangeMask
		public let mixEffectIndex: UInt8
		public let upstreamKey: UInt8
		public let rotation: Measurement<UnitAngle>

		public init(with bytes: ArraySlice<UInt8>) throws {
			changedElements = ChangeMask(rawValue: UInt32(from: bytes[relative: Position.changedElements]))
			mixEffectIndex = bytes[relative: Position.mixEffect]
			upstreamKey = bytes[relative: Position.upstreamKey]
			rotation = Measurement(
				value: Double(UInt32(from: bytes[relative: Position.rotation])) / 10,
				unit: UnitAngle.degrees
			)
		}

		public init(mixEffect: UInt8, key: UInt8, rotation: Measurement<UnitAngle>) {
			changedElements = .rotation
			mixEffectIndex = mixEffect
			upstreamKey = key
			self.rotation = rotation
		}

		public var debugDescription: String {
			"Change Key DVE. \(changedElements)"
		}

		public var dataBytes: [UInt8] {
			.init(unsafeUninitializedCapacity: 64) { (buffer, count) in
				buffer.write(changedElements.rawValue.bigEndian, at: Position.changedElements.lowerBound)
				buffer[Position.mixEffect] = mixEffectIndex
				buffer[Position.upstreamKey] = upstreamKey
				buffer.write(UInt32(rotation.converted(to: .degrees).value * 10).bigEndian, at: Position.rotation.lowerBound)
				count = 64
			}
		}

		enum Position {
			static let changedElements = 0..<4
			static let mixEffect = 4
			static let upstreamKey = 5
			static let rotation = 24..<28
		}

		public struct ChangeMask: OptionSet {
			public let rawValue: UInt32

			public init(rawValue: UInt32) {
				self.rawValue = rawValue
			}

			public static let rotation = Self(rawValue: 1 << 4)
		}
	}
}
