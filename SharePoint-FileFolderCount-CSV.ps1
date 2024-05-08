# Parameters for the document library
$PnPSiteURL = "https://thesomethingfoundation.sharepoint.com/sites/LindseyTestTeam"
$LibraryName = "Shared Documents"
$CSVPath = "C:\temp\LibraryFilesLindseyTest.csv"

# Function to connect to SharePoint, get file details, and export to CSV
Function Export-LibraryDetailsToCSV {
    param (
        [string]$SiteURL,
        [string]$LibraryName,
        [string]$CSVPath
    )

    # Connect to SharePoint Online
    Connect-PnPOnline -Url $SiteURL -Interactive

    # Get all items in the document library
    $AllItems = Get-PnPListItem -List $LibraryName -PageSize 500 -Fields "FileLeafRef", "FileDirRef"

    # Get the file count
    $FileCount = ($AllItems | Where-Object { $_.FileSystemObjectType -eq "File" }).Count

    # Output the file count
    Write-Host "Total number of files in '$LibraryName': $FileCount"

    # Prepare data for CSV export
    $DataForCSV = $AllItems | Where-Object { $_.FileSystemObjectType -eq "File" } | 
        Select-Object @{Name="Folder";Expression={$_.FieldValues.FileDirRef.Split("/") | Select-Object -Last 1}},
                      @{Name="FileName";Expression={$_.FieldValues.FileLeafRef}},
                      @{Name="FileCount";Expression={$FileCount}}

    # Export to CSV
    $DataForCSV | Export-Csv -Path $CSVPath -NoTypeInformation

    # Output the path to the CSV file
    Write-Host "A CSV file containing a list of all files along with their folder names and total file count has been exported to $CSVPath"

    # Disconnect the session
    Disconnect-PnPOnline
}

# Call the function
Export-LibraryDetailsToCSV -SiteURL $PnPSiteURL -LibraryName $LibraryName -CSVPath $CSVPath
