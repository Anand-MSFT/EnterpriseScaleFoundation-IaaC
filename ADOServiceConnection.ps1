#Create self signed certificate for SP
$cert = New-SelfSignedCertificate -Subject "CN=ADOServiceConnectionTest" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256

