"
Based on a Zinc request, get the specifications from the fields and then generate the code based on those fields.
"
Class {
	#name : #ZnQRRequest,
	#superclass : #Object,
	#instVars : [
		'string',
		'micro',
		'errorCorrection',
		'quietZone',
		'mirror',
		'reverse',
		'magnifyBy',
		'code',
		'url'
	],
	#category : #'QRCode-Server'
}

{ #category : #'instance creation' }
ZnQRRequest class >> fromRequest: request [
	^ self new
		request: request;
		yourself
]

{ #category : #results }
ZnQRRequest >> canGeneratePng [
	^ code notNil
]

{ #category : #results }
ZnQRRequest >> codeInformation [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: '<em>Type</em>: ';
			nextPutAll: (code isMicro ifTrue: [ 'MicroQR Code' ] ifFalse: [ 'QR Code' ]);
			nextPutAll: '<br>';
			crlf;
			nextPutAll: '<em>Version</em>: ';
			nextPutAll: code version asString;
			nextPutAll: '<br>';
			crlf;
			nextPutAll: '<em>Encoding</em>: ';
			nextPutAll: code encoding asString;
			nextPutAll: '<br>';
			crlf;
			nextPutAll: '<em>Error Correction</em>: ';
			nextPutAll: code errorCorrection asString;
			nextPutAll: '<br>';
			crlf;
			nextPutAll: '<em>Content</em>: ';
			nextPutAll: code string asHTMLString ]
]

{ #category : #'default values' }
ZnQRRequest >> defaultErrorCorrection [
	^ nil
]

{ #category : #'default values' }
ZnQRRequest >> defaultMagnifyBy [
	^ 10
]

{ #category : #'default values' }
ZnQRRequest >> defaultMicro [
	^ false
]

{ #category : #'default values' }
ZnQRRequest >> defaultMirror [
	^ false
]

{ #category : #'default values' }
ZnQRRequest >> defaultQuietZone [
	^ true
]

{ #category : #'default values' }
ZnQRRequest >> defaultReverse [
	^ false
]

{ #category : #editing }
ZnQRRequest >> edit [
	^ String streamContents: [ :stream | stream
		nextPutAll: '<table>';
		crlf;
		nextPutAll: '<tr><td>Text</td><td>';
		nextPutAll: self editString;
		nextPutAll: '</td></tr>';
		crlf;
		nextPutAll: '<tr><td>Type</td><td>';
		nextPutAll: self editMicro;
		nextPutAll: '</td></tr>';
		crlf;
		nextPutAll: '<tr><td>Error Correction</td><td>';
		nextPutAll: self editErrorCorrection;
		nextPutAll: '</td></tr>';
		crlf;
		nextPutAll: '<tr><td>Magnify</td><td>';
		nextPutAll: self editMagnifyBy;
		nextPutAll:'</td></tr>';
		crlf;
		nextPutAll: '<tr><td>Quiet Zone</td><td>';
		nextPutAll: self editQuietZone;
		nextPutAll: '</td></tr>';
		crlf;
		nextPutAll: '<tr><td>Reverse</td><td>';
		nextPutAll: self editReverse;
		nextPutAll: '</td></tr>';
		crlf;
		nextPutAll: '<tr><td>Mirror</td><td>';
		nextPutAll: self editMirror;
		nextPutAll: '</td></tr>';
		crlf;
		nextPutAll: '</table>';
		crlf ]
]

{ #category : #editing }
ZnQRRequest >> editErrorCorrection [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: '<select name="errorCorrection">';
			crlf;
			nextPutAll: '<option value="nil"'.
		errorCorrection ifNil: [ stream
			nextPutAll: ' selected' ].
		stream
			nextPutAll: '>prioritize size</option>';
			crlf;
			nextPutAll: '<option value="L"'.
		errorCorrection = $L ifTrue: [ stream
			nextPutAll: ' selected' ].
		stream
			nextPutAll: '>L - 7% recovery</option>';
			crlf;
			nextPutAll: '<option value="M"'.
		errorCorrection = $M ifTrue: [ stream
			nextPutAll: ' selected' ].
		stream
			nextPutAll: '>M - 15% recovery</option>';
			crlf;
			nextPutAll: '<option value="Q"'.
		errorCorrection = $Q ifTrue: [ stream
			nextPutAll: ' selected' ].
		stream
			nextPutAll: '>Q - 25% recovery</option>';
			crlf;
			nextPutAll: '<option value="H"'.
		errorCorrection = $H ifTrue: [ stream
			nextPutAll: ' selected' ].
		stream
			nextPutAll: '>H - 30% recovery</option>';
			crlf;
			nextPutAll: '</select>' ]
]

{ #category : #editing }
ZnQRRequest >> editMagnifyBy [
	^ '<input name="magnifyBy" type="text" size=2 value="', magnifyBy asString, '"> (a number between 1 and 20)'
]

{ #category : #editing }
ZnQRRequest >> editMicro [
	^ micro
		ifTrue: [ '<input name="micro" type="radio" value="false">standard (ubiquitous use with three finder patterns)<br><input name="micro" type="radio" value="true" checked>micro (more compact with one finder pattern, but few readers support it)' ]
		ifFalse: [ '<input name="micro" type="radio" value="false" checked>standard (ubiquitous use with three finder patterns)<br><input name="micro" type="radio" value="true">micro (more compact with one finder pattern, but few readers support it)' ]
]

{ #category : #editing }
ZnQRRequest >> editMirror [
	^ '<input name="mirror" type="checkbox" value="true"', (mirror ifTrue: [ 'checked' ] ifFalse: [ '' ]), '>flip image horizontally (not recommended)'
]

{ #category : #editing }
ZnQRRequest >> editQuietZone [
	^ '<input name="quietZone" type="checkbox" value="true"', (quietZone ifTrue: [ 'checked' ] ifFalse: [ '' ]), '>add a border (recommended for reading)'
]

{ #category : #editing }
ZnQRRequest >> editReverse [
	^ '<input name="reverse" type="checkbox" value="true"', (reverse ifTrue: [ ' checked' ] ifFalse: [ '' ]), '>invert colors (i.e., white on black)'
]

{ #category : #editing }
ZnQRRequest >> editString [
	^ '<textarea name="string" rows=4 cols=60 wrap=virtual>', string asHTMLString, '</textarea>'
]

{ #category : #'default values' }
ZnQRRequest >> maxMagnifyBy [
	^ 20
]

{ #category : #results }
ZnQRRequest >> png [
	"Return the PNG entity for the QR Code"
	| form |
	form := quietZone ifTrue: [ code formWithQuietZone ] ifFalse: [ code form ].
	magnifyBy = 1 ifFalse: [ form := form magnifyBy: magnifyBy ].
	^ ZnByteArrayEntity
		with: (ByteArray streamContents: [ :out |
			(PNGReadWriter on: out) nextPutImage: form ])
		type: ZnMimeType imagePng.
]

{ #category : #results }
ZnQRRequest >> pngReference [
	^ String streamContents: [ :stream | stream
		nextPutAll: '<a href="';
		nextPutAll: url;
		nextPutAll: '" download="qrcode.png"><img border=';
		nextPutAll: (magnifyBy + 1 // 2) asString;
		nextPutAll: ' src="';
		nextPutAll: url;
		nextPutAll: '" alt="click to download"></a>' ]
]

{ #category : #'initialize-release' }
ZnQRRequest >> request: request [
	| fields |
	fields := request mergedFields.
	string := fields at: #string ifAbsent: [ '' ].
	micro := (fields includesKey: #micro)
		ifTrue: [ (fields at: #micro) = 'true' ]
		ifFalse: [ self defaultMicro ].
	micro := (fields at: #micro ifAbsent: [ 'false' ]) = 'true'.
	errorCorrection := fields at: #errorCorrection ifAbsent: [ self defaultErrorCorrection ].
	errorCorrection isString ifTrue: [ 
		errorCorrection := (errorCorrection size = 1 and: [ 'LMQH' includes: errorCorrection first ])
			ifTrue: [ errorCorrection first ]
			ifFalse: [ nil ] ].
	quietZone := (fields includesKey: #quietZone)
		ifTrue: [ (fields at: #quietZone) = 'true' ]
		ifFalse: [ self defaultQuietZone ].
	magnifyBy := (fields includesKey: #magnifyBy)
		ifTrue: [ 
			magnifyBy := fields at: #magnifyBy.
			magnifyBy isAllDigits
				ifTrue: [ ((magnifyBy asNumber) max: 1) min: self maxMagnifyBy ]
				ifFalse: [ self defaultMagnifyBy ] ]
		ifFalse: [ self defaultMagnifyBy ].
	mirror := (fields includesKey: #mirror)
		ifTrue: [ (fields at: #mirror) = 'true' ]
		ifFalse: [ self defaultMirror ].
	reverse := (fields includesKey: #reverse)
		ifTrue: [ (fields at: #reverse) = 'true' ]
		ifFalse: [ self defaultReverse ].
	string isEmpty ifFalse: [ 
		"Generate the Code"
		code := [ (micro ifTrue: [ MicroQRCodeEncoder ] ifFalse: [ QRCodeEncoder ]) codeForString: string errorCorrection: errorCorrection ] ifError: [ :a :b | nil ] ].
	code ifNotNil: [ 
		reverse ifTrue: [ code reverse ].
		mirror ifTrue: [ code mirror ].
		"Generate the URL to the PNG"
		url := ZnUrl new
			addPathSegment: 'qrcode';
			addPathSegment: 'qrcode.png';
			queryAt: 'string' put: string.
		errorCorrection = self defaultErrorCorrection ifFalse: [ url
			queryAt: 'errorCorrection' put: errorCorrection asString ].
		micro = self defaultMicro ifFalse: [ url
			queryAt: 'micro' put: micro asString ].
		quietZone = self defaultQuietZone ifFalse: [ url
			queryAt: 'quietZone' put: quietZone asString ].
		magnifyBy = self defaultMagnifyBy ifFalse: [ url
			queryAt: 'magnifyBy' put: magnifyBy asString ].
		mirror = self defaultMirror ifFalse: [ url
			queryAt: 'mirror' put: mirror asString ].
		reverse = self defaultReverse ifFalse: [ url
			queryAt: 'reverse' put: reverse asString ].
		url := url asString ]
]

{ #category : #results }
ZnQRRequest >> result [
	"If there is no string, then no request was made"
	string isEmpty ifTrue: [ ^ '' ].
	^ String streamContents: [ :stream |
		stream
			nextPutAll: '<h1>Result</h1>';
			crlf.
		self canGeneratePng
			ifTrue: [ stream
				nextPutAll: '<table>';
				crlf;
				nextPutAll: '<tr><td>';
				nextPutAll: self pngReference;
				nextPutAll: '</td><td>';
				nextPutAll: self codeInformation;
				nextPutAll: '</td></tr>';
				crlf;
				nextPutAll: '</table>';
				crlf ]
			ifFalse: [ micro
				ifTrue: [ stream nextPutAll: '<p>This text cannot be generated as a MicroQR Code; it is too long.</p>' ]
				ifFalse: [ stream nextPutAll: '<p>This text cannot be generated as a QR Code.</p>' ] ] ]
]
