#Parameters
$PnPSiteURL = "https://thesomethingfoundation.sharepoint.com/subsite" 
$FolderRelativeUrl = "/subsite/Shared Documents/Folder" #Folder Relative URL
$CSVFile = "$env:TEMP\SharePoint_FolderSizes11.csv" 

Connect-PnPOnline -Url $PnPSiteURL -Interactive
 
Try { 
    # Initialize total file count
    $TotalFileCount = 0 
    #Get all folders from the document library
    $Folders = Get-PnPListItem -List $ListName -PageSize 2000 | Where-Object { 
        $_.FileSystemObjectType -eq "Folder" -and 
        ($_.FieldValues.FileRef -like "$FolderRelativeUrl/*" -or $_.FieldValues.FileRef -eq $FolderRelativeUrl) 
    }
    
    #Calculate Folder Size from files
    $FolderSizeData = @()
    $Folders | ForEach-Object {
        #Extract Folder Size data
        $SizeInMB = [Math]::Round($_.FieldValues.SMTotalSize.LookupId / 1MB, 2) # Convert size to megabytes and round off to 2 decimal places
        
        $FolderSizeData += New-Object PSObject -Property  ([Ordered]@{
            "Folder Name"  = $_.FieldValues.FileLeafRef
            "URL" = $_.FieldValues.FileRef       
            "Size (MB)" = $SizeInMB  # Size column labeled as "Size (MB)"
        })
    }
    $FolderSizeData | Format-Table
    $FolderSizeData | Export-csv $CSVFile -NoTypeInformation
    #Calculate the Total Size of Folders
    $FolderSize = [Math]::Round((($FolderSizeData | Measure-Object -Property "Size (MB)" -Sum | Select-Object -expand Sum)),2)
    Write-host -f Green ("Total Size: {0} MB" -f $FolderSize)
}
Catch {
    Write-Host -f Red "Error:"$_.Exception.Message
}

Start-Process $CSVFile