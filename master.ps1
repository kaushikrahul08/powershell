function ChangeDriveLetter
 { Param(
[Parameter(Mandatory=$True,
Position=1)]
[string]
[ValidatePattern("^[A-Z]{1}:{1}`$")]$NewDrvLetter
)
# Get Available CD/DVD Drive - Drive Type 5
$DvdDrv = Get-WmiObject -Class Win32_Volume -Filter "DriveType=5"
 
# Check if CD/DVD Drive is Available
if ($DvdDrv -ne $null)
{
 
# Get Current Drive Letter for CD/DVD Drive
$DvdDrvLetter = $DvdDrv | Select-Object -ExpandProperty DriveLetter
Write-Output "Current CD/DVD Drive Letter is $DvdDrvLetter"
 
# Confirm New Drive Letter is NOT used
if (-not (Test-Path -Path $NewDrvLetter))
{
 
# Change CD/DVD Drive Letter
$DvdDrv | Set-WmiInstance -Arguments @{DriveLetter="$NewDrvLetter"}
Write-Output "Updated CD/DVD Drive Letter as $NewDrvLetter"
}
else
{
Write-Output "Error: Drive Letter $NewDrvLetter Already In Use"
}
}
else
{
Write-Output "Error: No CD/DVD Drive Available !!"
}}

ChangeDriveLetter -NewDrvLetter N:

function Set-ServerDisk 
      { Param    
      ([Parameter(Mandatory=$true)] [string[]] $driveLetter,
       [Parameter(Mandatory=$True)]     [string[]]$labels)
        $disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
        $count = 0
        $labels = "Logs","Data"
        $driveLetter= "E","F"
       foreach ($disk in $disks)
       { 
$disk |Initialize-Disk -PartitionStyle GPT -PassThru |New-Partition -UseMaximumSize -DriveLetter $driveLetter[$count] | Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force 
         $count++
           }
           }

sleep 5;

Set-ServerDisk -driveLetter "E","F" -labels "Logs","Data"

sleep 10;

## Adding Web Server 
Add-WindowsFeature -Name Web-Server -IncludeAllSubFeature

# clean www root folder
Remove-Item C:\inetpub\wwwroot\* -Recurse -Force



# download Code 
$ZipBlobUrl = 'https://esusvnetdiag.blob.core.windows.net/customscript/Website.zip'
$ZipBlobDownloadLocation = 'E:\Website.zip'
(New-Object System.Net.WebClient).DownloadFile($ZipBlobUrl, $ZipBlobDownloadLocation)

# extract downloaded zip
$UnzipLocation = 'E:\'
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($ZipBlobDownloadLocation, $UnzipLocation)

# read write permission
$Path = "C:\inetpub\wwwroot\temp"
$User = "IIS AppPool\DefaultAppPool"
$Acl = Get-Acl $Path
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule($User, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $Path $Acl
