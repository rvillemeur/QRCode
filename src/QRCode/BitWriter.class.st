"
This class is an interface for putting bits into a ByteArray for creating a QRCode. It is possible to put in bytes (nextPut:) or bits (nextPut:bits:). There is support for the four formats supported by QRCode: numeric, alphanumeric, byte and kanji.
"
Class {
	#name : #BitWriter,
	#superclass : #Object,
	#instVars : [
		'content',
		'byte',
		'bit'
	],
	#category : #'QRCode-Core'
}

{ #category : #'instance creation' }
BitWriter class >> new: anInteger [
	^self on: (ByteArray new: anInteger)
]

{ #category : #'instance creation' }
BitWriter class >> on: aByteArray [
	^self new
		content: aByteArray;
		yourself
]

{ #category : #accessing }
BitWriter >> bitsLeft [
	^ content size - byte + 1 * 8 - bit
]

{ #category : #accessing }
BitWriter >> bytesLeft [
	^ bit = 0
		ifTrue: [ content size - byte + 1 ]
		ifFalse: [ content size - byte ]
]

{ #category : #encoding }
BitWriter >> codeForAlphanumerical: char [
	char == $0 ifTrue: [ ^ 0 ].
	^ '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:' indexOf: char
]

{ #category : #accessing }
BitWriter >> completeByte [
	bit = 0 ifFalse: [ 
		byte := byte + 1.
		bit := 0 ]
]

{ #category : #accessing }
BitWriter >> content [
	^ content
]

{ #category : #'initialize-release' }
BitWriter >> content: aByteArray [
	content := aByteArray
]

{ #category : #'initialize-release' }
BitWriter >> initialize [
	byte := 1.
	bit := 0
]

{ #category : #accessing }
BitWriter >> nextPut: aByte [
	self completeByte.
	content at: byte put: aByte.
	byte := byte + 1
]

{ #category : #accessing }
BitWriter >> nextPut: integer bits: bits [
	| amount shift |
	bits = 0 ifTrue: [ ^ self ].
	bit + bits <= 8
		ifTrue: [ bit + bits = 8
			ifTrue: [
				content at: byte put: ((content at: byte) bitOr: integer).
				byte := byte + 1.
				bit := 0 ]
			ifFalse: [
				content at: byte put: ((content at: byte) bitOr: (integer bitShiftMagnitude: 8 - bits - bit)).
				bit := bit + bits ] ]
		ifFalse: [
			amount := bits + bit - 8.
			shift := integer bitShiftMagnitude: amount * -1.
			content at: byte put: ((content at: byte) bitOr: shift).
			shift := integer - (shift bitShiftMagnitude: amount).
			byte := byte + 1.
			bit := 0.
			self nextPut: shift bits: amount ]
]

{ #category : #encoding }
BitWriter >> nextPutAlphanumeric: string [
	"Two alphanumerical characters at a time."
	string size > 2 ifTrue: [
		2 to: string size // 2 * 2 by: 2 do: [ :end |
			self nextPut: (self codeForAlphanumerical: (string at: end - 1)) * 45 + (self codeForAlphanumerical: (string at: end)) bits: 11 ] ].
	string size \\ 2 = 1 ifTrue: [
		self nextPut: (self codeForAlphanumerical: string last) bits: 6 ]
]

{ #category : #encoding }
BitWriter >> nextPutByte: string [
	"One byte at a time."
	string do: [ :char | self nextPut: char charCode bits: 8 ]
]

{ #category : #encoding }
BitWriter >> nextPutKanji: string [
	"13 bits at a time"
	| word |
	string do: [ :char |
		word := char charCode.
		word := word < 16re040
			ifTrue: [
				word := word - 16r8140.
				word // 256 * 16rc0 + (word \\ 256) ]
			ifFalse: [ 
				word := word - 16rc140.
				word // 256 * 16rc0 + (word \\ 256) ].
		self nextPut: word bits: 13 ]
]

{ #category : #encoding }
BitWriter >> nextPutNumeric: string [
	"Three numerical characters at a time."
	string size > 3 ifTrue: [
		3 to: string size // 3 * 3 by: 3 do: [ :end |
			self nextPut: (((string at: end - 2) asInteger - 48) * 100) + (((string at: end - 1) asInteger - 48) * 10) + ((string at: end) asInteger - 48) bits: 10 ] ].
	string size \\ 3 caseOf: {
		[ 0 ] -> [ "Nothing required" ].
		[ 1 ] -> [ self nextPut: (string last asInteger - 48) bits: 4 ].
		[ 2 ] -> [ self nextPut: (string at: string size - 1) asInteger - 48 * 10 + (string last asInteger - 48) bits: 7 ] }
]
