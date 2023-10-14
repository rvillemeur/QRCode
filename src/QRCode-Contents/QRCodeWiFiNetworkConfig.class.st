Class {
	#name : #QRCodeWiFiNetworkConfig,
	#superclass : #Object,
	#instVars : [
		't',
		's',
		'p',
		'h',
		'e',
		'a',
		'i',
		'ph2'
	],
	#category : #'QRCode-Contents-Wi-Fi'
}

{ #category : #initialization }
QRCodeWiFiNetworkConfig >> initialize [ 

	super initialize.
	
	self wpa.
	self ssid: 'mynetwork'.
]

{ #category : #'API - authentication type' }
QRCodeWiFiNetworkConfig >> noPass [

	t := 'nopass'
]

{ #category : #initialization }
QRCodeWiFiNetworkConfig >> printOn: aStream [

	t ifNil:[^'Error : bad Wi-Fi Network Config'].

	aStream nextPutAll: 'WIFI:'.
	aStream nextPutAll: 'T:'; nextPutAll: (t asString); nextPut: $;.
	
]

{ #category : #'API - network' }
QRCodeWiFiNetworkConfig >> ssid: aString [

	s := aString.
]

{ #category : #'API - authentication type' }
QRCodeWiFiNetworkConfig >> wep [

	t := 'WEP'
]

{ #category : #'API - authentication type' }
QRCodeWiFiNetworkConfig >> wpa [

	t := 'WPA'
]

{ #category : #'API - authentication type' }
QRCodeWiFiNetworkConfig >> wpaEap [

	t := 'WPA2-EAP'
]
