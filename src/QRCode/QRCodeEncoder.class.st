"
This encoder is implemented according to the specifications for QR Code 2005 (ISO/IEC 18004:2006(E)).
"
Class {
	#name : #QRCodeEncoder,
	#superclass : #Object,
	#instVars : [
		'string',
		'version',
		'code',
		'codewords',
		'finalCodewords',
		'whiteMask',
		'blackMask',
		'bb',
		'matrix',
		'matrixPosition',
		'dimension'
	],
	#classVars : [
		'GeneratorPolynomials'
	],
	#category : #'QRCode-Core'
}

{ #category : #'QRCode creation' }
QRCodeEncoder class >> codeForString: aString [
	| return |
	return := QRCode new
		string: aString;
		yourself.
	self initializeCode: return.
	^ return
]

{ #category : #'QRCode creation' }
QRCodeEncoder class >> codeForString: aString eci: anInteger [
	| return |
	return := QRCode new
		string: aString;
		eci: anInteger;
		yourself.
	self initializeCode: return.
	^ return
]

{ #category : #'QRCode creation' }
QRCodeEncoder class >> codeForString: aString errorCorrection: errorCorrection [
	| return |
	return := QRCode new
		string: aString;
		errorCorrection: errorCorrection;
		yourself.
	self initializeCode: return.
	^ return
]

{ #category : #'QRCode creation' }
QRCodeEncoder class >> codeForString: aString errorCorrection: errorCorrection eci: anInteger [
	| return |
	return := QRCode new
		string: aString;
		errorCorrection: errorCorrection;
		eci: anInteger;
		yourself.
	self initializeCode: return.
	^ return
]

{ #category : #'class initialization' }
QRCodeEncoder class >> initialize [
	super initialize.
	"Cache the generator polynomials so they don't need to be regenerated each time"
	GeneratorPolynomials := Dictionary new
]

{ #category : #'instance creation' }
QRCodeEncoder class >> initializeCode: aQRCode [
	^ self new
		code: aQRCode;
		initializeCode;
		yourself
]

{ #category : #'matrix generation' }
QRCodeEncoder >> alignmentPattern [
	^ #(#()
		#(6 18)
		#(6 22)
		#(6 26)
		#(6 30)
		#(6 34)
		#(6 22 38)
		#(6 24 42)
		#(6 26 46)
		#(6 28 50)
		#(6 30 54)
		#(6 32 58)
		#(6 34 62)
		#(6 26 46 66)
		#(6 26 48 70)
		#(6 26 50 74)
		#(6 30 54 78)
		#(6 30 56 82)
		#(6 30 58 86)
		#(6 34 62 90)
		#(6 28 50 72 94)
		#(6 26 50 74 98)
		#(6 30 54 78 102)
		#(6 28 54 80 106)
		#(6 32 58 84 110)
		#(6 30 58 86 114)
		#(6 34 62 90 118)
		#(6 26 50 74 98 122)
		#(6 30 54 78 102 126)
		#(6 26 52 78 104 130)
		#(6 30 56 82 108 134)
		#(6 34 60 86 112 138)
		#(6 30 58 86 114 142)
		#(6 34 62 90 118 146)
		#(6 30 54 78 102 126 150)
		#(6 24 50 76 102 128 154)
		#(6 28 54 80 106 132 158)
		#(6 32 58 84 110 136 162)
		#(6 26 54 82 110 138 166)
		#(6 30 58 86 114 142 170)) at: version
]

{ #category : #capacity }
QRCodeEncoder >> alphanumericCapacityForCorrection: correction [
	^ correction caseOf: {
		[ $L ] -> [ #(25 47 77 114 154 195 224 279 335 395 468 535 619 667 758 854 938 1046 1153 1249 1352 1460 1588 1704 1853 1990 2132 2223 2369 2520 2677 2840 3009 3183 3351 3537 3729 3927 4087 4296) ].
		[ $M ] -> [ #(20 38 61 90 122 154 178 221 262 311 366 419 483 528 600 656 734 816 909 970 1035 1134 1248 1326 1451 1542 1637 1732 1839 1994 2113 2238 2369 2506 2632 2780 2894 3054 3220 3391) ].
		[ $Q ] -> [ #(16 29 47 67 87 108 125 157 189 221 259 296 352 376 426 470 531 574 644 702 742 823 890 963 1041 1094 1172 1263 1322 1429 1499 1618 1700 1787 1867 1966 2071 2181 2298 2420) ].
		[ $H ] -> [ #(10 20 35 50 64 84 93 122 143 174 200 227 259 283 321 365 408 452 493 557 587 640 672 744 779 864 910 958 1016 1080 1150 1226 1307 1394 1431 1530 1591 1658 1774 1852) ] }
]

{ #category : #capacity }
QRCodeEncoder >> byteCapacityForCorrection: correction [
	^ correction caseOf: {
		[ $L ] -> [ #(17 32 53 78 106 134 154 192 230 271 321 367 425 458 520 586 644 718 792 858 929 1003 1091 1171 1273 1367 1465 1528 1628 1732 1840 1952 2068 2188 2303 2431 2563 2699 2809 2953) ].
		[ $M ] -> [ #(14 26 42 62 84 106 122 152 180 213 251 287 331 362 412 450 504 560 624 666 711 779 857 911 997 1059 1125 1190 1264 1370 1452 1538 1628 1722 1809 1911 1989 2099 2213 2331) ].
		[ $Q ] -> [ #(11 20 32 46 60 74 86 108 130 151 177 203 241 258 292 322 364 394 442 482 509 565 611 661 715 751 805 868 908 982 1030 1112 1168 1228 1283 1351 1423 1499 1579 1663) ].
		[ $H ] -> [ #(7 14 24 34 44 58 64 84 98 119 137 155 177 194 220 250 280 310 338 382 403 439 461 511 535 593 625 658 698 742 790 842 898 958 983 1051 1093 1139 1219 1273) ] }
]

{ #category : #'error correction' }
QRCodeEncoder >> chunking [
	^ (code errorCorrection caseOf: {
		[ $L ] -> [ self chunkingL ].
		[ $M ] -> [ self chunkingM ].
		[ $Q ] -> [ self chunkingQ ].
		[ $H ] -> [ self chunkingH ] }) at: version
]

{ #category : #'error correction' }
QRCodeEncoder >> chunkingH [
	^ #(#(#(1 26 9))
		#(#(1 44 16))
		#(#(2 35 13))
		#(#(4 25 9))
		#(#(2 33 11) #(2 34 12))
		#(#(4 43 15))
		#(#(4 39 13) #(1 40 14))
		#(#(4 40 14) #(2 41 15))
		#(#(4 36 12) #(4 37 13))
		#(#(6 43 15) #(2 44 16))
		#(#(3 36 12) #(8 37 13))
		#(#(7 42 14) #(4 43 15))
		#(#(12 33 11) #(4 34 12))
		#(#(11 36 12) #(5 37 13))
		#(#(11 36 12) #(7 37 13))
		#(#(3 45 15) #(13 46 16))
		#(#(2 42 14) #(17 43 15))
		#(#(2 42 14) #(19 43 15))
		#(#(9 39 13) #(16 40 14))
		#(#(15 43 15) #(10 44 16))
		#(#(19 46 16) #(6 47 17))
		#(#(34 37 13))
		#(#(16 45 15) #(14 46 16))
		#(#(30 46 16) #(2 47 17))
		#(#(22 45 15) #(13 46 16))
		#(#(33 46 16) #(4 47 17))
		#(#(12 45 15) #(28 46 16))
		#(#(11 45 15) #(31 46 16))
		#(#(19 45 15) #(26 46 16))
		#(#(23 45 15) #(25 46 16))
		#(#(23 45 15) #(28 46 16))
		#(#(19 45 15) #(35 46 16))
		#(#(11 45 15) #(46 46 16))
		#(#(59 46 16) #(1 47 17))
		#(#(22 45 15) #(41 46 16))
		#(#(2 45 15) #(64 46 16))
		#(#(24 45 15) #(46 46 16))
		#(#(42 45 15) #(32 46 16))
		#(#(10 45 15) #(67 46 16))
		#(#(20 45 15) #(61 46 16)))
]

{ #category : #'error correction' }
QRCodeEncoder >> chunkingL [
	^ #(#(#(1 26 19))
		#(#(1 44 34))
		#(#(1 70 55))
		#(#(1 100 80))
		#(#(1 134 108))
		#(#(2 86 68))
		#(#(2 98 78))
		#(#(2 121 97))
		#(#(2 146 116))
		#(#(2 86 68) #(2 87 69))
		#(#(4 101 81))
		#(#(2 116 92) #(2 117 93))
		#(#(4 133 107))
		#(#(3 145 115) #(1 146 116))
		#(#(5 109 87) #(1 110 88))
		#(#(5 122 98) #(1 123 99))
		#(#(1 135 107) #(5 136 108))
		#(#(5 150 120) #(1 151 121))
		#(#(3 141 113) #(4 142 114))
		#(#(3 135 107) #(5 136 108))
		#(#(4 144 116) #(4 145 117))
		#(#(2 139 111) #(7 140 112))
		#(#(4 151 121) #(5 152 122))
		#(#(6 147 117) #(4 148 118))
		#(#(8 132 106) #(4 133 107))
		#(#(10 142 114) #(2 143 115))
		#(#(8 152 122) #(4 153 123))
		#(#(3 147 117) #(10 148 118))
		#(#(7 146 116) #(7 147 117))
		#(#(5 145 115) #(10 146 116))
		#(#(13 145 115) #(3 146 116))
		#(#(17 145 115))
		#(#(17 145 115) #(1 146 116))
		#(#(13 145 115) #(6 146 116))
		#(#(12 151 121) #(7 152 122))
		#(#(6 151 121) #(14 152 122))
		#(#(17 152 122) #(4 153 123))
		#(#(4 152 122) #(18 153 123))
		#(#(20 147 117) #(4 148 118))
		#(#(19 148 118) #(6 149 119)))
]

{ #category : #'error correction' }
QRCodeEncoder >> chunkingM [
	^ #(#(#(1 26 16))
		#(#(1 44 28))
		#(#(1 70 44))
		#(#(2 50 32))
		#(#(2 67 43))
		#(#(4 43 27))
		#(#(4 49 31))
		#(#(2 60 38) #(2 61 39))
		#(#(3 58 36) #(2 59 37))
		#(#(4 69 43) #(1 70 44))
		#(#(1 80 50) #(4 81 51))
		#(#(6 58 36) #(2 59 37))
		#(#(8 59 37) #(1 60 38))
		#(#(4 64 40) #(5 65 41))
		#(#(5 65 41) #(5 66 42))
		#(#(7 73 45) #(3 74 46))
		#(#(10 74 46) #(1 75 47))
		#(#(9 69 43) #(4 70 44))
		#(#(3 70 44) #(11 71 45))
		#(#(3 67 41) #(13 68 42))
		#(#(17 68 42))
		#(#(17 74 46))
		#(#(4 75 47) #(14 76 48))
		#(#(6 73 45) #(14 74 46))
		#(#(8 75 47) #(13 76 48))
		#(#(19 74 46) #(4 75 47))
		#(#(22 73 45) #(3 74 46))
		#(#(3 73 45) #(23 74 46))
		#(#(21 73 45) #(7 74 46))
		#(#(19 75 47) #(10 76 48))
		#(#(2 74 46) #(29 75 47))
		#(#(10 74 46) #(23 75 47))
		#(#(14 74 46) #(21 75 47))
		#(#(14 74 46) #(23 75 47))
		#(#(12 75 47) #(26 76 48))
		#(#(6 75 47) #(34 76 48))
		#(#(29 74 46) #(14 75 47))
		#(#(13 74 46) #(32 75 47))
		#(#(40 75 47) #(7 76 48))
		#(#(18 75 47) #(31 76 48)))
]

{ #category : #'error correction' }
QRCodeEncoder >> chunkingQ [
	^ #(#(#(1 26 13))
		#(#(1 44 22))
		#(#(2 35 17))
		#(#(2 50 24))
		#(#(2 33 15) #(2 34 16))
		#(#(4 43 19))
		#(#(2 32 14) #(4 33 15))
		#(#(4 40 18) #(2 41 19))
		#(#(4 36 16) #(4 37 17))
		#(#(6 43 19) #(2 44 20))
		#(#(4 50 22) #(4 51 23))
		#(#(4 46 20) #(6 47 21))
		#(#(8 44 20) #(4 45 21))
		#(#(11 36 16) #(5 37 17))
		#(#(5 54 24) #(7 55 25))
		#(#(15 43 19) #(2 44 20))
		#(#(1 50 22) #(15 51 23))
		#(#(17 50 22) #(1 51 23))
		#(#(17 47 21) #(4 48 22))
		#(#(15 54 24) #(5 55 25))
		#(#(17 50 22) #(6 51 23))
		#(#(7 54 24) #(16 55 25))
		#(#(11 54 24) #(14 55 25))
		#(#(11 54 24) #(16 55 25))
		#(#(7 54 24) #(22 55 25))
		#(#(28 50 22) #(6 51 23))
		#(#(8 53 23) #(26 54 24))
		#(#(4 54 24) #(31 55 25))
		#(#(1 53 23) #(37 54 24))
		#(#(15 54 24) #(25 55 25))
		#(#(42 54 24) #(1 55 25))
		#(#(10 54 24) #(35 55 25))
		#(#(29 54 24) #(19 55 25))
		#(#(44 54 24) #(7 55 25))
		#(#(39 54 24) #(14 55 25))
		#(#(46 54 24) #(10 55 25))
		#(#(49 54 24) #(10 55 25))
		#(#(48 54 24) #(14 55 25))
		#(#(43 54 24) #(22 55 25))
		#(#(34 54 24) #(34 55 25)))
]

{ #category : #'initialize-release' }
QRCodeEncoder >> code: aCode [
	code := aCode
]

{ #category : #codewords }
QRCodeEncoder >> codeForAlphanumerical: char [
	char == $0 ifTrue: [ ^0 ].
	^ '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:' indexOf: char
]

{ #category : #codewords }
QRCodeEncoder >> codewords [
	^ codewords
]

{ #category : #'matrix generation' }
QRCodeEncoder >> createMasks [
	| black white whiteCanvas blackCanvas alignmentPattern |
	black := Color black.
	white := Color white.
	whiteMask := Form extent: dimension @ dimension.
	blackMask := Form extent: dimension @ dimension.
	whiteCanvas := whiteMask getCanvas.
	blackCanvas := blackMask getCanvas.
	whiteCanvas fillColor: black.
	"Add position detection + format and version information"
	whiteCanvas
		"top left, top right, and bottom left position pattern + format information"
		fillRectangle: (0@0 extent: 9@9) color: white;
		fillRectangle: (dimension - 8 @ 0 extent: 8@9) color: white;
		fillRectangle: (0 @ (dimension - 8) extent: 9@8) color: white.
	version > 6 ifTrue: [whiteCanvas
		"Extra areas for version information"
		fillRectangle: (dimension - 11 @ 0 extent: 3@6) color: white;
		fillRectangle: (0 @ (dimension - 11) extent: 6@3) color: white ].
	blackCanvas
		"top left"
		fillRectangle: (0@0 extent: 7@7) color: black;
		fillRectangle: (1@1 extent: 5@5) color: white;
		fillRectangle: (2@2 extent: 3@3) color: black;
		"top right and bottom left"
		fillRectangle: (dimension - 7 @ 0 extent: 7@7) color: black;
		fillRectangle: (0 @ (dimension - 7) extent: 7@7) color: black;
		fillRectangle: (dimension - 6 @ 1 extent: 5@5) color: white;
		fillRectangle: (1 @ (dimension - 6) extent: 5@5) color: white;
		fillRectangle: (dimension - 5 @ 2 extent: 3@3) color: black;
		fillRectangle: (2 @ (dimension - 5) extent: 3@3) color: black.
	"Add timing patterns"
	whiteCanvas fillRectangle: (0@6 extent: dimension @ 1) color: white.
	whiteCanvas fillRectangle: (6@0 extent: 1 @ dimension) color: white.
	8 to: dimension - 9 by: 2 do: [ :index |
		blackCanvas fillRectangle: (index @ 6 extent: 1@1) color: black.
		blackCanvas fillRectangle: (6 @ index extent: 1@1) color: black ].
	"Add alignment patterns"
	alignmentPattern := self alignmentPattern.
	alignmentPattern size > 2 ifTrue: [
		(alignmentPattern copyFrom: 2 to: alignmentPattern size - 1) do: [ :index |
			"The top alignment pattern"
			whiteCanvas fillRectangle: (index - 2 @ 4 extent: 5@5) color: white.
			blackCanvas fillRectangle: (index - 2 @ 4 extent: 5@5) color: black.
			blackCanvas fillRectangle: (index - 1 @ 5 extent: 3@3) color: white.
			blackCanvas fillRectangle: (index @ 6 extent: 1@1) color: black.
			"The left alignment pattern"
			whiteCanvas fillRectangle: (4 @ (index - 2 )extent: 5@5) color: white.
			blackCanvas fillRectangle: (4 @ (index - 2 ) extent: 5@5) color: black.
			blackCanvas fillRectangle: (5 @ (index - 1) extent: 3@3) color: white.
			blackCanvas fillRectangle: (6 @ index extent: 1@1) color: black ] ].
	"The other ones"
	alignmentPattern isEmpty ifFalse: [
		alignmentPattern := alignmentPattern copyFrom: 2 to: alignmentPattern size ].
	alignmentPattern do: [ :x |
		alignmentPattern do: [ :y |
			whiteCanvas fillRectangle: (x - 2 @ (y - 2) extent: 5@5) color: white.
			blackCanvas fillRectangle: (x - 2 @ (y - 2) extent: 5@5) color: black.
			blackCanvas fillRectangle: (x - 1 @ (y - 1) extent: 3@3) color: white.
			blackCanvas fillRectangle: (x @ y extent: 1@1) color: black ] ]
]

{ #category : #capacity }
QRCodeEncoder >> dataCapacity [
	^ (self dataCapacityForCorrection: code errorCorrection) at: version
]

{ #category : #capacity }
QRCodeEncoder >> dataCapacityForCorrection: correction [
	^ correction caseOf: {
		[ $L ] -> [ #(19 34 55 80 108 136 156 194 232 274 324 370 428 461 523 589 647 721 795 861 932 1006 1094 1174 1276 1370 1468 1531 1631 1735 1843 1955 2071 2191 2306 2434 2566 2702 2812 2956) ].
		[ $M ] -> [ #(16 28 44 64 86 108 124 154 182 216 254 290 334 365 415 453 507 563 627 669 714 782 860 914 1000 1062 1128 1193 1267 1373 1455 1541 1631 1725 1812 1914 1992 2102 2216 2334) ].
		[ $Q ] -> [ #(13 22 34 48 62 76 88 110 132 154 180 206 244 261 295 325 367 397 445 485 512 568 614 664 718 754 808 871 911 985 1033 1115 1171 1231 1286 1354 1426 1502 1582 1666) ].
		[ $H ] -> [#(9 16 26 36 46 60 66 86 100 122 140 158 180 197 223 253 283 313 341 385 406 442 464 514 538 596 628 661 701 745 793 845 901 961 986 1054 1096 1142 1222 1276) ] }
]

{ #category : #'matrix generation' }
QRCodeEncoder >> dimension: anInteger [
	dimension := anInteger
]

{ #category : #'error correction' }
QRCodeEncoder >> errorCorrections [
	^ #($L $M $Q $H)
]

{ #category : #'error correction' }
QRCodeEncoder >> finalCodewords [
	^ finalCodewords
]

{ #category : #'error correction' }
QRCodeEncoder >> generatorPolynomial: size [
	^ GeneratorPolynomials at: size ifAbsentPut: [ ByteArray gfPolynomial: size ]
]

{ #category : #'initialize-release' }
QRCodeEncoder >> initializeCode [
	self initializeEncoding.
	self initializeVersion.
	self initializeCodewords.
	self initializeErrorCorrection.
	self initializeMatrixGeneration.
	self initializeMasking
]

{ #category : #codewords }
QRCodeEncoder >> initializeCodewords [
	| writer |
	codewords := ByteArray new: self dataCapacity.
	writer := BitWriter on: codewords.
	code encoding caseOf: {
		[ #numeric ] -> [
			"Mode"
			writer nextPut: 1 bits: 4.
			"Number of bits"
			version < 10
				ifTrue: [ writer nextPut: string size bits: 10 ]
				ifFalse: [ version < 27
					ifTrue: [ writer nextPut: string size bits: 12 ]
					ifFalse: [ writer nextPut: string size bits: 14 ] ].
			writer nextPutNumeric: string ].
		[ #alphanumeric ] -> [
			"Mode"
			writer nextPut: 2 bits: 4.
			"Number of bits"
			version < 10
				ifTrue: [ writer nextPut: string size bits: 9 ]
				ifFalse: [ version < 27
					ifTrue: [ writer nextPut: string size bits: 11 ]
					ifFalse: [ writer nextPut: string size bits: 13 ] ].
			writer nextPutAlphanumeric: string ].
		[ #byte ] -> [
			code usesEciMode ifTrue: [
				"Specify ECI mode"
				writer nextPut: 7 bits: 4.
				"Add the ECI assignment number"
				code eci < 128
					ifTrue: [ 
						writer nextPut: 0 bits: 1.
						writer nextPut: code eci bits: 7 ]
					ifFalse: [ code eci < 16384
						ifTrue: [ 
							writer nextPut: 2 bits: 2.
							writer nextPut: code eci bits: 14 ]
						ifFalse: [ 
							writer nextPut: 6 bits: 3.
							writer nextPut: code eci bits: 21 ] ] ].
			"Specify byte encoding"
			writer nextPut: 4 bits: 4.
			"Number of bits"
			version < 10
				ifTrue: [ writer nextPut: string size bits: 8 ]
				ifFalse: [ writer nextPut: string size bits: 16 ].
			writer nextPutByte: string ].
		[ #kanji ] -> [
			"Mode"
			writer nextPut: 8 bits: 8.
			"Number of bits"
			version < 10
				ifTrue: [ writer nextPut: string size bits: 8 ]
				ifFalse: [ version < 27
					ifTrue: [ writer nextPut: string size bits: 10 ]
					ifFalse: [ writer nextPut: string size bits: 12 ] ].
			writer nextPutKanji: string ] }.
	"Terminate the sequence / Skip to next byte for error correction"
	writer bitsLeft > 3 ifTrue: [ writer nextPut: 0 bits: 4 ].
	"Add error correction sequence, alternating between 11101100 and 00010001".
	1 to: writer bytesLeft do: [ :index |
		writer nextPut: (index odd ifTrue: [ 2r11101100 ] ifFalse: [ 2r00010001 ]) ]
]

{ #category : #encoding }
QRCodeEncoder >> initializeEncoding [
	| index |
	code eci ifNotNil: [ 
		"If an ECI is specified, then use byte encoding."
		code encoding: #byte.
		^self ].
	string := code string.
	string isEmpty ifTrue: [
		code encoding: #numeric.
		^self ].
	index := 1.
	[ (string at: index) isDigit ] whileTrue: [
		index := index + 1.
		index > string size ifTrue: [
			code encoding: #numeric.
			^self ] ].
	[ (string at: index) isQRCodeAlphanumeric ] whileTrue: [
		index := index + 1.
		index > string size ifTrue: [
			code encoding: #alphanumeric.
			^self ] ].
	(string allSatisfy: [ :char | char isKanji ])
		ifTrue: [ code encoding: #kanji ]
		ifFalse: [
			code encoding: #byte.
			(string anySatisfy: [ :char | char asciiValue > 127 ])
				ifTrue: [ "Use UTF8 Encoding"
					string := string convertToEncoding: 'utf8'.
					code eci: 26 ]
				ifFalse: [ "Use ISO Latin 1"
					code eci: 3 ] ]
]

{ #category : #'error correction' }
QRCodeEncoder >> initializeErrorCorrection [
	| dataCodewords errorCorrectionCodewords bytePosition dataWidth errorCorrectionWidth data errorCorrection index |
	"Generate the data chunks and the error correction chunks"
	dataCodewords := OrderedCollection new.
	errorCorrectionCodewords := OrderedCollection new.
	bytePosition := 1.
	dataWidth := 0.
	errorCorrectionWidth := 0.
	self chunking do: [ :arr |
		arr first timesRepeat: [
			data := codewords copyFrom: bytePosition to: bytePosition + arr third - 1.
			bytePosition := bytePosition + arr third.
			errorCorrection := data dividedByGFPolynomial: (self generatorPolynomial: arr second - arr third).
			dataCodewords add: data.
			errorCorrectionCodewords add: errorCorrection.
			dataWidth := dataWidth max: data size.
			errorCorrectionWidth := errorCorrectionWidth max: errorCorrection size ] ].
	"Place the data and error correction chunks into finalCodewords"
	finalCodewords := ByteArray new: self totalCapacity.
	index := 0.
	1 to: dataWidth do: [ :column |
		dataCodewords do: [ :row |
			row size >= column ifTrue: [
				index := index + 1.
				finalCodewords at: index put: (row at: column) ] ] ].
	1 to: errorCorrectionWidth do: [ :column |
		errorCorrectionCodewords do: [ :row |
			row size >= column ifTrue: [
				index := index + 1.
				finalCodewords at: index put: (row at: column) ] ] ]
]

{ #category : #masking }
QRCodeEncoder >> initializeMasking [
	| symbols errorCorrection format bitVersion count finalForm |
	symbols := self maskedSymbols.
	finalForm := symbols detectMin: [ :entry | self penaltyScoreSymbol: entry ].
	"(symbols collect: [ :entry | self penaltyScoreSymbol: entry ]) inspect."
	"Generate the format information"
	format := code errorCorrection caseOf: {
		[ $L ] -> [ 1 ].
		[ $M ] -> [ 0 ].
		[ $Q ] -> [ 3 ].
		[ $H ] -> [ 2 ] }.
	format := (format * 8) +  (symbols indexOf: finalForm) - 1 * 1024.
	errorCorrection := format.
	14 to: 10 by: -1 do: [ :i |
		errorCorrection >= (2 raisedTo: i) ifTrue: [
			errorCorrection := (2 raisedTo: i - 10) * 1335 bitXor: errorCorrection ] ].
	format := (format + errorCorrection) bitXor: 2r101010000010010.
	"Place the format information"
	bb := BitBlt bitPokerToForm: finalForm.
	{ { 8 @ 0. dimension - 1 @ 8 }.
		{ 8 @ 1. dimension - 2 @ 8 }.
		{ 8 @ 2. dimension - 3 @ 8 }.
		{ 8 @ 3. dimension - 4 @ 8 }.
		{ 8 @ 4. dimension - 5 @ 8 }.
		{ 8 @ 5. dimension - 6 @ 8 }.
		{ 8 @ 7. dimension - 7 @ 8 }.
		{ 8 @ 8. dimension - 8 @ 8 }.
		{ 7 @ 8. 8 @ (dimension - 7) }.
		{ 5 @ 8. 8 @ (dimension - 6) }.
		{ 4 @ 8. 8 @ (dimension - 5) }.
		{ 3 @ 8. 8 @ (dimension - 4) }.
		{ 2 @ 8. 8 @ (dimension - 3) }.
		{ 1 @ 8. 8 @ (dimension - 2) }.
		{ 0 @ 8. 8 @ (dimension - 1) } } withIndexDo: [ :arr :index |
			((2 raisedTo: index - 1) bitAnd: format) = 0 ifFalse: [
				arr do: [ :point |
					bb pixelAt: point put: 1 ] ] ].
	"Add dark module"
	bb pixelAt: 8 @ (dimension - 8) put: 1.
	"Version information"
	version > 6 ifTrue: [
		"Generate the bitVersion information"
		bitVersion := version * 2r1000000000000.
		errorCorrection := bitVersion.
		17 to: 12 by: -1 do: [ :i |
			errorCorrection >= (2 raisedTo: i) ifTrue: [
				errorCorrection := (2 raisedTo: i - 12) * 7973 bitXor: errorCorrection ] ].
		bitVersion := bitVersion + errorCorrection.
		"Place the bitVersion information"
		count := 0.
		0 to: 5 do: [ :x |
			dimension - 11 to: dimension - 9 do: [ :y |
				((2 raisedTo: count) bitAnd: bitVersion) > 0 ifTrue: [
					bb pixelAt: x @ y put: 1.
					bb pixelAt: y @ x put: 1 ].
				count := count + 1 ] ] ].
	code form: finalForm
]

{ #category : #'matrix generation' }
QRCodeEncoder >> initializeMatrixGeneration [
	| bbMatrix |
	self dimension: version * 4 + 17.
	matrix := Form extent: dimension @ dimension.
	self createMasks.
	"Fill Matrix with finalCodewords (using the white mask to avoid writing to non-data areas"
	matrixPosition := dimension - 2 @ dimension.
	bb := BitBlt bitPeekerFromForm: whiteMask.
	bbMatrix := BitBlt bitPokerToForm: matrix.
	self placeBytes: finalCodewords matrix: bbMatrix
]

{ #category : #version }
QRCodeEncoder >> initializeVersion [
	"Determine the version to use."
	| size versions |
	size := string size.
	(self errorCorrections includes: code errorCorrection)
		ifTrue: [ "Error correction has already been specified"
			version := code encoding caseOf: {
				[ #numeric ] -> [ self versionNumericSize: size correction: code errorCorrection ].
				[ #alphanumeric ] -> [ self versionAlphanumericSize: size correction: code errorCorrection ].
				[ #byte ] -> [ code usesEciMode
					ifTrue: [ self versionEciSize: size correction: code errorCorrection ]
					ifFalse: [ self versionByteSize: size correction: code errorCorrection ] ].
				[ #kanji ] -> [ self versionKanjiSize: size correction: code errorCorrection ] }.
			version > self maxVersion ifTrue: [ self error: 'This string is too long to be encoded for the specified error correction.' ] ]
		ifFalse: [ "Choose the error correction that gets the smallest size but the highest error correction"
			versions := code encoding caseOf: {
				[ #numeric ] -> [ self errorCorrections collect: [ :char | self versionNumericSize: size correction: char ] ].
				[ #alphanumeric ] -> [ self errorCorrections collect: [ :char | self versionAlphanumericSize: size correction: char ] ].
				[ #byte ] -> [code usesEciMode
					ifTrue: [ self errorCorrections collect: [ :char | self versionEciSize: size correction: char ] ]
					ifFalse: [ self errorCorrections collect: [ :char | self versionByteSize: size correction: char ] ] ].
				[ #kanji ] -> [ self errorCorrections collect: [ :char | self versionKanjiSize: size correction: char ] ] }.
			version := versions first.
			version > self maxVersion ifTrue: [ self error: 'This string is too long to be encoded.' ].
			code errorCorrection: (self errorCorrections at: self errorCorrections size + 1 - (versions reversed indexOf: version))  ]
]

{ #category : #capacity }
QRCodeEncoder >> kanjiCapacityForCorrection: correction [
	^ correction caseOf: {
		[ $L ] -> [ #(10 20 32 48 65 82 95 118 141 167 198 226 262 282 320 361 397 442 488 528 572 618 672 721 784 842 902 940 1002 1066 1132 1201 1273 1347 1417 1496 1577 1661 1729 1817) ].
		[ $M ] -> [ #(8 16 26 38 52 65 75 93 111 131 155 177 204 223 254 277 310 345 384 410 438 480 528 561 614 652 692 732 778 843 894 947 1002 1060 1113 1176 1224 1292 1362 1435) ].
		[ $Q ] -> [ #(7 12 20 28 37 45 53 66 80 93 109 125 149 159 180 198 224 243 272 297 314 348 376 407 440 462 496 534 559 604 634 684 719 756 790 832 876 923 972 1024) ].
		[ $H ] -> [ #(4 8 15 21 27 36 39 52 60 74 85 96 109 120 136 154 173 191 208 235 248 270 284 315 330 365 385 405 430 457 486 518 553 590 605 647 673 701 750 784) ] }
]

{ #category : #masking }
QRCodeEncoder >> maskedSymbols [
	| form |
	^ self maskingGenerators collect: [ :generator |
		form := Form extent: dimension @ dimension.
		"Generate the top left 12 x 12"
		bb := BitBlt bitPokerToForm: form.
		0 to: 11 do: [ :x |
			0 to: 11 do: [ :y |
				(generator value: y value: x) ifTrue: [
					bb pixelAt: x@y put: 1 ] ] ].
		"Based on top left 12 x 12, fill the rest"
		bb := BitBlt toForm: form.
		bb sourceForm: form.
		bb combinationRule: Form over.
		bb sourceRect: (0@0 extent: 12@12).
		1 to: dimension - 1 // 12 do: [ :index |
			bb destOrigin: index * 12 @ 0.
			bb copyBits ].
		bb sourceRect: (0@0 extent: dimension @ 12).
		1 to: dimension - 1 // 12 do: [ :index |
			bb destOrigin: 0 @ (index * 12).
			bb copyBits ].
		bb := BitBlt toForm: form.
		"XOR it with the matrix."
		bb sourceForm: matrix.
		bb combinationRule: Form reverse.
		bb copyBits.
		"AND it with the white mask."
		bb sourceForm: whiteMask.
		bb combinationRule: Form and.
		bb copyBits.
		"OR it with the black mask."
		bb sourceForm: blackMask.
		bb combinationRule: Form under.
		bb copyBits.
		form ]
]

{ #category : #masking }
QRCodeEncoder >> maskingGenerators [
	^{ [ :i :j | i + j \\ 2 = 0 ].
		[ :i :j | i \\ 2 = 0 ].
		[ :i :j | j \\ 3 = 0 ].
		[ :i :j | i + j \\ 3 = 0 ].
		[ :i :j | (i // 2) + (j // 3) \\ 2 = 0 ].
		[ :i :j | (i * j \\ 2) + (i * j \\ 3) = 0 ].
		[ :i :j | i * j + (i * j \\ 3) \\ 2 = 0 ].
		[ :i :j | (i * j \\ 3) + i + j \\ 2 = 0 ] }
]

{ #category : #version }
QRCodeEncoder >> maxVersion [
	"The maximum version number"
	^ 40
]

{ #category : #'matrix generation' }
QRCodeEncoder >> nextMatrixPosition [
	| x shift |
	["Try next test position"
		x := matrixPosition x.
		shift := x < 7
			ifTrue: [ 
				x = 6 ifTrue: [ matrixPosition := 5 @ matrixPosition y ].
				x odd ]
			ifFalse: [ x even ].
		matrixPosition := shift
			ifTrue: [ matrixPosition - (1@0) ]
			ifFalse: [ (x // 2) odd
				ifTrue: [ matrixPosition y = 0
					ifTrue: [ matrixPosition + (-1 @ 0) ]
					ifFalse: [ matrixPosition + (1 @ -1) ] ]
				ifFalse: [ matrixPosition y + 1 = dimension
					ifTrue: [ matrixPosition + (-1 @ 0) ]
					ifFalse: [ matrixPosition + (1 @ 1) ] ] ].
		(bb pixelAt: matrixPosition) = 1] whileFalse.
	^matrixPosition
]

{ #category : #capacity }
QRCodeEncoder >> numericCapacityForCorrection: correction [
	^ correction caseOf: {
		[ $L ] -> [ #(41 77 127 187 255 322 370 461 552 652 772 883 1022 1101 1250 1408 1548 1725 1903 2061 2232 2409 2620 2812 3057 3283 3517 3669 3909 4158 4417 4686 4965 5253 5529 5836 6153 6479 6743 7089) ].
		[ $M ] -> [ #(34 63 101 149 202 255 293 365 432 513 604 691 796 871 991 1082 1212 1346 1500 1600 1708 1872 2059 2188 2395 2544 2701 2857 3035 3289 3486 3693 3909 4134 4343 4588 4775 5039 5313 5596) ].
		[ $Q ] -> [ #(27 48 77 111 144 178 207 259 312 364 427 489 580 621 703 775 876 948 1063 1159 1224 1358 1468 1588 1718 1804 1933 2085 2181 2358 2473 2670 2805 2949 3081 3244 3417 3599 3791 3993) ].
		[ $H ] -> [ #(17 34 58 82 106 139 154 202 235 288 331 374 427 468 530 602 674 746 813 919 969 1056 1108 1228 1286 1425 1501 1581 1677 1782 1897 2022 2157 2301 2361 2524 2625 2735 2927 3057) ] }
]

{ #category : #masking }
QRCodeEncoder >> penaltyScoreSymbol: aForm [
	"Return the penalty score for the symbol, according to the following criteria:
	Penalty 1: A penalty (n-2) for each group of five or more same-colored modules in a row (or column)
	Penalty 2: A penalty (3) for each 2x2 area of same-colored modules
	Penalty 3: A penalty (40) if there are patterns that look similar to the finder patterns
	Penalty 4: A penalty based on the percentage of tiles that are black / white
	NOTE: This method has been optimized for speed as it is the anchor on QRCode generation performance"
	| penalty run count current runTest finderPattern last |
	bb := BitBlt bitPeekerFromForm: aForm.
	penalty := 0.
	"Go through each row.
	Use this to assess Penalty 2"
	0 to: dimension - 2 do: [ :row |
		current := bb pixelAt: 0 @ row.
		last := current.
		run := 1.
		runTest := current.
		finderPattern := current.
		1 to: 9 do: [ :column |
			current := bb pixelAt: column @ row.
			last = current
				ifTrue: [ (bb pixelAt: column @ (row + 1)) = last
					ifTrue: [ (bb pixelAt: column - 1 @ (row + 1)) = last
						ifTrue: [ penalty := penalty + 3 ] ] ]
				ifFalse: [ last := current ].
			runTest = current
				ifTrue: [ run := run + 1 ]
				ifFalse: [ 
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					runTest := current ].
			finderPattern := finderPattern * 2 + current ].
		10 to: dimension - 1 do: [ :column |
			current := bb pixelAt: column @ row.
			last = current
				ifTrue: [ (bb pixelAt: column @ (row + 1)) = last
					ifTrue: [ (bb pixelAt: column - 1 @ (row + 1)) = last
						ifTrue: [ penalty := penalty + 3 ] ] ]
				ifFalse: [ last := current ].
			runTest = current
				ifTrue: [ run := run + 1 ]
				ifFalse: [ 
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					runTest := current ].
			finderPattern := finderPattern * 2 + current \\ 2048.
			(finderPattern = 1488 or: [ finderPattern = 93 ]) ifTrue: [ penalty := penalty + 40 ] ].
		run > 4 ifTrue: [  penalty := penalty + run - 2 ] ].
	"Process the last row without Penalty 2"
	current := bb pixelAt: 0 @ (dimension - 1).
	run := 1.
	runTest := current.
	finderPattern := current.
	1 to: 9 do: [ :column |
		current := bb pixelAt: column @ (dimension - 1).
		runTest = current
			ifTrue: [ run := run + 1 ]
			ifFalse: [ 
				run > 4 ifTrue: [ penalty := penalty + run - 2 ].
				run := 1.
				runTest := current ].
		finderPattern := finderPattern * 2 + current ].
	10 to: dimension - 1 do: [ :column |
		current := bb pixelAt: column @ (dimension - 1).
		runTest = current
			ifTrue: [ run := run + 1 ]
			ifFalse: [ 
				run > 4 ifTrue: [ penalty := penalty + run - 2 ].
				run := 1.
				runTest := current ].
		finderPattern := finderPattern * 2 + current \\ 2048.
		(finderPattern = 1488 or: [ finderPattern = 93 ]) ifTrue: [ penalty := penalty + 40 ] ].
	run > 4 ifTrue: [  penalty := penalty + run - 2 ].

	"Go through each column.
	Use this to assess Penalty 4"
	count := 0.	
	0 to: dimension - 1 do: [ :column |
		current := bb pixelAt: column @ 0.
		count := count + current.
		run := 1.
		runTest := current.
		finderPattern := current.
		1 to: 9 do: [ :row |
			current := bb pixelAt: column @ row.
			count := count + current.
			runTest = current
				ifTrue: [ run := run + 1 ]
				ifFalse: [ 
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					runTest := current ].
			finderPattern := finderPattern * 2 + current ].
		10 to: dimension - 1 do: [ :row |
			current := bb pixelAt: column @ row.
			count := count + current.
			runTest = current
				ifTrue: [ run := run + 1 ]
				ifFalse: [ 
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					runTest := current ].
			finderPattern := finderPattern * 2 + current \\ 2048.
			(finderPattern = 1488 or: [ finderPattern = 93 ]) ifTrue: [ penalty := penalty + 40 ] ].
		run > 4 ifTrue: [  penalty := penalty + run - 2 ] ].
	penalty := ((count / dimension squared - 0.5) abs * 20) floor * 10 + penalty.
	
	^penalty
]

{ #category : #masking }
QRCodeEncoder >> penaltyScoreUnoptimizedSymbol: aForm [
	"Return the penalty score for the symbol"
	| penalty run color test count |
	bb := BitBlt bitPeekerFromForm: aForm.
	penalty := 0.
	"Penalty 1: A penalty for each group of five or more same-colored modules in a row (or column)"
	0 to: dimension - 1 do: [ :row |
		run := 0.
		color := nil.
		0 to: dimension - 1 do: [ :column |
			test := bb pixelAt: column @ row.
			test = color
				ifTrue: [ run := run + 1 ]
				ifFalse: [
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					color := test ] ].
		run > 4 ifTrue: [ penalty := penalty + run - 2 ] ].
	0 to: dimension - 1 do: [ :column |
		run := 0.
		color := nil.
		0 to: dimension - 1 do: [ :row |
			test := bb pixelAt: column @ row.
			test = color
				ifTrue: [ run := run + 1 ]
				ifFalse: [
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					color := test ] ].
		run > 4 ifTrue: [ penalty := penalty + run - 2 ] ].
	"Penalty 2: A penalty for each 2x2 area of same-colored modules"
	0 to: dimension - 2 do: [ :row |
		color := bb pixelAt: 0@row.
		1 to: dimension - 1 do: [ :column |
			test := bb pixelAt: column@row.
			test = color
				ifTrue: [ ((bb pixelAt: column @ (row + 1)) = color and: [(bb pixelAt: column - 1 @ (row + 1)) = color])
					ifTrue: [ penalty := penalty + 3 ] ]
				ifFalse: [ color := test ] ] ].
	"Penalty 3: A large penalty if there are patterns that look similar to the finder patterns."
	0 to: dimension - 1 do: [ :row |
		test := bb pixelAt: 0@row.
		1 to: 9 do: [ :column |
			test := test * 2 + (bb pixelAt: column@row) ].
		10 to: dimension - 1 do: [ :column |
			test := test * 2 + (bb pixelAt: column@row) \\ 2048.
			(test = 1488 or: [ test = 93 ]) ifTrue: [ penalty := penalty + 40 ] ] ].
	0 to: dimension - 1 do: [ :column |
		test := bb pixelAt: column@0.
		1 to: 9 do: [ :row |
			test := test * 2 + (bb pixelAt: column@row) ].
		10 to: dimension - 1 do: [ :row |
			test := test * 2 + (bb pixelAt: column@row) \\ 2048.
			(test = 1488 or: [ test = 93 ]) ifTrue: [ penalty := penalty + 40 ] ] ].
	"Penalty 4: A penalty based on the percentage of tiles that are black / white"
	count := 0.
	0 to: dimension - 1 do: [ :row |
		0 to: dimension - 1 do: [ :column |
			count := count + (bb pixelAt: column@row) ] ].
	penalty := ((count / dimension squared - 0.5) abs * 20) floor * 10 + penalty.
	
	^penalty
]

{ #category : #'matrix generation' }
QRCodeEncoder >> placeBytes: bytes matrix: bbMatrix [
	| test |
	bytes do: [ :byte |
		test := byte.
		1 to: 8 do: [ :index |
			self nextMatrixPosition.
			test > 127 ifTrue: [
				bbMatrix pixelAt: matrixPosition put: 1.
				test := test - 128 ].
			test := test * 2 ] ]
]

{ #category : #capacity }
QRCodeEncoder >> totalCapacity [
	^ self totalCapacityVersion: version
]

{ #category : #capacity }
QRCodeEncoder >> totalCapacityVersion: index [
	^ #(26 44 70 100 134 172 196 242 292 346 404 466 532 581 655 733 815 901 991 1085 1156 1258 1364 1474 1588 1706 1828 1921 2051 2185 2323 2465 2611 2761 2876 3034 3196 3362 3532 3706) at: index
]

{ #category : #version }
QRCodeEncoder >> version [
	^ version
]

{ #category : #version }
QRCodeEncoder >> versionAlphanumericSize: size correction: correction [
	(self alphanumericCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [ ^ index ] ].
	^ 100
]

{ #category : #version }
QRCodeEncoder >> versionByteSize: size correction: correction [
	(self byteCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [ ^ index ] ].
	^ 100
]

{ #category : #version }
QRCodeEncoder >> versionEciSize: size correction: correction [
	| totalSize dataCapacity |
	"Convert from ECI byte size to total capacity."
	totalSize := code eci < 128
		ifTrue: [ 3 + size ]
		ifFalse: [ code eci < 16384
			ifTrue: [ 4 + size ]
			ifFalse: [ 5 + size ] ].
	dataCapacity := self dataCapacityForCorrection: correction.
	totalSize > (dataCapacity at: 9) ifTrue: [
		"Add a bit for versions 10+"
		totalSize := totalSize + 1 ].
	dataCapacity withIndexDo: [ :capacity :index |
		capacity >= totalSize ifTrue: [ ^ index ] ].
	^ 100
]

{ #category : #version }
QRCodeEncoder >> versionKanjiSize: size correction: correction [
	(self kanjiCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [ ^ index ] ].
	^ 100
]

{ #category : #version }
QRCodeEncoder >> versionNumericSize: size correction: correction [
	(self numericCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [ ^ index ] ].
	^ 100
]
