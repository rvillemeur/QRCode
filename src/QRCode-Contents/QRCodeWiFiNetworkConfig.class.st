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

{ #category : #'API - authentication type - advanced' }
QRCodeWiFiNetworkConfig >> anonymous [

	a := 'anon'
]

{ #category : #'API - authentication type' }
QRCodeWiFiNetworkConfig >> authenticationType [

	^ t
]

{ #category : #'API - network' }
QRCodeWiFiNetworkConfig >> hidden [

	self isHidden: true
]

{ #category : #'API - authentication type - advanced' }
QRCodeWiFiNetworkConfig >> identity: aString [

	i := aString
]

{ #category : #initialization }
QRCodeWiFiNetworkConfig >> initialize [ 

	super initialize.
	
	self wpa.
	self ssid: 'mynetwork'.
	self isHidden: false.
	self password: 'mypass'.
]

{ #category : #'API - network' }
QRCodeWiFiNetworkConfig >> isHidden [

	^ h
]

{ #category : #'API - network' }
QRCodeWiFiNetworkConfig >> isHidden: aBoolean [

	h := aBoolean
]

{ #category : #'API - authentication type - advanced' }
QRCodeWiFiNetworkConfig >> msChapV2 [

	ph2 := 'MSCHAPV2'
]

{ #category : #'API - authentication type' }
QRCodeWiFiNetworkConfig >> noPass [

	t := 'nopass'
]

{ #category : #'API - password' }
QRCodeWiFiNetworkConfig >> password [

	^ p
]

{ #category : #'API - password' }
QRCodeWiFiNetworkConfig >> password: aString [

	p := aString
]

{ #category : #initialization }
QRCodeWiFiNetworkConfig >> printOn: aStream [

	"Display head"
	t ifNil:[^'Error : bad Wi-Fi Network Config'].
	aStream nextPutAll: 'WIFI:'.

	"Display T"
	aStream nextPutAll: 'T:'; nextPutAll: (t ifNil:[''] asString); nextPut: $;.
	
	"Display S"
	aStream nextPutAll: 'S:'; nextPutAll: (s ifNil:[''] asString); nextPut: $;.
	
	"Display P"
	t = 'nopass' ifFalse:[ aStream nextPutAll: 'P:'; nextPutAll: (p ifNil:[''] asString); nextPut: $; ].
		
	"Display H"
	h ifTrue:[ aStream nextPutAll: 'H:true;' ].
		
	"Advanced settings only for WPA2-EAP"
	t = 'WPA2-EAP' ifTrue:[
		e ifNotNil:[ aStream nextPutAll: 'E:'; nextPutAll: e asString; nextPut: $; ].
		a ifNotNil:[ aStream nextPutAll: 'A:'; nextPutAll: a asString; nextPut: $; ].
		i ifNotNil:[ aStream nextPutAll: 'I:'; nextPutAll: i asString; nextPut: $; ].
		ph2 ifNotNil:[ aStream nextPutAll: 'PH2:'; nextPutAll: ph2 asString; nextPut: $; ].
	].
		
	"Display foot"
	aStream nextPut: $;.
]

{ #category : #'API - authentication type - advanced' }
QRCodeWiFiNetworkConfig >> pwd [

	e := 'PWD'
]

{ #category : #'API - network' }
QRCodeWiFiNetworkConfig >> ssid [

	^ s
]

{ #category : #'API - network' }
QRCodeWiFiNetworkConfig >> ssid: aString [

	s := aString.
]

{ #category : #'API - authentication type - advanced' }
QRCodeWiFiNetworkConfig >> ttls [

	e := 'TTLS'
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
QRCodeWiFiNetworkConfig >> wpa2Eap [

	t := 'WPA2-EAP'
]
