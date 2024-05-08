#To find file count in Doc Library
# Parameters
$PnPSiteURL = "https://thesomethingfoundation.sharepoint.com/sites/LindseyTestTeam"
$LibraryName = "Documents" # The internal name of the document library

# Connect to SharePoint Online
Connect-PnPOnline -Url $PnPSiteURL -Interactive

# Get all items in the document library and count files
$AllItems = Get-PnPListItem -List $LibraryName -PageSize 500
$FileCount = ($AllItems | Where-Object { $_.FileSystemObjectType -eq "File" }).Count

# Output the file count
Write-Host "Total number of files in '$LibraryName': $FileCount"

# Disconnect the session
Disconnect-PnPOnline


