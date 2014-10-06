Extension { #name : #ByteArray }

{ #category : #'*QRCode' }
ByteArray >> dividedByGFPolynomial: poly [
	"Return myself divided by the GF(256) polynomial."
	| return combinedIndex startEntry |
	return := self forceTo: self size + poly size - 1 paddingWith: 0.
	1 to: self size do: [ :start |
		startEntry := return at: start.
		startEntry = 0 ifFalse: [
			startEntry := startEntry toGF256Alpha.
			poly withIndexDo: [ :alpha :index |
				combinedIndex := start + index - 1.
				return at: combinedIndex put: ((startEntry + alpha \\ 255) fromGF256Alpha bitXor: (return at: combinedIndex)) ] ] ].
	"return the last bytes digits"
	^ return last: poly size - 1
]

{ #category : #'*QRCode' }
ByteArray class >> gfPolynomial: anInteger [
	"Generate the GF(256) polynomial for that length"
	| instance |
	instance := #[0 0].
	1 to: anInteger - 1 do: [ :index |
		instance := instance multipliedByGFPolynomial: (self with: 0 with: index) ].
	^instance
]

{ #category : #'*QRCode' }
ByteArray >> multipliedByGFPolynomial: poly [
	"Return the product of myself and the GF(256) polynomial."
	| return combinedIndex |
	return := self class new: poly size + self size - 1.
	poly withIndexDo: [ :polyAlpha :polyIndex |
		self withIndexDo: [ :alpha :index |
			combinedIndex := polyIndex + index - 1.
			return
				at: combinedIndex
				put: ((polyAlpha + alpha \\ 255) fromGF256Alpha bitXor: (return at: combinedIndex)) ] ].
	"Convert bytes to alpha representation"
	1 to: return size do: [ :index |
		return at: index put: (return at: index) toGF256Alpha ].
	^ return
]
