Connect-PnPOnline -Url https://thesomethingfoundation.sharepoint.com/sites/restricted -Interactive
Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } | Select Title, Id