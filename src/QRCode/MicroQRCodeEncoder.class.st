"
This encoder is implemented according to the specifications for QR Code 2005 (ISO/IEC 18004:2006(E)).

The Micro QR Code differs from QR Code in that it only uses one position pattern (in the top left corner) and a smaller recommended quiet zone (2 pixels instead of 4). The smallest QR Code (Version 1) has an extent of 21x21 (29x29 with quiet zone). In contrast, Micro QR Codes are smaller:
	Version 1 : 11x11 (15x15)
	Version 2 : 13x13 (17x17)
	Version 3 : 15x15 (19x19)
	Version 4 : 17x17 (21x21)

Due to their small size, Micro QR Codes also have a small capacity. They are useful as markers for applications where size of the pattern is critical  (e.g., augmented reality), rather than for general use (e.g., distributing URLs). Many QR Code readers do not read Micro QR.
"
Class {
	#name : #MicroQRCodeEncoder,
	#superclass : #QRCodeEncoder,
	#category : #'QRCode-Core'
}

{ #category : #capacity }
MicroQRCodeEncoder >> alphanumericCapacityForCorrection: correction [
	^correction caseOf: { 
		[ $L ] -> [ #(0 6 14 21) ].
		[ $M ] -> [ #(0 5 11 18) ].
		[ $Q ] -> [ #(0 0 0 13) ] }
]

{ #category : #capacity }
MicroQRCodeEncoder >> byteCapacityForCorrection: correction [
	^correction caseOf: { 
		[ $L ] -> [ #(0 0 9 15) ].
		[ $M ] -> [ #(0 0 7 13) ].
		[ $Q ] -> [ #(0 0 0 9) ] }
]

{ #category : #'error correction' }
MicroQRCodeEncoder >> chunkingL [
	^ #(#(#(1 5 3))
		#(#(1 10 5))
		#(#(1 17 11))
		#(#(1 24 16)))
]

{ #category : #'error correction' }
MicroQRCodeEncoder >> chunkingM [
	^ #(#()
		#(#(1 10 4))
		#(#(1 17 9))
		#(#(1 24 14)))
]

{ #category : #'error correction' }
MicroQRCodeEncoder >> chunkingQ [
	^ #(#()
		#()
		#()
		#(#(1 24 10)))
]

{ #category : #'matrix generation' }
MicroQRCodeEncoder >> createMasks [
	| black white whiteCanvas blackCanvas |
	black := Color black.
	white := Color white.
	whiteMask := Form extent: dimension @ dimension.
	blackMask := Form extent: dimension @ dimension.
	whiteCanvas := whiteMask getCanvas.
	blackCanvas := blackMask getCanvas.
	whiteCanvas fillColor: black.
	"Add position detection + format and version information"
	whiteCanvas
		"position pattern + format information"
		fillRectangle: (0@0 extent: 9@9) color: white.
	blackCanvas
		"top left pattern"
		fillRectangle: (0@0 extent: 7@7) color: black;
		fillRectangle: (1@1 extent: 5@5) color: white;
		fillRectangle: (2@2 extent: 3@3) color: black.
	"Add timing patterns"
	whiteCanvas fillRectangle: (0@0 extent: dimension @ 1) color: white.
	whiteCanvas fillRectangle: (0@0 extent: 1 @ dimension) color: white.
	8 to: dimension - 1 by: 2 do: [ :index |
		blackCanvas fillRectangle: (index @ 0 extent: 1@1) color: black.
		blackCanvas fillRectangle: (0 @ index extent: 1@1) color: black ]
]

{ #category : #capacity }
MicroQRCodeEncoder >> dataCapacityForCorrection: correction [
	^correction caseOf: {
		[ $L ] -> [ #(3 5 11 16) ].
		[ $M ] -> [ #(0 4 9 14) ].
		[ $Q ] -> [ #(0 0 0 10) ] }
]

{ #category : #'error correction' }
MicroQRCodeEncoder >> errorCorrections [
	^ #($L $M $Q)
]

{ #category : #'initialize-release' }
MicroQRCodeEncoder >> initializeCode [
	self initializeEncoding.
	code usesEciMode ifTrue: [ self error: 'MicroQR codes cannot use ECI.' ].
	self initializeVersion.
	self initializeCodewords.
	self initializeErrorCorrection.
	self initializeMatrixGeneration.
	self initializeMasking
]

{ #category : #codewords }
MicroQRCodeEncoder >> initializeCodewords [
	|  writer correctHalfByte |
	codewords := ByteArray new: self dataCapacity.
	writer := BitWriter on: codewords.
	"Mode & Number of Bits"
	self version caseOf: { 
		[ 1 ] -> [ code encoding caseOf: { 
			[ #numeric ] -> [ 
				"no mode bits"
				writer nextPut: string size bits: 3 ] } ].
		[ 2 ] -> [ code encoding caseOf: { 
			[ #numeric ] -> [ 
				writer nextPut: 0 bits: 1.
				writer nextPut: string size bits: 4 ].
			[ #alphanumeric ] -> [ 
				writer nextPut: 1 bits: 1.
				writer nextPut: string size bits: 3 ] } ].
		[ 3 ] -> [ code encoding caseOf: { 
			[ #numeric ] -> [ 
				writer nextPut: 0 bits: 2.
				writer nextPut: string size bits: 5 ].
			[ #alphanumeric ] -> [ 
				writer nextPut: 1 bits: 2.
				writer nextPut: string size bits: 4 ].
			[ #byte ] -> [ 
				writer nextPut: 2 bits: 2.
				writer nextPut: string size bits: 4 ].
			[ #kanji ] -> [ 
				writer nextPut: 3 bits: 2.
				writer nextPut: string size bits: 3 ] } ].
		[ 4 ] -> [ code encoding caseOf: { 
			[ #numeric ] -> [ 
				writer nextPut: 0 bits: 3.
				writer nextPut: string size bits: 6 ].
			[ #alphanumeric ] -> [ 
				writer nextPut: 1 bits: 3.
				writer nextPut: string size bits: 5 ].
			[ #byte ] -> [ 
				writer nextPut: 2 bits: 3.
				writer nextPut: string size bits: 5 ].
			[ #kanji ] -> [ 
				writer nextPut: 3 bits: 3.
				writer nextPut: string size bits: 4 ] } ] }.
	"Content"
	code encoding caseOf: { 
		[ #numeric ] -> [ writer nextPutNumeric: string ].
		[ #alphanumeric ] -> [ writer nextPutAlphanumeric: string ].
		[ #byte ] -> [ writer nextPutByte: string ].
		[ #kanji ] -> [ writer nextPutKanji: string ] }.
	"Terminate the sequence / Skip to next byte for error correction"
	writer nextPut: 0 bits: ((#(3 5 7 9) at: self version) min: writer bitsLeft).
	"Add error correction sequence, alternating between 11101100 and 00010001".
	correctHalfByte := (#(1 3) includes: self version) and: [ writer bytesLeft > 0 ].
	1 to: writer bytesLeft do: [ :index |
		writer nextPut: (index odd ifTrue: [ 2r11101100 ] ifFalse: [ 2r00010001 ]) ].
	correctHalfByte ifTrue: [ codewords at: codewords size put: 0 ]
]

{ #category : #masking }
MicroQRCodeEncoder >> initializeMasking [
	| symbols errorCorrection format finalForm |
	symbols := self maskedSymbols.
	finalForm := symbols detectMax: [ :entry | self penaltyScoreSymbol: entry ].
	"Generate the format information"
	format := version caseOf: { 
		[ 1 ] -> [ 2r000 ].
		[ 2 ] -> [ code errorCorrection caseOf: {
			[ $L ] -> [ 2r001 ].
			[ $M ] -> [ 2r010 ] } ].
		[ 3 ] -> [ code errorCorrection caseOf: {
			[ $L ] -> [ 2r011 ].
			[ $M ] -> [ 2r100 ] } ].
		[ 4 ] -> [ code errorCorrection caseOf: {
			[ $L ] -> [ 2r101 ].
			[ $M ] -> [ 2r110 ].
			[ $Q ] -> [ 2r111 ] } ] }.
	format := (format * 4) +  (symbols indexOf: finalForm) - 1 * 1024.
	errorCorrection := format.
	14 to: 10 by: -1 do: [ :i |
		errorCorrection >= (2 raisedTo: i) ifTrue: [
			errorCorrection := (2 raisedTo: i - 10) * 1335 bitXor: errorCorrection ] ].
	format := (format + errorCorrection) bitXor: 2r100010001000101.
	"Place the format information"
	bb := BitBlt bitPokerToForm: finalForm.
	{ { 8 @ 1 }.
		{ 8 @ 2 }.
		{ 8 @ 3 }.
		{ 8 @ 4 }.
		{ 8 @ 5 }.
		{ 8 @ 6 }.
		{ 8 @ 7 }.
		{ 8 @ 8 }.
		{ 7 @ 8 }.
		{ 6 @ 8 }.
		{ 5 @ 8 }.
		{ 4 @ 8 }.
		{ 3 @ 8 }.
		{ 2 @ 8 }.
		{ 1 @ 8 } } withIndexDo: [ :arr :index |
			((2 raisedTo: index - 1) bitAnd: format) = 0 ifFalse: [
				arr do: [ :point |
					bb pixelAt: point put: 1 ] ] ].
	code form: finalForm
]

{ #category : #'matrix generation' }
MicroQRCodeEncoder >> initializeMatrixGeneration [
	| bbMatrix |
	self dimension: version * 2 + 9.
	matrix := Form extent: dimension @ dimension.
	self createMasks.
	"Fill Matrix with finalCodewords (using the white mask to avoid writing to non-data areas"
	matrixPosition := dimension - 2 @ dimension.
	bb := BitBlt bitPeekerFromForm: whiteMask.
	bbMatrix := BitBlt bitPokerToForm: matrix.
	"MicroQRCode Version 1 & 3 has a half byte"
	version caseOf: { 
		[ 1 ] -> [ "half byte is the 3rd codeword"
			self placeBytes: (finalCodewords copyFrom: 1 to: 2) matrix: bbMatrix.
			self placeHalfByte: (finalCodewords at: 3) matrix: bbMatrix.
			self placeBytes: (finalCodewords copyFrom: 4 to: finalCodewords size) matrix: bbMatrix ].
		[ 3 ] -> [ code errorCorrection caseOf: { 
			[ $L ] -> [ "half byte is the 11th codeword"
				self placeBytes: (finalCodewords copyFrom: 1 to: 10) matrix: bbMatrix.
				self placeHalfByte: (finalCodewords at: 11) matrix: bbMatrix.
				self placeBytes: (finalCodewords copyFrom: 12 to: finalCodewords size) matrix: bbMatrix ].
			[ $M ] -> [ "half byte is the 9th codeword"
				self placeBytes: (finalCodewords copyFrom: 1 to: 8) matrix: bbMatrix.
				self placeHalfByte: (finalCodewords at: 9) matrix: bbMatrix.
				self placeBytes: (finalCodewords copyFrom: 10 to: finalCodewords size) matrix: bbMatrix ] } ] }
		otherwise: [ self placeBytes: finalCodewords matrix: bbMatrix ]
]

{ #category : #capacity }
MicroQRCodeEncoder >> kanjiCapacityForCorrection: correction [
	^correction caseOf: { 
		[ $L ] -> [ #(0 0 6 9) ].
		[ $M ] -> [ #(0 0 4 8) ].
		[ $Q ] -> [ #(0 0 0 5) ] }
]

{ #category : #masking }
MicroQRCodeEncoder >> maskingGenerators [
	^ { [ :i  :j | i \\ 2 = 0 ].
		[ :i :j | (i // 2) + (j // 3) \\ 2 = 0 ].
		[ :i :j | i * j + (i * j \\ 3) \\ 2 = 0 ].
		[ :i :j | (i * j \\ 3) + i + j \\ 2 = 0 ] }
]

{ #category : #version }
MicroQRCodeEncoder >> maxVersion [
	^ 4
]

{ #category : #'matrix generation' }
MicroQRCodeEncoder >> nextMatrixPosition [
	| x |
	[ "Try next test position"
		x := matrixPosition x.
		matrixPosition := x even
			ifTrue: [ matrixPosition - (1@0) ]
			ifFalse: [ (dimension - x // 2) odd
				ifTrue: [ matrixPosition y = 1
					ifTrue: [ matrixPosition + (-1 @ 0) ]
					ifFalse: [ matrixPosition + (1 @ -1) ] ]
				ifFalse: [ matrixPosition y + 1 = dimension
					ifTrue: [ matrixPosition + (-1 @ 0) ]
					ifFalse: [ matrixPosition + (1 @ 1) ] ] ].
		(bb pixelAt: matrixPosition) = 1 ] whileFalse.
	^ matrixPosition
]

{ #category : #capacity }
MicroQRCodeEncoder >> numericCapacityForCorrection: correction [
	^correction caseOf: { 
		[ $L ] -> [ #(5 10 23 35) ].
		[ $M ] -> [ #(0 8 18 30) ].
		[ $Q ] -> [ #(0 0 0 21) ] }
]

{ #category : #masking }
MicroQRCodeEncoder >> penaltyScoreSymbol: aForm [
	"Return the penalty score for the symbol, according to the following criteria:
	SUM1 = number of black dots at the right edge
	SUM2 = number of black dots at the bottom edge
	MAX = MAX(SUM1,SUM2)
	MIN = MIN(SUM1,SUM2)
	RETURN = 16 * MIN + MAX
	Note that a higher penalty score is good in the case of MicroQR Code"
	| rightSum bottomSum |
	bb := BitBlt bitPeekerFromForm: aForm.
	rightSum := (1 to: dimension - 1) count: [ :row | (bb pixelAt: dimension - 1 @ row) = 1 ].
	bottomSum := (1 to: dimension - 1) count: [ :column | (bb pixelAt: column @ (dimension - 1)) = 1 ].
	^ rightSum > bottomSum
		ifTrue: [ bottomSum * 16 + rightSum ]
		ifFalse: [ rightSum * 16 + bottomSum ]
]

{ #category : #'matrix generation' }
MicroQRCodeEncoder >> placeHalfByte: byte matrix: bbMatrix [
	| test |
	test := byte.
	1 to: 4 do: [ :index |
		self nextMatrixPosition.
		test > 127 ifTrue: [
			bbMatrix pixelAt: matrixPosition put: 1.
			test := test - 128 ].
		test := test * 2 ]
]

{ #category : #capacity }
MicroQRCodeEncoder >> totalCapacityVersion: index [
	^ #(5 10 17 24) at: index
]
