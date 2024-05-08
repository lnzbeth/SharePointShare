#Params
Connect-PnPOnline -Url "https://thesomethingfoundation.sharepoint.com/" -Interactive
$SiteURL = "https://thesomethingfoundation.sharepoint.com/"
$SourceFolderURL= "/subsitename/Shared Documents/Foldername" #Site Relative URL from the current site
$TargetFolderURL = "/subsitename/Shared Documents/foldername" #Server Relative URL of the Target Parent Folder

#move folder between sites in sharepoint online using powershell
#Move-PnPFile -SiteRelativeUrl $SourceFolderURL -TargetUrl $TargetFolderURL -Force -AllowSchemaMismatch
Copy-PnPFile -SourceUrl $SourceFolderURL -TargetUrl $TargetFolderURL -Force


#Read more: https://www.sharepointdiary.com/2017/06/how-to-move-folder-in-sharepoint-online.html#ixzz83mrJ5h9S


