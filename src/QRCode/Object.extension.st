Extension { #name : #Object }

{ #category : #'*QRCode' }
Object >> asMicroQRCode [
	^ MicroQRCodeEncoder codeForString: self asString
]

{ #category : #'*QRCode' }
Object >> asQRCode [
	^ QRCodeEncoder codeForString: self asString
]
