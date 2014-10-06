Extension { #name : #Character }

{ #category : #'*QRCode' }
Character >> isKanji [
	| charCode |
	charCode := self charCode.
	charCode < 16r8140 ifTrue: [ ^ false ].
	charCode <= 16r9ffc ifTrue: [ ^ true ].
	charCode < 16re040 ifTrue: [ ^ false ].
	^ charCode <= 16rebbf
]

{ #category : #'*QRCode' }
Character >> isQRCodeAlphanumeric [
	^ '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:' includes: self
]
