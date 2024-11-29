$remotehosts="172.15.1.11"
#in nested remoting use username as an example below
$username = "ENT-BACKUP-1\sysadmin"
$password = "M=WUd657tBxc877" | ConvertTo-SecureString -AsPlainText -Force
$pathdata = "E:\PWSH_script\temp_veeamservicestatus.csv"
#Region Define Exite code
$ExitCode=@{
    Up=0
    Down=1
    Warning=2
    Critical=3
    Unknown=4
}

# Create a PSCredential object using the username and password
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

#prepare Deployer configuration
$remotsession=New-PSSession -ComputerName $remotehosts -Credential $credential -Name rtunnel
Invoke-Command -Session $remotsession -ScriptBlock {
Get-Service | Where-Object {$_.name -like "*veeam*"}
} |  ForEach-Object {

    # Extract the service name and status
    $Service = $_
    switch ($Service.Status) 
     { 
     "Running" { $stat1=0 } 
     "stopped" { $stat1=1 } 
     "unknown" { $stat1=2 } 
     default { $stat1=3 }
     }
         # Display the service name and status with clear formatting
    if ($Service.Status -eq "running") {
        $status = "Running"
        Write-Host "Message.RunningService: $($Service.Name)" -ForegroundColor Green
        Write-Host "Statistic.RunningService: $stat1"
        Write-Host "Message.ServiceStatus: $($Service.Status)" -ForegroundColor Cyan
        Write-Host "Statistic.ServiceStatus: $stat1"
     
    }
    else {
        $status = "Stopped"
        Write-Host "Message.StoppedService: $($Service.Name)" -ForegroundColor red
        Write-Host "Statistic.StoppedService: $stat1"
        #Write-Host "Message.StoppedServicestatus: $($Service.Status)" -ForegroundColor Red
        #Write-Host "Statistic.StoppedServicestatus: $stat1"
     
    }

     
}
exit $ExitCode[$Status];




