# QRCode
A QRCode generator for Pharo

# history
Initial code was created by Jochen Rick and hosted on smalltalkhub.

# usage
Here is how a ticket generates its own QR code:
```smalltalk
T123Ticket>>#asQRCode

^ self url asString asQRCode formWithQuietZone magnifyBy: 5
```

It is also easy  to combine the QR code with some text:

```smalltalk
T123Ticket >>#asQRCodeWithText

| form font |
form := Form extent: 535 @ 185 depth: 1.
font := LogicalFont familyName: ‘Bitmap DejaVu Sans’ pointSize: 14.
self asQRCode displayOn: form at: 0 @ 0.
form getCanvas
drawString: self url asString at: 180 @ 20 font: font color: Color black;
drawString: self id36, ‘ – ‘, ticketId asString at: 180 @ 45 font: font color: Color black;
drawString: (name ifNil: [ ‘N.N’ ]) at: 180 @ 90  font: font color: Color black;
drawString: (email ifNil: [ ‘@’ ]) at: 180 @ 115 font: font color: Color black;
drawString: (phone ifNil: [ ‘+’ ]) at: 180 @ 140 font: font color: Color black.
^ form
```

Next we combine this with a nice template designed by a graphics artist:
```smalltalk
T123Ticket >>#asQRCodeWithTextInTemplate
| templateFile form |
templateFile := ‘tickets123-template-{1}.jpg’ format: { self event id }.
form := PluginBasedJPEGReadWriter formFromFileNamed: templateFile.
self asQRCodeWithText displayOn: form at: 20@540.
^ form

```

And finally, the ticket form is encoded as a JPEG:

```smalltalk
T123Ticket >>#asJPEGBytes
^ ByteArray streamContents: [ :out |
PluginBasedJPEGReadWriter putForm: self asQRCodeWithTextInTemplate onStream: out ]
```

# reference
initial quote on using: https://pharoweekly.wordpress.com/2018/04/13/qrcode-a-thank-you-note/


