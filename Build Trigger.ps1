$user = 'test'
$token = '11e30f52613642a96d350c04a6558f834e'
$prevcommit = '82b6e2f6b58a0c036872eb27197de8fc8214896f'
$latestcommit = '83f0b9172c11a4f8f7763231a3445bd32c60aebf'

# The header is the username and token concatenated together
$pair = "$($user):$($token)"
# The combined credentials are converted to Base 64
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
# The base 64 credentials are then prefixed with "Basic"
$basicAuthValue = "Basic $encodedCreds"
# This is passed in the "Authorization" header
$Headers = @{
    Authorization = $basicAuthValue
}
# Make a request to get a crumb. This will be returned as JSON
$json = Invoke-WebRequest -Uri 'http://localhost:8080/crumbIssuer/api/json' -Headers $Headers
# Parse the JSON so we can get the value we need
$parsedJson = $json | ConvertFrom-Json
# See the value of the crumb
Write-Host "The Jenkins crumb is $($parsedJson.crumb)"

# Extract the crumb filed from the returned json, and assign it to the "Jenkins-Crumb" header
$BuildHeaders = @{
    "Jenkins-Crumb" = $parsedJson.crumb
    Authorization = $basicAuthValue
}
Invoke-WebRequest -Uri "http://localhost:8080/job/abcd/buildWithParameters?PreviousCommitId=$prevcommit&LatestCommitId=$latestcommit" -Headers $BuildHeaders -Method Post
    