Function Disable-LDAPQueryLogging {
<#
    .SYNOPSIS
        Disable diagnostic LDAP query logging on a domain controller

    .DESCRIPTION
        Disable diagnostic LDAP query logging on a domain controller

        We set the Field Engineering data to 0, and set a few parameters back to the defaults

    .FUNCTIONALITY
        Active Directory

    .PARAMETER ComputerName
        One or more domain controllers

    .PARAMETER ExpensiveThreshold
        Set the 'Expensive Search Results Threshold' value's data to this. Default: 10,000

    .PARAMETER InefficientThreshold
        Set the 'Inefficient Search Results Threshold' value's data to this. Default: 1,000

    .PARAMETER SearchTimeThreshold
        Set the 'Search Time Threshold (msecs)' value's data to this. Default: 30,000

    .EXAMPLE
        Disable-LDAPQueryLogging -ComputerName DS1

        # Disable diagnostic logging on DS1

    .LINK
        https://github.com/RamblingCookieMonster/PSLDAPQueryLogging

    .LINK
        Test-LDAPQueryLoggingPrerequisites

    .LINK
        Enable-LDAPQueryLogging

    .LINK
        Get-LDAPQueryLogging

    .LINK
        http://blogs.technet.com/b/askpfeplat/archive/2015/05/11/how-to-find-expensive-inefficient-and-long-running-ldap-queries-in-active-directory.aspx
    #>	
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [validaterange(0,2147483647)]
        [int]$ExpensiveThreshold = 10000,

        [validaterange(0,2147483647)]
        [int]$InefficientThreshold = 1000,

        [validaterange(0,2147483647)]
        [int]$SearchTimeThreshold = 30000
    )
    process
    {
        foreach($Computer in $ComputerName)
        {
            # Disable
            Try
            {
                Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'System\CurrentControlSet\Services\NTDS\Diagnostics' -Value '15 Field Engineering' -data 0 -force -Confirm:$False
            }
            Catch
            {
                Write-Error "Failed to disable logging on '$Computer'"
                Throw $_
            
            }
        
            # Set default thresholds
            Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Expensive Search Results Threshold' -data $ExpensiveThreshold -force -Confirm:$False
            Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Inefficient Search Results Threshold' -data $InefficientThreshold -force -Confirm:$False
            Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Search Time Threshold (msecs)' -data $SearchTimeThreshold -force -Confirm:$False
        }
    }
}