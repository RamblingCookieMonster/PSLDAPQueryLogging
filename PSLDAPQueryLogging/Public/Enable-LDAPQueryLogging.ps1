Function Enable-LDAPQueryLogging {
    <#
    .SYNOPSIS
        Enable diagnostic LDAP query logging on a domain controller

    .DESCRIPTION
        Enable diagnostic LDAP query logging on a domain controller

        We set the Field Engineering data to 5, and set a few parameters to help catch the data

    .FUNCTIONALITY
        Active Directory

    .PARAMETER ComputerName
        One or more domain controllers

    .PARAMETER ExpensiveThreshold
        Set the 'Expensive Search Results Threshold' value's data to this. Default: 0

    .PARAMETER InefficientThreshold
        Set the 'Inefficient Search Results Threshold' value's data to this. Default: 0

    .PARAMETER SearchTimeThreshold
        Set the 'Search Time Threshold (msecs)' value's data to this. Default: 100

    .EXAMPLE
        Enable-LDAPQueryLogging -ComputerName DS1

        # Enable diagnostic logging on DS1

    .LINK
        https://github.com/RamblingCookieMonster/PSLDAPQueryLogging

    .LINK
        Get-LDAPQueryLogging

    .LINK
        Test-LDAPQueryLoggingPrerequisites

    .LINK
        Disable-LDAPQueryLogging

    .LINK
        http://blogs.technet.com/b/askpfeplat/archive/2015/05/11/how-to-find-expensive-inefficient-and-long-running-ldap-queries-in-active-directory.aspx
    #>	
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Computername = $ENV:ComputerName,

        [validaterange(0,2147483647)]
        [int]$ExpensiveThreshold = 0,

        [validaterange(0,2147483647)]
        [int]$InefficientThreshold = 0,

        [validaterange(0,2147483647)]
        [int]$SearchTimeThreshold = 100     
    )
    process
    {
        foreach($Computer in $ComputerName)
        {
            # Enable
            Try
            {
                Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'System\CurrentControlSet\Services\NTDS\Diagnostics' -Value '15 Field Engineering' -data 5 -force -Confirm:$False -ErrorAction Stop
            }
            Catch
            {
                Write-Error "Failed to enable logging on '$Computer'"
                Throw $_
            }

            # Set reasonably low thresholds
            Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Expensive Search Results Threshold' -data $ExpensiveThreshold -force -Confirm:$False
            Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Inefficient Search Results Threshold' -data $InefficientThreshold -force -Confirm:$False
            Set-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Search Time Threshold (msecs)' -data $SearchTimeThreshold -force -Confirm:$False
        }
    }
}