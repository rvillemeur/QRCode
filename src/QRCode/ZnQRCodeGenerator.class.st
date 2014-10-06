"
To add a ZNQRCodeGenerator to a default Zinc server, do the following:

| generator |
generator := ZnQRCodeGenerator new.
ZnServer startDefaultOn: 8080.
ZnServer default delegate prefixMap at: 'qrcode' put: [ :request | generator handleRequest: request ].

Then, go to http://localhost:8080/qrcode to start generating QR and MicroQR codes.
"
Class {
	#name : #ZnQRCodeGenerator,
	#superclass : #Object,
	#category : #'QRCode-Server'
}

{ #category : #public }
ZnQRCodeGenerator >> handleRequest: request [
	| png |
	^ request uri pathPrintString caseOf: { 
		[ '/qrcode' ] -> [ "redirect to /qrcode/"
			ZnResponse redirect: '/qrcode/' ].
		[ '/qrcode/' ] -> [ "generation page"
			ZnResponse ok: (ZnEntity html: (self html: (ZnQRRequest fromRequest: request))) ].
		[ '/qrcode/qrcode.png' ] -> [ "a PNG for the request"
			[ png := (ZnQRRequest fromRequest: request) png ] ifError: [ :a :b | 
				"return not found on error"
				^ ZnResponse notFound: request uri pathPrintString ].
			ZnResponse ok: png ] }
		otherwise: [ "not found"
			ZnResponse notFound: request uri pathPrintString ]
]

{ #category : #public }
ZnQRCodeGenerator >> html: request [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: '<html>';
			crlf;
			nextPutAll: '<head>';
			crlf;
			nextPutAll: '<title>QR Code</title>';
			crlf;
			nextPutAll: '</head>';
			crlf;
			nextPutAll: '<body>';
			crlf;
			nextPutAll: '<h1>Generate "Quick Response" Code</h1>';
			crlf;
			nextPutAll: '<form action="/qrcode/" method="post">';
			crlf;
			nextPutAll: request edit;
			nextPutAll: '<input type="submit" value="Generate">';
			crlf;
			nextPutAll: '</form>';
			crlf;
			nextPutAll: request result;
			nextPutAll: '</body>';
			crlf;
			nextPutAll: '</html>' ]
]
