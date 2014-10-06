"
A QRCode (Quick Response Code) is a matrix of nominally square modules arranged in an overall square pattern. It can be used to encode a variety of data formats: numeric, alphanumeric, byte and kanji. This implementation is based on the international standard for QR Code 2005.

There are two ways to generate a QRCode:
(1) Sending the asQRCode / asMicroQRCode message to an object, usually a String or Integer (e.g., 'http://smalltalkhub.com' asQRCode). asQRCode will produce a standard Model 2 QR Code. asMicroQRCode will produce a Micro QR Code. There are many readers that do not accept Micro QR, so it is safest to just use asQRCode.
(2) To specify something different (different error correction level, ECI encoding) than the default, use the ""QRCode creation"" protocol class methods in QRCodeEncoder.

QR Code allows you to specify four levels of error correction:
	(L) Recovery of 7% of the symbol codewords
	(M) Recovery of 15% of the symbol codewords
	(Q) Recovery of 25% of the symbol codewords
	(H) Recovery of 30% of the symbol codewords
The higher the level of error correction, the larger the symbol needs to be. To minimize symbol extent, $L is is used as the default error correction. To further minimize symbol extent, keeping to alphanumeric mode can be useful but requires that all letters are uppercase. As URLs (the most common use for QR Code) are largely case insensitive, alphanumeric mode is probably sufficient. While error correction is a core feature of the QRCode specification, many readers don't utilize it.

After initialization, this class serves as a wrapper for the QRCode, allowing access to its string, encoding, version, errorCorrection, and eci; these cannot be changed after creation. Most importantly, you can access its form. For example, do the following code:

('HTTP://SMALLTALKHUB.COM' asQRCode form magnifyBy: 10) asMorph openInWorld.

| instance |
instance := 'http://smalltalkhub.com' asQRCode.
instance backgroundColor: Color green.
instance foregroundColor: Color yellow.
(instance formWithQuietZone magnifyBy: 10) asMorph openInWorld.

This class also implements two of the features of QR Code 2005: reversing and mirroring. You can reverse the symbol (i.e., exchange background and foreground colors) by sending the reverse message to the QRCode. You can mirror the symbol (i.e., flip the symbol left to right) by sending the mirror message to the QRCode; it is not clear why you would want to do that, but it is in the specifications. While black and white are specified as the nominal foreground and background colors respectively, you can change them to arbitrary colors (as above). Be cautious using these features; many readers do not support them.
"
Class {
	#name : #QRCode,
	#superclass : #Object,
	#instVars : [
		'string',
		'errorCorrection',
		'encoding',
		'eci',
		'form',
		'foregroundColor',
		'backgroundColor',
		'isMirrored'
	],
	#category : #'QRCode-Core'
}

{ #category : #'form access' }
QRCode >> backgroundColor [
	^ backgroundColor
		ifNil: [ Color white ]
		ifNotNil: [ backgroundColor ]
]

{ #category : #'form access' }
QRCode >> backgroundColor: aColor [
	self backgroundColor = aColor ifTrue: [ ^ self ].
	self foregroundColor = aColor ifTrue: [ self error: 'A QR code cannot have the same foreground and background color.' ].
	foregroundColor := self foregroundColor.
	backgroundColor := aColor.
	(foregroundColor = Color black and: [ backgroundColor = Color white ]) ifTrue: [ 
		backgroundColor := nil.
		foregroundColor := nil ]
]

{ #category : #accessing }
QRCode >> eci [
	^ eci
]

{ #category : #'initialize-release' }
QRCode >> eci: aNumber [
	"Indicate the ECI encoding.
	3 = ISO/IEC 8859-1 Latin 1
	26 = ISO/IEC 10646 UTF-8"
	eci := aNumber
]

{ #category : #accessing }
QRCode >> encoding [
	^ encoding
]

{ #category : #'initialize-release' }
QRCode >> encoding: aSymbol [
	"The supported encoding types are #numeric, #alphanumeric, #byte and #kanji."
	encoding := aSymbol
]

{ #category : #accessing }
QRCode >> errorCorrection [
	^ errorCorrection
]

{ #category : #'initialize-release' }
QRCode >> errorCorrection: char [
	"For QR codes, the following characters are possible: L, M, Q and H.
	For MicroQR codes, the following characters are possible: L, M and Q.
	When the error correction is not specified, the encoder will choose the one that creates the smallest form with the best error correction."
	errorCorrection := char
]

{ #category : #'form access' }
QRCode >> foregroundColor [
	^ foregroundColor
		ifNil: [ Color black ]
		ifNotNil: [ foregroundColor ]
]

{ #category : #'form access' }
QRCode >> foregroundColor: aColor [
	self foregroundColor = aColor ifTrue: [ ^ self ].
	self backgroundColor = aColor ifTrue: [ self error: 'A QR code cannot have the same foreground and background color.' ].
	backgroundColor := self backgroundColor.
	foregroundColor := aColor.
	(foregroundColor = Color black and: [ backgroundColor = Color white ]) ifTrue: [ 
		backgroundColor := nil.
		foregroundColor := nil ]
]

{ #category : #'form access' }
QRCode >> form [
	| return |
	"Do the mirroring"
	return := self isMirrored
		ifTrue: [ form flipBy: #horizontal centerAt: form center ]
		ifFalse: [ form ].
	"If there is a background / foreground color specified, apply them."
	backgroundColor ifNotNil: [ backgroundColor = Color black
		ifTrue: [ 
			return := return copy reverse.
			foregroundColor = Color white ifFalse: [ 
				return := return asFormOfDepth: 32.
				return mapColor: Color white to: foregroundColor ] ]
		ifFalse: [ 
			return := return asFormOfDepth: 32.
			backgroundColor = Color white ifFalse: [ 
				return mapColor: Color white to: backgroundColor ].
			foregroundColor = Color black ifFalse: [ 
				return mapColor: Color black to: foregroundColor ] ] ].
	^ return
]

{ #category : #'initialize-release' }
QRCode >> form: aForm [
	form := aForm
]

{ #category : #'form access' }
QRCode >> formWithBorder: anInteger [
	^ self formWithBorder: anInteger color: self backgroundColor
]

{ #category : #'form access' }
QRCode >> formWithBorder: anInteger color: aColor [
	| myForm depth return |
	myForm := self form.
	depth := (aColor = Color white or: [ aColor = Color black ])
		ifTrue: [ myForm depth ]
		ifFalse: [ 32 ].
	return := Form extent: anInteger @ anInteger * 2 + myForm extent depth: depth.
	return getCanvas
		fillColor: aColor;
		drawImage: myForm at: anInteger @ anInteger.
	^ return
]

{ #category : #'form access' }
QRCode >> formWithQuietZone [
	"The specifications suggest that there is a quiet zone of 4 pixels is correct for QR Code and 2 pixels is correct for Micro QR Code."
	^ self formWithBorder: (self isMicro ifTrue: [ 2 ] ifFalse: [ 4 ])
]

{ #category : #'initialize-release' }
QRCode >> initialize [
	super initialize.
	isMirrored := false
]

{ #category : #testing }
QRCode >> isAlphanumeric [
	^encoding == #alphanumeric
]

{ #category : #testing }
QRCode >> isByte [
	^encoding == #byte
]

{ #category : #testing }
QRCode >> isEncoded [
	^form notNil
]

{ #category : #testing }
QRCode >> isKanji [
	^encoding == #kanji
]

{ #category : #testing }
QRCode >> isMicro [
	^form width < 21
]

{ #category : #testing }
QRCode >> isMirrored [
	^isMirrored
]

{ #category : #testing }
QRCode >> isNumeric [
	^encoding == #numeric
]

{ #category : #testing }
QRCode >> isReversed [
	"Normally, a QR Code has the 1 bits (foregroundColor) in a darker color than the 0 bits (backgroundColor); however, this can be reversed by calling the reverse message. In that case the QR Code is reversed."
	^self backgroundColor luminance < self foregroundColor luminance
]

{ #category : #testing }
QRCode >> isUTF8 [
	^ eci = 26
]

{ #category : #'form access' }
QRCode >> mirror [
	"Reflect the form across a vertical line to mirror the image.
	The capability of QR Code / Micro QR Code to be mirrored was added in QR Code 2005."
	isMirrored := isMirrored not
]

{ #category : #'form access' }
QRCode >> reverse [
	"Flip the foreground and background colors"
	| color |
	color := self backgroundColor.
	backgroundColor := self foregroundColor.
	foregroundColor := color.
	(foregroundColor = Color black and: [ backgroundColor = Color white ]) ifTrue: [ 
		backgroundColor := nil.
		foregroundColor := nil ]
]

{ #category : #accessing }
QRCode >> string [
	^ string
]

{ #category : #'initialize-release' }
QRCode >> string: aString [
	string := aString
]

{ #category : #testing }
QRCode >> usesEciMode [
	"Standard byte encoding is done in ISO/IEC 8859-1. To use other byte encoding systems, you need to specify an ECI."
	^encoding == #byte and: [ (eci = 3) not ]
]

{ #category : #accessing }
QRCode >> version [
	"For QR Code, the version is an integer from 1 to 40. The version also specifies the extent of the symbol. Version 1 is 21x21 modules. Side length goes up by 4 with each version.
	For Micro QR Code, the version is an integer from 1 to 4. The version also specifies the extent of the symbol. Version 1 is 11x11 modules. Side length goes up by 2 with each version."
	^ self isMicro
		ifTrue: [ form width - 9 // 2 ]
		ifFalse: [ form width - 17 // 4 ]
]
