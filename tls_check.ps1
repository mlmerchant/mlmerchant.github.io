function Get-TlsCertInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [int]$TimeoutSec = 10,

        [switch]$NoFollowRedirects
    )

    # Optional: pin TLS version if needed
    # [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $handler = New-Object System.Net.Http.HttpClientHandler
    if ($NoFollowRedirects) { $handler.AllowAutoRedirect = $false }

    # Variables to capture the cert and chain
    $script:ServerCert = $null
    $script:ServerChain = $null

    $handler.ServerCertificateCustomValidationCallback = {
        param($msg, $cert, $chain, $errors)
        $script:ServerCert  = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $cert
        $script:ServerChain = $chain
        $true
    }

    $client = [System.Net.Http.HttpClient]::new($handler)
    $client.Timeout = [TimeSpan]::FromSeconds($TimeoutSec)

    try {
        $null = $client.GetAsync($Uri).GetAwaiter().GetResult()
    } catch {
        # 401/403 expected if no auth token; ignore
    }

    $leaf = $script:ServerCert
    if (-not $leaf) {
        Write-Error "No certificate captured. Check DNS/SNI (use hostname not IP), port, and reachability."
        return
    }

    $sanExt = $leaf.Extensions | Where-Object { $_.Oid.Value -eq "2.5.29.17" }
    $sans = if ($sanExt) { $sanExt.Format($true) } else { "" }

    [pscustomobject]@{
        Subject      = $leaf.Subject
        Issuer       = $leaf.Issuer
        NotBefore    = $leaf.NotBefore
        NotAfter     = $leaf.NotAfter
        Thumbprint   = $leaf.Thumbprint
        SerialNumber = $leaf.SerialNumber
        SigAlgorithm = $leaf.SignatureAlgorithm.FriendlyName
        SAN          = $sans
        Chain        = ($script:ServerChain.ChainElements | ForEach-Object { $_.Certificate.Subject }) -join " -> "
    }
}
