
$remotehosts="172.15.1.11"
#in nested remoting use username as an example below
$username = "ENT-BACKUP-1\sysadmin"
$password = "M=WUd657tBxc877" | ConvertTo-SecureString -AsPlainText -Force

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
#set-Item WSMan:\localhost\Client\TrustedHosts -Value $remotehosts -force
$remotsession=New-PSSession -ComputerName $remotehosts -Credential $credential -Name rtunnel

$temp_veeam = Invoke-Command -Session $remotsession -ScriptBlock {
    $job_name = Get-VBRJob
    if ($job_name -ne $null)
    {
    # Iterate over each job and output its name, last result, and current state
    foreach ($job in $job_name) {
        $jobName = $job.Name
        $job_Result = (Get-VBRJob -Name $jobName).GetLastResult()
        $job_State = (Get-VBRJob -Name $jobName).GetLastState()
        $job_session = (Get-VBRJob -Name $jobName).FindLastSession()
    
        # Output the job information
        [PSCustomObject]@{
            JobName     = $jobName
            LastResult  = $job_Result
            LastState   = $job_State
            job_session = $job_session
        }
    
    if ( $job_session -eq $null )
    { $stat3=$stat4=$stat5=$stat6=0; }
    else
    {
    $stat3=$job_session.jobtypestring;
    $temp_stat4=$job_session.CreationTime;
    $temp_stat5=$job_session.EndTime;
    $stat4 = $temp_stat4.tostring("yyyy.MM.dd HH:mm")
    $stat5 = $temp_stat5.tostring("yyyy.MM.dd HH:mm")
    }
    }
    }
        else {
            Write-Host "Message: review powershell code"
            $status = "Critical"
            }
    
}
#EOF each
#counter for jobs number
$totaljobs = $temp_veeam.Count
$failedjobs = 0
$successjobs = 0
switch ($temp_veeam.LastResult) 
{ 
"Success" { $stat1=0 } 
"None" { $stat1=1 } 
"Failed" { $stat1=2 } 
default { $stat1=3 }
}
switch ($temp_veeam.LastState) 
{ 
"Stopped" { $stat2=0 } 
"Starting" { $stat2=1 } 
"Working" { $stat2=2 } 
"Stopping" { $stat2=3 } 
"Resuming" { $stat2=4 } 
"Pausing" { $stat2=5 } 
default { $stat2=6 }
}
foreach ($taskName in ($temp_veeam).JobName ) {
    if (($temp_veeam).LastResult -eq "failed") {
        $failedjobs ++
        Write-host "Message.FailedJobs: $taskname" -ForegroundColor red
        Write-host "Statistic.FailedJobs: $stat1" -ForegroundColor black
        
        $status = "Warning"
    }
else {
    $successjobs ++
    Write-host "Message.Successfulljobs: $taskname" -ForegroundColor green
    Write-host "Statistic.Successfulljobs: $stat1" -ForegroundColor black
    $status = "up"
}
}
#total Jobs report
Write-host "Statistic.TotalJobs: $totaljobs" -ForegroundColor yellow
Write-host "Statistic.Failedjobs: $failedjobs" -ForegroundColor yellow
Write-host "Statistic.Successfulljobs: $successjobs" -ForegroundColor yellow
exit $ExitCode[$Status];

