### CertificateValidationLevel Enum
### Defines validation levels for certificate checks

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

enum CertificateValidationLevel {
	None = 0      ### No validation performed
	Basic = 1     ### Check expiration date only
	Standard = 2  ### Check expiration date and key usage purposes
	Strict = 3    ### Full validation including certificate chain and revocation
}
