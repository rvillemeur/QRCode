"
A QRCode (Quick Response Code) is a matrix of nominally square modules arranged in an overall square pattern. It can be used to encode a variety of data formats. Numeric, alphanumeric, byte, and kanji are implemented. This implementation is based on the international standard for QR Code Model 2.

There are two primary ways to generate a QRCode:
(1) Sending the asQRCode message to a String (e.g., 'http://smalltalkhub.com' asQRCode). This will use an error correction level of $M (medium).
(2) Using the class instance creation method to specify the level of error correction:
	(L) Recovery of 7% of the symbol codewords
	(M) Recovery of 15% of the symbol codewords
	(Q) Recovery of 25% of the symbol codewords
	(H) Recovery of 30% of the symbol codewords

The higher the level of error correction, the larger the symbol needs to be. For the smallest symbol, use $L for error correction. Also, alphanumeric mode can be particularly concise but requires that all the letters are uppercase. For most URLs, that is perfectly sufficient.

After initialization, this class serves as a wrapper for the QRCode, allowing access to its string, encoding, version, and errorCorrection; these cannot be changed after creation. Most importantly, you can access its form. For example, do the following code:

((QRCode fromString: 'HTTP://SMALLTALKHUB.COM') form magnifyBy: 10) asMorph openInWorld.

| instance |
instance := 'http://smalltalkhub.com' asQRCode.
instance backgroundColor: Color green.
instance foregroundColor: Color yellow.
(instance formWithQuietZone magnifyBy: 10) asMorph openInWorld.
"
Class {
	#name : #QRCode,
	#superclass : #Object,
	#instVars : [
		'errorCorrection',
		'string',
		'encoding',
		'version',
		'form'
	],
	#category : #'QRCode-Core'
}

{ #category : #'instance creation' }
QRCode class >> fromString: aString [
	^self basicNew
		string: aString;
		initialize;
		yourself
]

{ #category : #'instance creation' }
QRCode class >> fromString: aString errorCorrection: char [
	^self basicNew
		errorCorrection: char;
		string: aString;
		initialize;
		yourself
]

{ #category : #'form access' }
QRCode >> backgroundColor [
	"The background color is white by default"
	^form colorAt: 1@1
]

{ #category : #'form access' }
QRCode >> backgroundColor: aColor [
	self backgroundColor = aColor ifTrue: [ ^self ].
	self foregroundColor = aColor ifTrue: [ self error: 'A QR code cannot have the same foreground and background color.' ].
	form depth = 1 ifTrue: [ form := form asFormOfDepth: 32 ].
	form mapColor: self backgroundColor to: aColor
]

{ #category : #accessing }
QRCode >> encoding [
	^encoding
]

{ #category : #'initialize-release' }
QRCode >> encoding: aSymbol [
	"The supported encoding types are #numeric, #alphanumeric, #byte, and #kanji"
	encoding := aSymbol
]

{ #category : #accessing }
QRCode >> errorCorrection [
	^errorCorrection
]

{ #category : #'initialize-release' }
QRCode >> errorCorrection: char [
	"Can be one of the following characters: L, M, Q, H, corresponding to recovery levels of 7%, 15%, 25%, and 30% respectively"
	errorCorrection := char
]

{ #category : #'form access' }
QRCode >> foregroundColor [
	"The foreground color is white by default"
	^form colorAt: 0@0
]

{ #category : #'form access' }
QRCode >> foregroundColor: aColor [
	self foregroundColor = aColor ifTrue: [ ^self ].
	self backgroundColor = aColor ifTrue: [ self error: 'A QR code cannot have the same foreground and background color.' ].
	form depth = 1 ifTrue: [ form := form asFormOfDepth: 32 ].
	form mapColor: self foregroundColor to: aColor
]

{ #category : #'form access' }
QRCode >> form [
	^form
]

{ #category : #'initialize-release' }
QRCode >> form: aForm [
	form := aForm
]

{ #category : #'form access' }
QRCode >> formWithBorder: anInteger [
	^self formWithBorder: anInteger color: self backgroundColor
]

{ #category : #'form access' }
QRCode >> formWithBorder: anInteger color: aColor [
	| return |
	return := form class extent: anInteger @ anInteger *2 + form extent depth: form depth.
	return getCanvas
		fillColor: self backgroundColor;
		drawImage: form at: anInteger @ anInteger.
	^return
]

{ #category : #'form access' }
QRCode >> formWithQuietZone [
	"The specifications suggest that there is a quiet zone of 4 pixels"
	^self formWithBorder: 4
]

{ #category : #'initialize-release' }
QRCode >> initialize [
	super initialize.
	errorCorrection ifNil: [errorCorrection := $M].
	QRCodeEncoder initializeCode: self
]

{ #category : #'form access' }
QRCode >> reverseForm [
	"Flip the foreground and background colors"
	| foregroundColor backgroundColor thirdColor |
	form depth = 1
		ifTrue: [ form reverse ]
		ifFalse: [ 
			foregroundColor := self foregroundColor.
			backgroundColor := self backgroundColor.
			thirdColor := { Color white. Color black. Color red. } detect: [ :color | 
				(foregroundColor = color or: [ backgroundColor = color ]) not ].
			form mapColor: foregroundColor to: thirdColor.
			form mapColor: backgroundColor to: foregroundColor.
			form mapColor: thirdColor to: backgroundColor ]
]

{ #category : #accessing }
QRCode >> string [
	^string
]

{ #category : #'initialize-release' }
QRCode >> string: aString [
	string := aString
]

{ #category : #accessing }
QRCode >> version [
	^version
]

{ #category : #'initialize-release' }
QRCode >> version: anInteger [
	"Can be from 1 to 40. The version also specifies the extent of the symbol. Version 1 is 21 x 21 modules. Side length goes up by 4 with each version."
	version := anInteger
]
