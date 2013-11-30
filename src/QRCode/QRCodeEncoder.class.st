"
This encoder is implemented according to the specifications for QR Code Model 2 (ISO/IEC 18004:2000(E)). Though it is largely complete, it does not implement the following:

(1) Mixing Modes. To create more compact results, encoding modes can be mixed. So, '0123456789ABCDEF' could be encoded so that '0123456789' is encoded in numeric mode while 'ABCDEF' is encoded in alphanumeric mode. Given the overhead in switching modes, this technique is seldom productive.

(2) Structured Append Mode. This allows you to encode a longer message over multiple QR codes.

(3) Extended Channel Interpretation (ECI) Mode. This allows you to specify an encoding, such as UTF-8, and can therefore encode a larger character set. This encoder does support byte mode, which handles the ISO-8859-1 character set.

For evaluating the penalties for a specific mask, the specification is slightly ambiguous. This encoder implements the algorithm proposed here: 
http://www.thonky.com/qr-code-tutorial/
That site is a good guide to the QRCode standard.

This encoder leaves artifacts of the encoding process in the instance variables. These are used by its test class.
"
Class {
	#name : #QRCodeEncoder,
	#superclass : #Object,
	#instVars : [
		'code',
		'codewords',
		'bytePosition',
		'bitPosition',
		'finalCodewords',
		'whiteMask',
		'blackMask',
		'bb',
		'matrix',
		'matrixPosition',
		'dimension'
	],
	#category : #'QRCode-Core'
}

{ #category : #'instance creation' }
QRCodeEncoder class >> initializeCode: aQRCode [
	^self new
		code: aQRCode;
		initializeCode;
		yourself
]

{ #category : #'matrix generation' }
QRCodeEncoder >> alignmentPattern [
	^self alignmentPatternVersion: code version
]

{ #category : #'matrix generation' }
QRCodeEncoder >> alignmentPatternVersion: version [
	^#(#()
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

{ #category : #'error correction' }
QRCodeEncoder >> alphaForNumber: number [
	^#[0 1 25 2 50 26 198 3 223 51 238 27 104 199 75 4 100 224 14 52 141 239 129 28 193 105 248 200 8 76 113 5 138 101 47 225 36 15 33 53 147 142 218 240 18 130 69 29 181 194 125 106 39 249 185 201 154 9 120 77 228 114 166 6 191 139 98 102 221 48 253 226 152 37 179 16 145 34 136 54 208 148 206 143 150 219 189 241 210 19 92 131 56 70 64 30 66 182 163 195 72 126 110 107 58 40 84 250 133 186 61 202 94 155 159 10 21 121 43 78 212 229 172 115 243 167 87 7 112 192 247 140 128 99 13 103 74 222 237 49 197 254 24 227 165 153 119 38 184 180 124 17 68 146 217 35 32 137 46 55 63 209 91 149 188 207 205 144 135 151 178 220 252 190 97 242 86 211 171 20 42 93 158 132 60 57 83 71 109 65 162 31 45 67 216 183 123 164 118 196 23 73 236 127 12 111 246 108 161 59 82 41 157 85 170 251 96 134 177 187 204 62 90 203 89 95 176 156 169 160 81 11 245 22 235 122 117 44 215 79 174 213 233 230 231 173 232 116 214 244 234 168 80 88 175] at: number
]

{ #category : #capacity }
QRCodeEncoder >> alphanumericCapacityForCorrection: correction [
	^correction caseOf: {
		[$L]->[#(25 47 77 114 154 195 224 279 335 395 468 535 619 667 758 854 938 1046 1153 1249 1352 1460 1588 1704 1853 1990 2132 2223 2369 2520 2677 2840 3009 3183 3351 3537 3729 3927 4087 4296)].
		[$M]->[#(20 38 61 90 122 154 178 221 262 311 366 419 483 528 600 656 734 816 909 970 1035 1134 1248 1326 1451 1542 1637 1732 1839 1994 2113 2238 2369 2506 2632 2780 2894 3054 3220 3391)].
		[$Q]->[#(16 29 47 67 87 108 125 157 189 221 259 296 352 376 426 470 531 574 644 702 742 823 890 963 1041 1094 1172 1263 1322 1429 1499 1618 1700 1787 1867 1966 2071 2181 2298 2420)].
		[$H]->[#(10 20 35 50 64 84 93 122 143 174 200 227 259 283 321 365 408 452 493 557 587 640 672 744 779 864 910 958 1016 1080 1150 1226 1307 1394 1431 1530 1591 1658 1774 1852)]}
]

{ #category : #capacity }
QRCodeEncoder >> byteCapacityForCorrection: correction [
	^correction caseOf: {
		[$L]->[#(17 32 53 78 106 134 154 192 230 271 321 367 425 458 520 586 644 718 792 858 929 1003 1091 1171 1273 1367 1465 1528 1628 1732 1840 1952 2068 2188 2303 2431 2563 2699 2809 2953)].
		[$M]->[#(14 26 42 62 84 106 122 152 180 213 251 287 331 362 412 450 504 560 624 666 711 779 857 911 997 1059 1125 1190 1264 1370 1452 1538 1628 1722 1809 1911 1989 2099 2213 2331)].
		[$Q]->[#(11 20 32 46 60 74 86 108 130 151 177 203 241 258 292 322 364 394 442 482 509 565 611 661 715 751 805 868 908 982 1030 1112 1168 1228 1283 1351 1423 1499 1579 1663)].
		[$H]->[#(7 14 24 34 44 58 64 84 98 119 137 155 177 194 220 250 280 310 338 382 403 439 461 511 535 593 625 658 698 742 790 842 898 958 983 1051 1093 1139 1219 1273)]}
]

{ #category : #'error correction' }
QRCodeEncoder >> chunking [
	^(code errorCorrection caseOf: {
		[$L]->[self chunkingL].
		[$M]->[self chunkingM].
		[$Q]->[self chunkingQ].
		[$H]->[self chunkingH]}) at: code version
]

{ #category : #'error correction' }
QRCodeEncoder >> chunkingH [
	^#(#(#(1 26 9))
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
	^#(#(#(1 26 19))
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
	^#(#(#(1 26 16))
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
	^#(#(#(1 26 13))
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
	char == $0 ifTrue: [^0].
	^'123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:' indexOf: char
]

{ #category : #codewords }
QRCodeEncoder >> codewords [
	^codewords
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
	code version > 6 ifTrue: [whiteCanvas
		"Extra areas for version information"
		fillRectangle: (dimension - 11 @ 0 extent: 3@6) color: white;
		fillRectangle: (0 @ (dimension - 11) extent: 6@3) color: white].
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
		blackCanvas fillRectangle: (6 @ index extent: 1@1) color: black].
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
			blackCanvas fillRectangle: (6 @ index extent: 1@1) color: black]].
	"The other ones"
	alignmentPattern isEmpty ifFalse: [
		alignmentPattern := alignmentPattern copyFrom: 2 to: alignmentPattern size].
	alignmentPattern do: [ :x |
		alignmentPattern do: [ :y |
			whiteCanvas fillRectangle: (x - 2 @ (y - 2) extent: 5@5) color: white.
			blackCanvas fillRectangle: (x - 2 @ (y - 2) extent: 5@5) color: black.
			blackCanvas fillRectangle: (x - 1 @ (y - 1) extent: 3@3) color: white.
			blackCanvas fillRectangle: (x @ y extent: 1@1) color: black]]
]

{ #category : #capacity }
QRCodeEncoder >> dataCapacity [
	^(self dataCapacityForCorrection: code errorCorrection) at: code version
]

{ #category : #capacity }
QRCodeEncoder >> dataCapacityForCorrection: correction [
	^correction caseOf: {
		[$L]->[#(19 34 55 80 108 136 156 194 232 274 324 370 428 461 523 589 647 721 795 861 932 1006 1094 1174 1276 1370 1468 1531 1631 1735 1843 1955 2071 2191 2306 2434 2566 2702 2812 2956)].
		[$M]->[#(16 28 44 64 86 108 124 154 182 216 254 290 334 365 415 453 507 563 627 669 714 782 860 914 1000 1062 1128 1193 1267 1373 1455 1541 1631 1725 1812 1914 1992 2102 2216 2334)].
		[$Q]->[#(13 22 34 48 62 76 88 110 132 154 180 206 244 261 295 325 367 397 445 485 512 568 614 664 718 754 808 871 911 985 1033 1115 1171 1231 1286 1354 1426 1502 1582 1666)].
		[$H]->[#(9 16 26 36 46 60 66 86 100 122 140 158 180 197 223 253 283 313 341 385 406 442 464 514 538 596 628 661 701 745 793 845 901 961 986 1054 1096 1142 1222 1276)]}
]

{ #category : #'matrix generation' }
QRCodeEncoder >> dimension: anInteger [
	dimension := anInteger
]

{ #category : #'error correction' }
QRCodeEncoder >> errorCorrect: chunk bytes: bytes [
	| polynomial generator startEntry entry |
	polynomial := chunk, (ByteArray new: bytes).
	generator := self generatorForBytes: bytes.
	1 to: chunk size do: [ :start |
		startEntry := polynomial at: start.
		startEntry = 0 ifFalse: [
			startEntry := self alphaForNumber: startEntry.
			generator withIndexDo: [ :generatorEntry :index |
				entry := startEntry + generatorEntry \\ 255.
				entry := self numberForAlpha: entry.
				entry := entry bitXor: (polynomial at: start + index - 1).
				polynomial at: start + index - 1 put: entry]]].
	"return the last bytes digits"
	^polynomial copyFrom: polynomial size - bytes + 1 to: polynomial size.
]

{ #category : #'error correction' }
QRCodeEncoder >> finalCodewords [
	^finalCodewords
]

{ #category : #'error correction' }
QRCodeEncoder >> fullGeneratorForBytes: bytes [
	"There are a bunch of generators included in the specification but they do not seem to be necessary"
	^bytes caseOf: {
		[2]->[#[0 25 1]].
		[5]->[#[0 113 164 166 119 10]].
		[6]->[#[0 116 134 5 176 15 87]].
		[7]->[#[0 87 229 146 149 238 102 21]].
		[10]->[#[0 251 67 46 61 118 70 64 94 32 45]].
		[13]->[#[0 74 152 176 100 86 100 106 104 130 218 206 140 78]].
		[15]->[#[0 8 183 61 91 202 37 51 58 58 237 140 124 5 99 105]].
		[16]->[#[0 120 104 107 109 102 161 76 3 91 191 147 169 182 194 225 120]].
		[17]->[#[0 43 139 206 78 43 239 123 206 214 147 24 99 150 39 243 163 136]].
		[18]->[#[0 215 234 158 94 184 97 118 170 79 187 152 148 252 179 5 98 96 153]].
		[20]->[#[0 17 60 79 50 61 163 26 187 202 180 221 225 83 239 156 164 212 212 188 190]].
		[22]->[#[0 210 171 247 242 93 230 14 109 221 53 200 74 8 172 98 80 219 134 160 105 165 231]].
		[24]->[#[0 229 121 135 48 211 117 251 126 159 180 169 152 192 226 228 218 111 0 117 232 87 96 227 21]].
		[26]->[#[0 173 125 158 2 103 182 118 17 145 201 111 28 165 53 161 21 245 142 13 102 48 227 153 145 218 70]].
		[28]->[#[0 168 223 200 104 224 234 108 180 110 190 195 147 205 27 232 201 21 43 245 87 42 195 212 119 242 37 9 123]].
		[30]->[#[0 41 173 145 152 216 31 179 182 50 48 110 86 239 96 222 125 42 173 226 193 224 130 156 37 251 216 238 40 192 180]].
		[32]->[#[0 10 6 106 190 249 167 4 67 209 138 138 32 242 123 89 27 120 185 80 156 38 69 171 60 28 222 80 52 254 185 220 241]].
		[34]->[#[0 111 77 146 94 26 21 108 19 105 94 113 193 86 140 163 125 58 158 229 239 218 103 56 70 114 61 183 129 167 13 98 62 129 51]].
		[36]->[#[0 200 183 98 16 172 31 246 234 60 152 115 0 167 152 113 248 238 107 18 63 218 37 87 210 105 177 120 74 121 196 117 251 113 233 30 120]].
		[40]->[#[0 59 116 79 161 252 98 128 205 128 161 247 57 163 56 235 106 53 26 187 174 226 104 170 7 175 35 181 114 88 41 47 163 125 134 72 20 232 53 35 15]].
		[42]->[#[0 250 103 221 230 25 18 137 231 0 3 58 242 221 191 110 84 230 8 188 106 96 147 15 131 139 34 101 223 39 101 213 199 237 254 201 123 171 162 194 117 50 96]].
		[44]->[#[0 190 7 61 121 71 246 69 55 168 188 89 243 191 25 72 123 9 145 14 247 1 238 44 78 143 62 224 126 118 114 68 163 52 194 217 147 204 169 37 130 113 102 73 181]].
		[46]->[#[0 112 94 88 112 253 224 202 115 187 99 89 5 54 113 129 44 58 16 135 216 169 211 36 1 4 96 60 241 73 104 234 8 249 245 119 174 52 25 157 224 43 202 223 19 82 15]].
		[48]->[#[0 228 25 196 130 211 146 60 24 251 90 39 102 240 61 178 63 46 123 115 18 221 111 135 160 182 205 107 206 95 150 120 184 91 21 247 156 140 238 191 11 94 227 84 50 163 39 34 108]].
		[50]->[#[0 232 125 157 161 164 9 118 46 209 99 203 193 35 3 209 111 195 242 203 225 46 13 32 160 126 209 130 160 242 215 242 75 77 42 189 32 113 65 124 69 228 114 235 175 124 170 215 232 133 205]].
		[52]->[#[0 116 50 86 186 50 220 251 89 192 46 86 127 124 19 184 233 151 215 22 14 59 145 37 242 203 134 254 89 190 94 59 65 124 113 100 233 235 121 22 76 86 97 39 242 200 220 101 33 239 254 116 51]].
		[54]->[#[0 183 26 201 87 210 221 113 21 46 65 45 50 238 184 249 225 102 58 209 218 109 165 26 95 184 192 52 245 35 254 238 175 172 79 123 25 122 43 120 108 215 80 128 201 235 8 153 59 101 31 198 76 31 156]].
		[56]->[#[0 106 120 107 157 164 216 112 116 2 91 248 163 36 201 202 229 6 144 254 155 135 208 170 209 12 139 127 142 182 249 177 174 190 28 10 85 239 184 101 124 152 206 96 23 163 61 27 196 247 151 154 202 207 20 61 10]].
		[58]->[#[0 82 116 26 247 66 27 62 107 252 182 200 185 235 55 251 242 210 144 154 237 176 141 192 248 152 249 206 85 253 142 65 165 125 23 24 30 122 240 214 6 129 218 29 145 127 134 206 245 117 29 41 63 159 142 233 125 148 123]].
		[60]->[#[0 107 140 26 12 9 141 243 197 226 197 219 45 211 101 219 120 28 181 127 6 100 247 2 205 198 57 115 219 101 109 160 82 37 38 238 49 160 209 121 86 11 124 30 181 84 25 194 87 65 102 190 220 70 27 209 16 89 7 33 240]].
		[62]->[#[0 65 202 113 98 71 223 248 118 214 94 0 122 37 23 2 228 58 121 7 105 135 78 243 118 70 76 223 89 72 50 70 111 194 17 212 126 181 35 221 117 235 11 229 149 147 123 213 40 115 6 200 100 26 246 182 218 127 215 36 186 110 106]].
		[64]->[#[0 45 51 175 9 7 158 159 49 68 119 92 123 177 204 187 254 200 78 141 149 119 26 127 53 160 93 199 212 29 24 145 156 208 150 218 209 4 216 91 47 184 146 47 140 195 195 125 242 238 63 99 108 140 230 242 31 204 11 178 243 217 156 213 231]].
		[66]->[#[0 5 118 222 180 136 136 162 51 46 117 13 215 81 17 139 247 197 171 95 173 65 137 178 68 111 95 101 41 72 214 169 197 95 7 44 154 77 111 236 40 121 143 63 87 80 253 240 126 217 77 34 232 106 50 168 82 76 146 67 106 171 25 132 93 45 105]].
		[68]->[#[0 247 159 223 33 224 93 77 70 90 160 32 254 43 150 84 101 190 205 133 52 60 202 165 220 203 151 93 84 15 84 253 173 160 89 227 52 199 97 95 231 52 177 41 125 137 241 166 225 118 2 54 32 82 215 175 198 43 238 235 27 101 184 127 3 5 8 163 238]]}
]

{ #category : #'error correction' }
QRCodeEncoder >> generatorForBytes: bytes [
	^bytes caseOf: {
		[7]->[#[0 87 229 146 149 238 102 21]].
		[10]->[#[0 251 67 46 61 118 70 64 94 32 45]].
		[13]->[#[0 74 152 176 100 86 100 106 104 130 218 206 140 78]].
		[15]->[#[0 8 183 61 91 202 37 51 58 58 237 140 124 5 99 105]].
		[16]->[#[0 120 104 107 109 102 161 76 3 91 191 147 169 182 194 225 120]].
		[17]->[#[0 43 139 206 78 43 239 123 206 214 147 24 99 150 39 243 163 136]].
		[18]->[#[0 215 234 158 94 184 97 118 170 79 187 152 148 252 179 5 98 96 153]].
		[20]->[#[0 17 60 79 50 61 163 26 187 202 180 221 225 83 239 156 164 212 212 188 190]].
		[22]->[#[0 210 171 247 242 93 230 14 109 221 53 200 74 8 172 98 80 219 134 160 105 165 231]].
		[24]->[#[0 229 121 135 48 211 117 251 126 159 180 169 152 192 226 228 218 111 0 117 232 87 96 227 21]].
		[26]->[#[0 173 125 158 2 103 182 118 17 145 201 111 28 165 53 161 21 245 142 13 102 48 227 153 145 218 70]].
		[28]->[#[0 168 223 200 104 224 234 108 180 110 190 195 147 205 27 232 201 21 43 245 87 42 195 212 119 242 37 9 123]].
		[30]->[#[0 41 173 145 152 216 31 179 182 50 48 110 86 239 96 222 125 42 173 226 193 224 130 156 37 251 216 238 40 192 180]]}
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
	| string word writer |
	codewords := ByteArray new: self dataCapacity.
	writer := BitWriter on: codewords.
	bytePosition := 1.
	bitPosition := 0.
	string := code string.
	code encoding caseOf: {
		[#numeric]->[
			"Mode"
			writer nextPut: 1 bits: 4.
			"Number of bits"
			code version < 10
				ifTrue: [ writer nextPut: string size bits: 10 ]
				ifFalse: [ code version < 27
					ifTrue: [ writer nextPut: string size bits: 12 ]
					ifFalse: [ writer nextPut: string size bits: 14 ] ].
			"Content: Three numerical characters at a time."
			string size > 3 ifTrue: [
				3 to: string size // 3 * 3 by: 3 do: [ :end |
					writer nextPut: (((string at: end - 2) asInteger - 48) * 100) + (((string at: end - 1) asInteger - 48) * 10) + ((string at: end) asInteger - 48) bits: 10 ] ].
			string size \\ 3 caseOf: {
				[0]->[ "Nothing required" ].
				[1]->[ writer nextPut: (string last asInteger - 48) bits: 4 ].
				[2]->[ writer nextPut: (string at: string size - 1) asInteger - 48 * 10 + (string last asInteger - 48) bits: 7 ]}].
		[#alphanumeric]->[
			"Mode"
			writer nextPut: 2 bits: 4.
			"Number of bits"
			code version < 10
				ifTrue: [ writer nextPut: string size bits: 9 ]
				ifFalse: [ code version < 27
					ifTrue: [ writer nextPut: string size bits: 11 ]
					ifFalse: [ writer nextPut: string size bits: 13 ] ].
			"Content: Two alphanumerical characters at a time."
			string size > 2 ifTrue: [
				2 to: string size // 2 * 2 by: 2 do: [ :end |
					writer nextPut: (self codeForAlphanumerical: (string at: end - 1)) * 45 + (self codeForAlphanumerical: (string at: end)) bits: 11 ] ].
			string size \\ 2 = 1 ifTrue: [
				writer nextPut: (self codeForAlphanumerical: string last) bits: 6 ] ].
		[#byte]->[
			"Mode"
			writer nextPut: 4 bits: 4.
			"Number of bits"
			code version < 10
				ifTrue: [ writer nextPut: string size bits: 8 ]
				ifFalse: [ writer nextPut: string size bits: 16 ].
			"Content: One byte at a time."
			string do: [ :char | writer nextPut: char charCode bits: 8 ] ].
		[#kanji]->[
			"Mode"
			writer nextPut: 8 bits: 8.
			"Number of bits"
			code version < 10
				ifTrue: [ writer nextPut: string size bits: 8 ]
				ifFalse: [ code version < 27
					ifTrue: [ writer nextPut: string size bits: 10 ]
					ifFalse: [ writer nextPut: string size bits: 12 ] ].
			"Content: 13 bits at a time"
			string do: [ :char |
				word := char charCode.
				word := word < 16re040
					ifTrue: [
						word := word - 16r8140.
						word // 256 * 16rc0 + (word \\ 256) ]
					ifFalse: [ 
						word := word - 16rc140.
						word // 256 * 16rc0 + (word \\ 256) ].
				writer nextPut: word bits: 13 ] ]}.
	"Terminate the sequence / Skip to next byte for error correction"
	writer bitsLeft > 3 ifTrue: [ writer nextPut: 0 bits: 4 ].
	"Add error correction sequence, alternating between 11101100 and 00010001".
	1 to: writer bytesLeft do: [ :index |
		writer nextPut: (index odd ifTrue: [ 2r11101100 ] ifFalse: [ 2r00010001 ]) ]
]

{ #category : #encoding }
QRCodeEncoder >> initializeEncoding [
	| string index |
	string := code string.
	string isEmpty ifTrue: [
		code encoding: #numeric.
		^self].
	index := 1.
	[(string at: index) isDigit] whileTrue: [
		index := index + 1.
		index > string size ifTrue: [
			code encoding: #numeric.
			^self]].
	[(string at: index) isQRCodeAlphanumeric] whileTrue: [
		index := index + 1.
		index > string size ifTrue: [
			code encoding: #alphanumeric.
			^self]].
	string isByteString ifTrue: [
		code encoding: #byte.
		^self].
	(string allSatisfy: [ :char | char isKanji]) ifTrue: [
		code encoding: #kanji].
	self error: 'This string contains characters that cannot be encoded.'
]

{ #category : #'error correction' }
QRCodeEncoder >> initializeErrorCorrection [
	| dataCodewords errorCorrectionCodewords dataWidth errorCorrectionWidth data errorCorrection index |
	dataCodewords := OrderedCollection new.
	errorCorrectionCodewords := OrderedCollection new.
	bytePosition := 1.
	dataWidth := 0.
	errorCorrectionWidth := 0.
	self chunking do: [ :arr |
		arr first timesRepeat: [
			data := codewords copyFrom: bytePosition to: bytePosition + arr third - 1.
			bytePosition := bytePosition + arr third.
			errorCorrection := self errorCorrect: data bytes: arr second - arr third.
			dataCodewords add: data.
			errorCorrectionCodewords add: errorCorrection.
			dataWidth := dataWidth max: data size.
			errorCorrectionWidth := errorCorrectionWidth max: errorCorrection size]].
	finalCodewords := ByteArray new: self totalCapacity.
	index := 0.
	1 to: dataWidth do: [ :column |
		dataCodewords do: [ :row |
			row size >= column ifTrue: [
				index := index + 1.
				finalCodewords at: index put: (row at: column)]]].
	1 to: errorCorrectionWidth do: [ :column |
		errorCorrectionCodewords do: [ :row |
			row size >= column ifTrue: [
				index := index + 1.
				finalCodewords at: index put: (row at: column)]]]
]

{ #category : #masking }
QRCodeEncoder >> initializeMasking [
	| symbols errorCorrection format version count finalForm |
	symbols := self maskedSymbols.
	finalForm := symbols detectMin: [ :entry | self penaltyScoreSymbol: entry ].
	"(symbols collect: [ :entry | self penaltyScoreSymbol: entry ]) inspect."
	"Generate the format information"
	format := code errorCorrection caseOf: {
		[$L]->[1].
		[$M]->[0].
		[$Q]->[3].
		[$H]->[2]}.
	format := (format * 8) +  (symbols indexOf: finalForm) - 1 * 1024.
	errorCorrection := format.
	14 to: 10 by: -1 do: [ :i |
		errorCorrection >= (2 raisedTo: i) ifTrue: [
			errorCorrection := (2 raisedTo: i - 10) * 1335 bitXor: errorCorrection]].
	format := (format + errorCorrection) bitXor: 2r101010000010010.
	"Place the format information"
	bb := BitBlt bitPokerToForm: finalForm.
	{{8 @ 0. dimension - 1 @ 8}.
		{8 @ 1. dimension - 2 @ 8}.
		{8 @ 2. dimension - 3 @ 8}.
		{8 @ 3. dimension - 4 @ 8}.
		{8 @ 4. dimension - 5 @ 8}.
		{8 @ 5. dimension - 6 @ 8}.
		{8 @ 7. dimension - 7 @ 8}.
		{8 @ 8. dimension - 8 @ 8}.
		{7 @ 8. 8 @ (dimension - 7)}.
		{5 @ 8. 8 @ (dimension - 6)}.
		{4 @ 8. 8 @ (dimension - 5)}.
		{3 @ 8. 8 @ (dimension - 4)}.
		{2 @ 8. 8 @ (dimension - 3)}.
		{1 @ 8. 8 @ (dimension - 2)}.
		{0 @ 8. 8 @ (dimension - 1)}} withIndexDo: [ :arr :index |
			((2 raisedTo: index - 1) bitAnd: format) = 0 ifFalse: [
				arr do: [ :point |
					bb pixelAt: point put: 1]]].
	"Add dark module"
	bb pixelAt: 8 @ (dimension - 8) put: 1.
	"Version information"
	code version > 6 ifTrue: [
		"Generate the version information"
		version := code version * 2r1000000000000.
		errorCorrection := version.
		17 to: 12 by: -1 do: [ :i |
			errorCorrection >= (2 raisedTo: i) ifTrue: [
				errorCorrection := (2 raisedTo: i - 12) * 7973 bitXor: errorCorrection]].
		version := version + errorCorrection.
		"Place the version information"
		count := 0.
		0 to: 5 do: [ :x |
			dimension - 11 to: dimension - 9 do: [ :y |
				((2 raisedTo: count) bitAnd: version) > 0 ifTrue: [
					bb pixelAt: x @ y put: 1.
					bb pixelAt: y @ x put: 1].
				count := count + 1]]].
	code form: finalForm
]

{ #category : #'matrix generation' }
QRCodeEncoder >> initializeMatrixGeneration [
	| bbMatrix test |
	self dimension: code version * 4 + 17.
	matrix := Form extent: dimension @ dimension.
	self createMasks.
	"Fill Matrix with finalCodewords (using the white mask to avoid writing to non-data areas"
	matrixPosition := dimension - 2 @ dimension.
	bb := BitBlt bitPeekerFromForm: whiteMask.
	bbMatrix := BitBlt bitPokerToForm: matrix.
	finalCodewords do: [ :byte |
		test := byte.
		1 to: 8 do: [ :index |
			self nextMatrixPosition.
			test > 127 ifTrue: [
				bbMatrix pixelAt: matrixPosition put: 1.
				test := test - 128 ].
			test := test * 2 ] ]
]

{ #category : #version }
QRCodeEncoder >> initializeVersion [
	"Based on the error correction and string size, determine the version to use."
	| versions  version |
	versions := code encoding caseOf: {
		[#numeric]->['HQML' asArray collect: [ :char | self versionNumericSize: code string size correction: char]].
		[#alphanumeric]->['HQML' asArray collect: [ :char | self versionAlphanumericSize: code string size correction: char]].
		[#byte]->['HQML' asArray collect: [ :char | self versionByteSize: code string size correction: char]].
		[#kanji]->['HQML' asArray collect: [ :char | self versionKanjiSize: code string size correction: char]]}.
	version := versions at: ('HQML' indexOf: code errorCorrection).
	version > 40
		ifTrue: [
			"The current level of error correction cannot be accommodated. Try to find a weaker one that works."
			versions := versions reject: [  :i | i > 40 ].
			versions isEmpty ifTrue: [ self error: 'This string is too long to be encoded.' ].
			code version: versions first.
			code errorCorrection: ('LMQH' at: versions size)]
		ifFalse: [
			code version: version.
			"Attempt to increase the error correction if it does not increase the version."
			code errorCorrection: ('HQML' at: (versions indexOf: version))]
]

{ #category : #capacity }
QRCodeEncoder >> kanjiCapacityForCorrection: correction [
	^correction caseOf: {
		[$L]->[#(10 20 32 48 65 82 95 118 141 167 198 226 262 282 320 361 397 442 488 528 572 618 672 721 784 842 902 940 1002 1066 1132 1201 1273 1347 1417 1496 1577 1661 1729 1817)].
		[$M]->[#(8 16 26 38 52 65 75 93 111 131 155 177 204 223 254 277 310 345 384 410 438 480 528 561 614 652 692 732 778 843 894 947 1002 1060 1113 1176 1224 1292 1362 1435)].
		[$Q]->[#(7 12 20 28 37 45 53 66 80 93 109 125 149 159 180 198 224 243 272 297 314 348 376 407 440 462 496 534 559 604 634 684 719 756 790 832 876 923 972 1024)].
		[$H]->[#(4 8 15 21 27 36 39 52 60 74 85 96 109 120 136 154 173 191 208 235 248 270 284 315 330 365 385 405 430 457 486 518 553 590 605 647 673 701 750 784)]}
]

{ #category : #masking }
QRCodeEncoder >> maskedSymbols [
	| form |
	^{[:i :j | i + j \\ 2 = 0].
		[:i :j | i \\ 2 = 0].
		[:i :j | j \\ 3 = 0].
		[:i :j | i + j \\ 3 = 0].
		[:i :j | (i // 2) + (j // 3) \\ 2 = 0].
		[:i :j | (i * j \\ 2) + (i * j \\ 3) = 0].
		[:i :j | i * j + (i * j \\ 3) \\ 2 = 0].
		[:i :j | (i * j \\ 3) + i + j \\ 2 = 0]} collect: [ :generator |
			form := Form extent: dimension @ dimension.
			"Generate the top left 12 x 12"
			bb := BitBlt bitPokerToForm: form.
			0 to: 11 do: [ :x |
				0 to: 11 do: [ :y |
					(generator value: y value: x) ifTrue: [
						bb pixelAt: x@y put: 1]]].
			"Based on top left 12 x 12, fill the rest"
			bb := BitBlt toForm: form.
			bb sourceForm: form.
			bb combinationRule: Form over.
			bb sourceRect: (0@0 extent: 12@12).
			1 to: dimension - 1 // 12 do: [ :index |
				bb destOrigin: index * 12 @ 0.
				bb copyBits].
			bb sourceRect: (0@0 extent: dimension @ 12).
			1 to: dimension - 1 // 12 do: [ :index |
				bb destOrigin: 0 @ (index * 12).
				bb copyBits].
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
			form]
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

{ #category : #'error correction' }
QRCodeEncoder >> numberForAlpha: alpha [
	alpha == 0 ifTrue: [ ^1 ].
	^#[2 4 8 16 32 64 128 29 58 116 232 205 135 19 38 76 152 45 90 180 117 234 201 143 3 6 12 24 48 96 192 157 39 78 156 37 74 148 53 106 212 181 119 238 193 159 35 70 140 5 10 20 40 80 160 93 186 105 210 185 111 222 161 95 190 97 194 153 47 94 188 101 202 137 15 30 60 120 240 253 231 211 187 107 214 177 127 254 225 223 163 91 182 113 226 217 175 67 134 17 34 68 136 13 26 52 104 208 189 103 206 129 31 62 124 248 237 199 147 59 118 236 197 151 51 102 204 133 23 46 92 184 109 218 169 79 158 33 66 132 21 42 84 168 77 154 41 82 164 85 170 73 146 57 114 228 213 183 115 230 209 191 99 198 145 63 126 252 229 215 179 123 246 241 255 227 219 171 75 150 49 98 196 149 55 110 220 165 87 174 65 130 25 50 100 200 141 7 14 28 56 112 224 221 167 83 166 81 162 89 178 121 242 249 239 195 155 43 86 172 69 138 9 18 36 72 144 61 122 244 245 247 243 251 235 203 139 11 22 44 88 176 125 250 233 207 131 27 54 108 216 173 71 142] at: alpha
]

{ #category : #capacity }
QRCodeEncoder >> numericCapacityForCorrection: correction [
	^correction caseOf: {
		[$L]->[#(41 77 127 187 255 322 370 461 552 652 772 883 1022 1101 1250 1408 1548 1725 1903 2061 2232 2409 2620 2812 3057 3283 3517 3669 3909 4158 4417 4686 4965 5253 5529 5836 6153 6479 6743 7089)].
		[$M]->[#(34 63 101 149 202 255 293 365 432 513 604 691 796 871 991 1082 1212 1346 1500 1600 1708 1872 2059 2188 2395 2544 2701 2857 3035 3289 3486 3693 3909 4134 4343 4588 4775 5039 5313 5596)].
		[$Q]->[#(27 48 77 111 144 178 207 259 312 364 427 489 580 621 703 775 876 948 1063 1159 1224 1358 1468 1588 1718 1804 1933 2085 2181 2358 2473 2670 2805 2949 3081 3244 3417 3599 3791 3993)].
		[$H]->[#(17 34 58 82 106 139 154 202 235 288 331 374 427 468 530 602 674 746 813 919 969 1056 1108 1228 1286 1425 1501 1581 1677 1782 1897 2022 2157 2301 2361 2524 2625 2735 2927 3057)]}
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
				ifTrue: [run := run + 1]
				ifFalse: [
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					color := test]].
		run > 4 ifTrue: [ penalty := penalty + run - 2 ]].
	0 to: dimension - 1 do: [ :column |
		run := 0.
		color := nil.
		0 to: dimension - 1 do: [ :row |
			test := bb pixelAt: column @ row.
			test = color
				ifTrue: [run := run + 1]
				ifFalse: [
					run > 4 ifTrue: [ penalty := penalty + run - 2 ].
					run := 1.
					color := test]].
		run > 4 ifTrue: [ penalty := penalty + run - 2 ]].
	"Penalty 2: A penalty for each 2x2 area of same-colored modules"
	0 to: dimension - 2 do: [ :row |
		color := bb pixelAt: 0@row.
		1 to: dimension - 1 do: [ :column |
			test := bb pixelAt: column@row.
			test = color
				ifTrue: [((bb pixelAt: column @ (row + 1)) = color and: [(bb pixelAt: column - 1 @ (row + 1)) = color])
					ifTrue: [penalty := penalty + 3]]
				ifFalse: [color := test]]].
	"Penalty 3: A large penalty if there are patterns that look similar to the finder patterns."
	0 to: dimension - 1 do: [ :row |
		test := bb pixelAt: 0@row.
		1 to: 9 do: [ :column |
			test := test * 2 + (bb pixelAt: column@row)].
		10 to: dimension - 1 do: [ :column |
			test := test * 2 + (bb pixelAt: column@row) \\ 2048.
			(test = 1488 or: [ test = 93 ]) ifTrue: [ penalty := penalty + 40 ]]].
	0 to: dimension - 1 do: [ :column |
		test := bb pixelAt: column@0.
		1 to: 9 do: [ :row |
			test := test * 2 + (bb pixelAt: column@row)].
		10 to: dimension - 1 do: [ :row |
			test := test * 2 + (bb pixelAt: column@row) \\ 2048.
			(test = 1488 or: [ test = 93 ]) ifTrue: [ penalty := penalty + 40 ]]].
	"Penalty 4: A penalty based on the percentage of tiles that are black / white"
	count := 0.
	0 to: dimension - 1 do: [ :row |
		0 to: dimension - 1 do: [ :column |
			count := count + (bb pixelAt: column@row)]].
	penalty := ((count / dimension squared - 0.5) abs * 20) floor * 10 + penalty.
	
	^penalty
]

{ #category : #capacity }
QRCodeEncoder >> totalCapacity [
	^self totalCapacityVersion: code version
]

{ #category : #capacity }
QRCodeEncoder >> totalCapacityVersion: anInteger [
	^#(26 44 70 100 134 172 196 242 292 346 404 466 532 581 655 733 815 901 991 1085 1156 1258 1364 1474 1588 1706 1828 1921 2051 2185 2323 2465 2611 2761 2876 3034 3196 3362 3532 3706) at: anInteger
]

{ #category : #version }
QRCodeEncoder >> versionAlphanumericSize: size correction: correction [
	(self alphanumericCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [^index]].
	^100
]

{ #category : #version }
QRCodeEncoder >> versionByteSize: size correction: correction [
	(self byteCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [^index]].
	^100
]

{ #category : #version }
QRCodeEncoder >> versionKanjiSize: size correction: correction [
	(self kanjiCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [^index]].
	^100
]

{ #category : #version }
QRCodeEncoder >> versionNumericSize: size correction: correction [
	(self numericCapacityForCorrection: correction) withIndexDo: [ :capacity :index |
		capacity >= size ifTrue: [^index]].
	^100
]
