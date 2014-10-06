"
MicroQR is not widely used. As such, the testing is not terribly thorough.
"
Class {
	#name : #MicroQRCodeEncoderTest,
	#superclass : #TestCase,
	#category : #'QRCode-Tests'
}

{ #category : #tests }
MicroQRCodeEncoderTest >> testM2 [
	| code encoder |
	code := QRCode new
		string: '01234567';
		errorCorrection: $L;
		yourself.
	encoder := MicroQRCodeEncoder initializeCode: code.
	self assert: encoder version = 2.
	self assert: code version = 2.
	self assert: code errorCorrection = $L.
	self assert: encoder codewords = #[64 24 172 195 0].
	self assert: encoder finalCodewords = #[64 24 172 195 0 134 13 34 174 48].
	self assert: code form bits asArray = #(4272422912 2196242432 3127377920 3128426496 3135242240 2189950976 4269277184 6291456 3498573824 1789394944 3891265536 338690048 3921149952).
	"On default, it should choose error correction of M"
	code := QRCode new
		string: '01234567';
		yourself.
	encoder := MicroQRCodeEncoder initializeCode: code.
	self assert: encoder version = 2.
	self assert: code version = 2.
	self assert: code errorCorrection = $M.
	self assert: encoder codewords = #[64 24 172 195].
	self assert: encoder finalCodewords = #[64 24 172 195 211 226 194 57 150 107].
	self assert: code form bits asArray = #(4272422912 2187853824 3127377920 3136815104 3126853632 2187853824 4273471488 6291456 3806855168 728236032 2857369600 779091968 2386034688)
]

{ #category : #tests }
MicroQRCodeEncoderTest >> testM3 [
	| code encoder |
	code := QRCode new
		string: 'Wikipedia';
		errorCorrection: $L;
		yourself.
	encoder := MicroQRCodeEncoder initializeCode: code.
	self assert: encoder version = 3.
	self assert: code version = 3.
	self assert: code errorCorrection = $L.
	self assert: encoder codewords = #[165 93 165 173 165 193 149 145 165 132 0].
	self assert: encoder finalCodewords = #[165 93 165 173 165 193 149 145 165 132 0 209 204 24 248 26 86].
	self assert: code form bits asArray = #(4272553984 2182348800 3137208320 3131441152 3122003968 2192179200 4266393600 5373952 4230610944 319684608 3991797760 1114898432 3203006464 1113325568 3982360576)
]
