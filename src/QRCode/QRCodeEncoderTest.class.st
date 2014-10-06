Class {
	#name : #QRCodeEncoderTest,
	#superclass : #TestCase,
	#category : #'QRCode-Tests'
}

{ #category : #tests }
QRCodeEncoderTest >> testAlphanumericEncoding [
	| code encoder |
	code := QRCode new
		string: 'AC-42';
		yourself.
	encoder := QRCodeEncoder new
		code: code;
		initializeEncoding;
		initializeVersion;
		initializeCodewords;
		yourself.
	self assert: code encoding = #alphanumeric.
	self assert: encoder version = 1.
	"It should switch to the highest level of encoding"
	self assert: code errorCorrection = $H.
	self assert: encoder codewords = #[32 41 206 231 33 0 236 17 236].

]

{ #category : #tests }
QRCodeEncoderTest >> testCapacity [
	"All the data capacities are cached in the QRCodeEncoder. Here, those cached values are tested whether they match the calculated capacity."
	| encoder dataCapacity numericCapacity alphanumericCapacity byteCapacity kanjiCapacity bitCapacity test |
	encoder := QRCodeEncoder new.
	1 to: 40 do: [ :version |
		'LMQH' do: [ :errorCorrection |
			dataCapacity := (encoder dataCapacityForCorrection: errorCorrection) at: version.
			bitCapacity := dataCapacity * 8 - 4.
			"Test that the numeric capacity cache is correct"
			test := version < 10
				ifTrue: [ 10 ]
				ifFalse: [ version < 27
					ifTrue: [ 12 ]
					ifFalse: [ 14 ] ].
			numericCapacity := bitCapacity - test * 3 + 9 // 10.
			test := numericCapacity * 10 // 3 + test.
			numericCapacity \\ 3 = 1 ifTrue: [ test := test + 4 ].
			numericCapacity \\ 3 = 2 ifTrue: [ test := test + 7 ].
			test > bitCapacity ifTrue: [ numericCapacity := numericCapacity - 1 ].
			self assert: numericCapacity = ((encoder numericCapacityForCorrection: errorCorrection) at: version).
			"Test that the alphanumeric capacity cache is correct"
			test := version < 10
				ifTrue: [ 9 ]
				ifFalse: [ version < 27
					ifTrue: [ 11 ]
					ifFalse: [ 13 ] ].
			alphanumericCapacity := bitCapacity - test * 2 + 10 // 11.
			test := alphanumericCapacity * 11 // 2 + test.
			alphanumericCapacity odd ifTrue: [ test := test + 6 ].
			test > bitCapacity ifTrue: [ alphanumericCapacity := alphanumericCapacity - 1 ].
			self assert: alphanumericCapacity = ((encoder alphanumericCapacityForCorrection: errorCorrection) at: version).
			"Test that the byte capacity cache is correct"
			byteCapacity := bitCapacity - (version < 10 ifTrue: [ 8 ] ifFalse: [ 16 ]) // 8.
			self assert: byteCapacity = ((encoder byteCapacityForCorrection: errorCorrection) at: version).
			"Test that the kanji capacity cache is correct"
			test := version < 10
				ifTrue: [ 8 ]
				ifFalse: [ version < 27
					ifTrue: [ 10 ]
					ifFalse: [ 12 ] ].
			kanjiCapacity := bitCapacity - test // 13.
			self assert: kanjiCapacity = ((encoder kanjiCapacityForCorrection: errorCorrection) at: version) ] ]
]

{ #category : #tests }
QRCodeEncoderTest >> testChunking [
	| encoding validGenerators |
	encoding := QRCodeEncoder new.
	validGenerators := #[7 10 13 15 16 17 18 20 22 24 26 28 30].
	#(chunkingL chunkingM chunkingQ chunkingH) do: [ :message |
		(encoding perform: message) withIndexDo: [ :arr :version |
			"Make sure that we have generators for this"
			arr do: [ :sub | self assert: (validGenerators includes: sub second - sub third)].
			"Make sure that the chunking adds up to the full capacity"
			self assert: (arr sum: [ :sub | sub first * sub second ]) = (encoding totalCapacityVersion: version)]]
]

{ #category : #tests }
QRCodeEncoderTest >> testFullLarge [
	"Test a larger string. This tests, for instance, whether format writing functions correctly."
	| code encoder |
	code := QRCode new
		string: 'This is another test. It should use byte encoding and thus be significantly larger.';
		errorCorrection: $H;
		yourself.
	encoder := QRCodeEncoder initializeCode: code.
	self assert: encoder version = 8.
	self assert: code version = 8.
	self assert: code errorCorrection = $H.
	self assert: encoder codewords = #[69 53 70 134 151 50 6 151 50 6 22 230 247 70 134 87 34 7 70 87 55 66 226 4 151 66 7 54 134 247 86 198 66 7 87 54 82 6 39 151 70 82 6 86 230 54 246 70 150 230 114 6 22 230 66 7 70 135 87 50 6 38 82 7 54 150 118 230 150 102 150 54 22 231 70 199 146 6 198 23 38 118 87 34 224 236].
	self assert: encoder finalCodewords = #[69 134 134 6 70 54 53 87 247 86 135 22 70 34 86 230 87 231 134 7 198 54 50 70 151 70 66 246 6 199 50 87 7 70 38 146 6 55 87 150 82 6 151 66 54 230 7 198 50 226 82 114 54 23 6 4 6 6 150 38 22 151 39 22 118 118 230 66 151 230 230 87 247 7 70 66 150 34 70 54 82 7 102 224 150 236 226 35 197 228 32 72 113 158 187 18 200 44 59 42 41 239 89 118 131 19 81 123 56 194 32 33 104 183 71 186 81 85 123 247 243 161 197 27 159 72 146 144 211 36 254 97 206 41 120 25 8 217 254 151 24 57 103 232 77 85 237 67 57 43 42 137 209 68 155 128 148 217 112 141 8 160 255 148 157 250 251 85 155 135 194 24 97 37 240 218 83 166 208 244 246 246 152 167 230 166 70 183 50 64 12 253 3 42 189 186 234 82 177 181 52 134 157 180 64 59 240 208 185 198 231 65 102 74 184 74 181 69 227 146 56 186 99 85 228 217 37 193 144 15 6 231 88 177 126 19 41 94 23 207 226 171].
	self assert: code form bits asArray = #(4264006085 4173299712 2193044393 933265408 3130029731 3584983040 3133964886 1429110784 3136220159 808353792 2194055732 2048950272 4272597674 2864676864 971322 1845493760 670706666 3445555200 1972503710 3696918528 3412101300 1304854528 2825345731 1762459648 3679145520 3464003584 3253914058 1564573696 3280255528 1221230592 1491987025 3471671296 3085824667 2943090688 2566916264 3578101760 1459902365 2643361792 2915795942 4162650112 200443807 2299297792 1753698122 3356557312 4022958078 486309888 3102869032 512327680 1792199356 1823309824 3905554982 3498868736 1066747878 368738304 26945504 3450699776 45343120 3946151936 4180313723 1347846144 998414585 1547468800 1227388152 1307836416 4272623445 3916726272 1165654586 2290384896 2519060716 1562542080 1485822672 2850291712 2473734044 2838593536 3234797202 3575021568 1203228586 3584327680 1898369375 2309226496 3819311100 3422093312 10673718 76185600 4273642169 3652091904 2189489724 3364618240 3125731323 4026335232 3124309379 1149829120 3133575730 3721297920 2188999468 2168717312 4267197192 2403368960)
	
]

{ #category : #tests }
QRCodeEncoderTest >> testFullSmall [
	| code encoder |
	code := QRCode new
		string: 'THIS IS A TEST.';
		errorCorrection: $Q;
		yourself.
	encoder := QRCodeEncoder initializeCode: code.
	self assert: encoder version = 1.
	self assert: code version = 1.
	self assert: code errorCorrection = $Q.
	self assert: encoder codewords = #[32 125 42 104 217 154 136 30 106 79 66 106 0].
	self assert: encoder finalCodewords = #[32 125 42 104 217 154 136 30 106 79 66 106 0 212 109 151 207 61 195 197 186 227 37 13 51 95].
	self assert: code form bits asArray = #(4276353024 2196899840 3123374080 3128092672 3123898368 2182744064 4272683008 1572864 1134827520 434003968 324110336 2093385728 933820416 11325440 4273534976 2182844416 3128127488 3127640064 3126671360 2190084096 4264263680)
	
]

{ #category : #tests }
QRCodeEncoderTest >> testGFPolynomials [
	"Test the Reed Solomon Error Correction"
	| chunk |
	"Test polynomial generation"
	{7->#[0 87 229 146 149 238 102 21].
	10->#[0 251 67 46 61 118 70 64 94 32 45].
	13->#[0 74 152 176 100 86 100 106 104 130 218 206 140 78].
	15->#[0 8 183 61 91 202 37 51 58 58 237 140 124 5 99 105].
	16->#[0 120 104 107 109 102 161 76 3 91 191 147 169 182 194 225 120].
	17->#[0 43 139 206 78 43 239 123 206 214 147 24 99 150 39 243 163 136].
	18->#[0 215 234 158 94 184 97 118 170 79 187 152 148 252 179 5 98 96 153].
	20->#[0 17 60 79 50 61 163 26 187 202 180 221 225 83 239 156 164 212 212 188 190].
	22->#[0 210 171 247 242 93 230 14 109 221 53 200 74 8 172 98 80 219 134 160 105 165 231].
	24->#[0 229 121 135 48 211 117 251 126 159 180 169 152 192 226 228 218 111 0 117 232 87 96 227 21].
	26->#[0 173 125 158 2 103 182 118 17 145 201 111 28 165 53 161 21 245 142 13 102 48 227 153 145 218 70].
	28->#[0 168 223 200 104 224 234 108 180 110 190 195 147 205 27 232 201 21 43 245 87 42 195 212 119 242 37 9 123].
	30->#[0 41 173 145 152 216 31 179 182 50 48 110 86 239 96 222 125 42 173 226 193 224 130 156 37 251 216 238 40 192 180]} do: [ :assoc | self assert: (ByteArray gfPolynomial: assoc key) = assoc value ].
	"Test the polynomial division"
	chunk := #[16 32 12 86 97 128 236 17 236 17 236 17 236 17 236 17].
	{7->#[97 13 169 7 28 175 7].
	10->#[165 36 212 193 237 54 199 135 44 85].
	13->#[143 74 77 249 189 15 24 224 37 13 145 190 74].
	15->#[137 158 107 61 53 135 220 81 113 121 44 248 252 16 56].
	16->#[49 26 210 36 60 119 57 149 223 215 18 96 254 142 205 139].
	17->#[239 120 237 193 143 177 48 180 97 69 85 194 11 116 207 22 98].
	18->#[136 234 219 174 42 35 65 71 14 106 81 24 169 84 107 85 79 207].
	20->#[220 115 142 193 169 116 93 138 76 198 21 239 33 203 6 136 13 222 28 71].
	22->#[68 203 28 235 198 5 48 26 159 138 163 167 211 142 6 171 181 119 72 206 146 208].
	24->#[123 65 10 55 178 103 101 216 73 216 47 44 224 207 94 71 146 66 49 81 20 227 82 168].
	26->#[162 100 11 86 14 223 18 205 63 174 68 247 74 199 33 60 13 77 240 216 144 131 192 182 69 25].
	28->#[74 153 71 68 253 92 82 148 3 221 144 51 84 141 230 161 23 202 205 97 180 243 185 128 129 206 185 219].
	30->#[6 77 92 244 137 26 216 212 37 67 92 231 107 115 132 145 112 30 102 218 13 83 248 225 122 102 58 229 94 210]} do: [ :assoc | self assert: (chunk dividedByGFPolynomial: (ByteArray gfPolynomial: assoc key)) = assoc value ].
]

{ #category : #tests }
QRCodeEncoderTest >> testNumericEncoding [
	| code encoder |
	code := QRCode new
		string: '01234567';
		yourself.
	encoder := QRCodeEncoder new
		code: code;
		initializeEncoding;
		initializeVersion;
		initializeCodewords;
		yourself.
	self assert: code encoding = #numeric.
	self assert: encoder version = 1.
	"It should switch to the highest level of encoding"
	self assert: code errorCorrection = $H.
	self assert: encoder codewords = #[16 32 12 86 97 128 236 17 236].

]

{ #category : #tests }
QRCodeEncoderTest >> testPenaltyScore [
	"While penalty testing is ambiguous, this is a test of a standard implementation."
	| form encoder |
	form := Form
		extent: 21 @ 21
		depth: 1
		fromArray: #(4262721536 2194278400 3126519808 3137005568 3134384128 2185889792 4272683008 14155776 1590611968 3171905536 722665472 3025715200 3756980224 8994816 4268128256 2191833088 3134339072 3132661760 3126466560 2196713472 4266135552)
		offset: 0 @ 0.
	encoder := QRCodeEncoder new
		dimension: 21;
		yourself.
	self assert: (encoder penaltyScoreSymbol: form) = 353
]

{ #category : #tests }
QRCodeEncoderTest >> testUTF8Encoding [
	| code encoder |
	code := QRCode new
		string: (WideString streamContents: [ :stream |
			#(200 400 800 1600 3200 6400) do: [ :i |
				stream nextPut: (Character value: i) ] ]);
		errorCorrection: $Q;
		yourself.
	encoder := QRCodeEncoder new
		code: code;
		initializeEncoding;
		initializeVersion;
		initializeCodewords;
		yourself.
	self assert: code encoding = #byte.
	self assert: encoder codewords = #[113 164 14 195 136 198 144 204 160 217 128 224 178 128 225 164 128 0 236 17 236 17].
]

{ #category : #tests }
QRCodeEncoderTest >> testVersion [
	| encoder |
	encoder := QRCodeEncoder new.
	encoder code: (QRCode new
		string: 'THIS IS A LITTLE TEST TO SEE IF THE VERSION IS CORRECTLY PICKED FOR THE LENGTH OF AN ALPHANUMERICAL SEQUENCE.';
		errorCorrection: $M;
		yourself).
	encoder
		initializeEncoding;
		initializeVersion.
	self assert: encoder version = 5.
	encoder := QRCodeEncoder new.
	encoder code: (QRCode new
		string: '48374837523850834853890573408573405734508347583750475039573857348573857345734054758347503475023475035723857238573487505701866160845847502458750345734856865090185783740814781773874328473204732847389473048374892147320487320847506580730847395003953748719356841384375650174873058638593471304731785390573205638497304732014730586320589371403270326532894701857935630183730487310563084710473041034618304831047304610486304';
		errorCorrection: $H;
		yourself).
	encoder
		initializeEncoding;
		initializeVersion..
	self assert: encoder version = 13
]
