"
This class is an interface for putting bits (and bytes) into a ByteArray.
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
BitWriter class >> on: aByteArray [
	^self new
		content: aByteArray;
		yourself
]

{ #category : #accessing }
BitWriter >> bitsLeft [
	^content size - byte + 1 * 8 - bit
]

{ #category : #accessing }
BitWriter >> bytesLeft [
	^bit = 0
		ifTrue: [ content size - byte + 1 ]
		ifFalse: [ content size - byte ]
]

{ #category : #accessing }
BitWriter >> completeByte [
	bit = 0 ifFalse: [ 
		byte := byte + 1.
		bit := 0 ]
]

{ #category : #accessing }
BitWriter >> content [
	^content
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
