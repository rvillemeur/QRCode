"
A QRCodeWiFiNetworkConfigTest is a test class for testing the behavior of QRCodeWiFiNetworkConfig
"
Class {
	#name : #QRCodeWiFiNetworkConfigTest,
	#superclass : #TestCase,
	#category : #'QRCode-Contents-Tests-Wi-Fi'
}

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testEmptyWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrCode := qrWifi asQRCode.
	
	self assert: qrCode string = 'WIFI:T:WPA;S:mynetwork;P:mypass;;'
]
