$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$transcriptPath = "$env:TEMP\SharePointDownload_$timestamp.txt"


Start-Transcript -Path $transcriptPath
Write-Host "Transcript started..." -ForegroundColor Cyan

#Function to Download All Files from a SharePoint Online Folder - Recursively 
Function Download-SPOFolder([Microsoft.SharePoint.Client.Folder]$Folder, $DestinationFolder)
{ 
    Write-Host "Processing folder: $($Folder.ServerRelativeUrl)" -ForegroundColor Cyan
    
    #Get the Folder's Site Relative URL
    $FolderURL = $Folder.ServerRelativeUrl.Substring($Folder.Context.Web.ServerRelativeUrl.Length)
    $LocalFolder = $DestinationFolder + ($FolderURL -replace "/","\")

    #Create Local Folder, if it doesn't exist
    If (!(Test-Path -Path $LocalFolder)) {
        New-Item -ItemType Directory -Path $LocalFolder | Out-Null
        Write-host -f Yellow "Created a New Folder '$LocalFolder'"
    }
            
    #Get all Files from the folder
    $FilesColl = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderURL -ItemType File
    Write-Host "Found $($FilesColl.Count) files to download..." -ForegroundColor Cyan
    
    #Iterate through each file and download
    Foreach($File in $FilesColl)
    {
        Get-PnPFile -ServerRelativeUrl $File.ServerRelativeUrl -Path $LocalFolder -FileName $File.Name -AsFile -force
        Write-host -f Green "`tDownloaded File from '$($File.ServerRelativeUrl)'"
    }

    #Get Subfolders of the Folder and call the function recursively
    $SubFolders = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderURL -ItemType Folder
    Write-Host "Processing $($SubFolders.Count) subfolders for $($FolderURL)..." -ForegroundColor Cyan

    Foreach ($SubFolder in $SubFolders | Where {$_.Name -ne "Forms"})
    {
        Write-Host "Calling recursive function for subfolder: $($SubFolder.ServerRelativeUrl)" -ForegroundColor Magenta
        Download-SPOFolder $SubFolder $DestinationFolder
    }
} 

#Set Parameters
$SiteURL = "https://thesomethingfoundation.sharepoint.com/subsite"
$FolderSiteRelativeURL = "/subsite/Foldername"
$DownloadPath ="$env:TEMP" #TargetFilePath
  
#Connect to PnP Online
Write-Host "Connecting to SharePoint Online at $SiteURL" -ForegroundColor Cyan
Connect-PnPOnline -Url $SiteURL -Interactive
Write-Host "Connected successfully!" -ForegroundColor Green
  
#Get the folder to download
Write-Host "Fetching details of folder: $FolderSiteRelativeURL" -ForegroundColor Cyan
$Folder = Get-PnPFolder -Url $FolderSiteRelativeURL
  
#Call the function to download all files from a folder
Download-SPOFolder $Folder $DownloadPath

Stop-Transcript
Write-Host "Transcript stopped. Check the log at $transcriptPath for details." -ForegroundColor Cyan

Start-Process $transcriptPath