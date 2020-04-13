Class {
	#name : #BaselineOfQRCode,
	#superclass : #BaselineOf,
	#category : #BaselineOfQRCode
}

{ #category : #baselines }
BaselineOfQRCode >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				package: 'QRCode' ]
]
