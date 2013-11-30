Extension { #name : #String }

{ #category : #'*QRCode' }
String >> asQRCode [
	^QRCode fromString: self
]
