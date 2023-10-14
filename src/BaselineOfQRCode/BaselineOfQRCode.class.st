Class {
	#name : #BaselineOfQRCode,
	#superclass : #BaselineOf,
	#category : #BaselineOfQRCode
}

{ #category : #baselines }
BaselineOfQRCode >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec package: 'QRCode'. 
		spec package: 'QRCode-Contents' with: [ spec requires: #('QRCode') ].
		spec package: 'QRCode-Contents-Tests' with: [ spec requires: #('QRCode-Contents') ].
	].
]
