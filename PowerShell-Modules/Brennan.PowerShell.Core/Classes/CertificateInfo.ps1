### CertificateInfo Class
### Wraps X509Certificate2 with validation and metadata

### Author  : Chris Brennan
### Email   : chris@brennantechnologies.com
### Company : Brennan Technologies, LLC
### Version : 1.0
### Date    : 2025-12-14

class CertificateInfo {
	[string]$Thumbprint
	[string]$Subject
	[string]$Issuer
	[datetime]$NotBefore
	[datetime]$NotAfter
	[bool]$IsValid
	[string[]]$ValidationErrors
	[System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate

	### Constructor from certificate object
	CertificateInfo([System.Security.Cryptography.X509Certificates.X509Certificate2]$cert) {
		$this.Certificate = $cert
		$this.Thumbprint = $cert.Thumbprint
		$this.Subject = $cert.Subject
		$this.Issuer = $cert.Issuer
		$this.NotBefore = $cert.NotBefore
		$this.NotAfter = $cert.NotAfter
		$this.ValidationErrors = @()
		$this.Validate()
	}

	### Validate certificate
	[void]Validate() {
		$this.IsValid = $true

		### Check expiration
		$now = Get-Date
		if ($now -lt $this.NotBefore) {
			$this.ValidationErrors += "Certificate not yet valid"
			$this.IsValid = $false
		}
		if ($now -gt $this.NotAfter) {
			$this.ValidationErrors += "Certificate has expired"
			$this.IsValid = $false
		}
	}

	### Get days until expiration
	[int]DaysUntilExpiration() {
		return ($this.NotAfter - (Get-Date)).Days
	}

	### Check if certificate is expiring soon
	[bool]IsExpiringSoon([int]$daysThreshold) {
		$daysLeft = $this.DaysUntilExpiration()
		return ($daysLeft -le $daysThreshold -and $daysLeft -gt 0)
	}

	### Get formatted subject CN
	[string]GetCommonName() {
		if ($this.Subject -match 'CN=([^,]+)') {
			return $matches[1]
		}
		return $this.Subject
	}
}
