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
	
	self assert: qrWifi authenticationType equals: 'WPA'.
	self assert: qrWifi ssid equals: 'mynetwork'.
	self assert: qrWifi password equals: 'mypass'.
	self deny: qrWifi isHidden.
	self assert: qrCode string equals: 'WIFI:T:WPA;S:mynetwork;P:mypass;;'
]

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testHiddenWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrWifi hidden.
	
	qrCode := qrWifi asQRCode.
	
	self assert: qrWifi isHidden.
	self assert: qrCode string equals: 'WIFI:T:WPA;S:mynetwork;P:mypass;H:true;;'
]

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testNoPassWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrWifi wep; ssid: 'testSSID'; noPass.
	qrCode := qrWifi asQRCode.
	
	self assert: qrCode string equals: 'WIFI:T:nopass;S:testSSID;;'
]

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testWEPWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrWifi wep; ssid: 'testSSID'; password: 'testPassword'.
	qrCode := qrWifi asQRCode.
	
	self assert: qrCode string equals: 'WIFI:T:WEP;S:testSSID;P:testPassword;;'
]

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testWPA2EAPAdvancedWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrWifi wpa2Eap; ssid: 'testSSID'; password: 'testPassword'.
	qrWifi ttls; anonymous; identity: 'testIdentity'; msChapV2.
	
	qrCode := qrWifi asQRCode.
	
	self assert: qrCode string equals: 'WIFI:T:WPA2-EAP;S:testSSID;P:testPassword;E:TTLS;A:anon;I:testIdentity;PH2:MSCHAPV2;;'
]

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testWPA2EAPWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrWifi wpa2Eap; ssid: 'testSSID'; password: 'testPassword'.
	qrCode := qrWifi asQRCode.
	
	self assert: qrCode string equals: 'WIFI:T:WPA2-EAP;S:testSSID;P:testPassword;;'
]

{ #category : #tests }
QRCodeWiFiNetworkConfigTest >> testWPAWiFiQRCode [

	| qrWifi qrCode |
	qrWifi := QRCodeWiFiNetworkConfig new.
	qrWifi wpa; ssid: 'testSSID'; password: 'testPassword'.
	qrCode := qrWifi asQRCode.
	
	self assert: qrCode string equals: 'WIFI:T:WPA;S:testSSID;P:testPassword;;'
]
