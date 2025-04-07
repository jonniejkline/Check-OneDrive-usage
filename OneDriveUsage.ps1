$ShowStats = $false

$TenantName = 'Redacted'
$DomainName = 'Redacted'

$Group = "Redacted"

$UserIds = Get-MgGroupMember -GroupId $Group

$Users = foreach($user in $UserIds) {
    ((Get-MgUser -UserId $user.Id).UserPrincipalName -replace 'Redacted','') -replace '\.','_'
}

$CurrentGroupUsageGB = [decimal]0
$TotalGroupStorageGB = [int]0

foreach ($user in $Users) {
    try {
        $URL = "https://$($TenantName)-my.sharepoint.com/personal/$($user)_$($DomainName)"
        $Stats = Get-SPOSite -Identity $URL | select Owner, StorageUsageCurrent, StorageQuota, Status
        $Object = [PSCustomObject]@{
            Owner          = $Stats.Owner
            CurrentUsageGB = "{0:F3}" -f ($Stats.StorageUsageCurrent / 1024) -as [decimal]
            TotalStorageGB = "{0:F0}" -f ($Stats.StorageQuota / 1024) -as [int]
            Status         = $Stats.Status
        }
        if ($ShowStats){
            $Object
        }
        $CurrentGroupUsageGB += $Object.CurrentUsageGB
        $TotalGroupStorageGB += $Object.TotalStorageGB
    } catch {
        Write-Error $_.Exception.Message
    }
}
Write-Host "Current Group Usage: $(($CurrentGroupUsageGB / 1024) -as [decimal]) TB"
Write-Host "Total Group Storage: $(($TotalGroupStorageGB / 1024) -as [int]) TB"
