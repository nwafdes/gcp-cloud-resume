# get js file content & Extract the first line
$first_line = (Get-Content -Path "app\Frontend\interactions.js" | Select-Object -First 1)

# trim the first line 
$url = $first_line.Split("=")[1].trim()

# extract url
$old_url = $url.Substring(0, $url.Length -1)

# accept the new url
$new_url = Read-Host "Paste the new URL"

# replace the old with the new
Write-Host "Old Url >> $old_url"
Write-Host "New Url >> $new_url"

# (Get-Content -Raw -Path "app\Frontend\interactions.js").Replace($old_url, "'$new_url'")

Get-Content .\app\Frontend\interactions.js -Raw | ForEach-Object{
    $_.Replace($old_url, "'$new_url'")
 } | Set-Content ./app/Frontend/interactions.js -Force