function Set-ServerDisk 
      { Param    
      ([Parameter(Mandatory=$true)] [string[]] $driveLetter,
       [Parameter(Mandatory=$True)]     [string[]]$labels)
        $disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
        $count = 0
        #$labels = "data","logs"
        #$driveLetter= "F"
       foreach ($disk in $disks)
       { 
$disk |Initialize-Disk -PartitionStyle GPT -PassThru |New-Partition -UseMaximumSize -DriveLetter $driveLetter[$count] | Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force 
         $count++
           }
           }

Set-ServerDisk -driveLetter "F" -labels "Data"
Set-ServerDisk -driveLetter "E" -labels "Logs"
