# Parameters for the first document library
$PnPSiteURL1 = "https://thesomethingfoundation.sharepoint.com/subsite"
$LibraryName1 = "Shared Documents"
$CSVPath1 = "C:\temp\LibraryFiles3.csv"

# Parameters for the second document library
$PnPSiteURL = "https://thesomethingfoundation.sharepoint.com/sites/LindseyTestTeam"
$LibraryName = "Shared Documents"
$CSVPath = "C:\temp\LibraryFilesLindseyTest.csv"

# Function to connect to SharePoint, get file count, and export to CSV
Function Export-LibraryFilesToCSV {
    param (
        [string]$SiteURL,
        [string]$LibraryName,
        [string]$CSVPath
    )

    # Connect to SharePoint Online
    Connect-PnPOnline -Url $SiteURL -Interactive

    # Get all items in the document library and count files
    $AllItems = Get-PnPListItem -List $LibraryName -PageSize 500
    $FileCount = ($AllItems | Where-Object { $_.FileSystemObjectType -eq "File" }).Count

    # Output the file count
    Write-Host "Total number of files in '$LibraryName': $FileCount"

    # Export the list of files to a CSV with an additional column for file size
    $AllItems | Where-Object { $_.FileSystemObjectType -eq "File" } |
        Select-Object @{Name="Title";Expression={$_.FieldValues.FileLeafRef}},
                      @{Name="URL";Expression={$_.FieldValues.FileRef}},
                      @{Name="Size (KB)";Expression={$_.FieldValues.File_x0020_Size/1024 -as [int]}} |
        Export-Csv -Path $CSVPath -NoTypeInformation

    # Output the path to the CSV file
    Write-Host "A CSV file containing a list of all files along with their sizes has been exported to $CSVPath"

    # Disconnect the session
    Disconnect-PnPOnline
}

# Call the function for both document libraries
Export-LibraryFilesToCSV -SiteURL $PnPSiteURL1 -LibraryName $LibraryName1 -CSVPath $CSVPath1
Export-LibraryFilesToCSV -SiteURL $PnPSiteURL2 -LibraryName $LibraryName2 -CSVPath $CSVPath2

# Compare the CSV files for differences on the filename column
$CSV1 = Import-Csv -Path $CSVPath1
$CSV2 = Import-Csv -Path $CSVPath2

$Diff = Compare-Object -ReferenceObject $CSV1.Title -DifferenceObject $CSV2.Title

# Output the differences
$Diff | ForEach-Object {
    if ($_.SideIndicator -eq "<=") {
        Write-Host "$($_.InputObject) is in $CSVPath1 but not in $CSVPath2"
    } elseif ($_.SideIndicator -eq "=>") {
        Write-Host "$($_.InputObject) is in $CSVPath2 but not in $CSVPath1"
    }
}
