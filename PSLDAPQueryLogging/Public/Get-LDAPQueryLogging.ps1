function Get-LDAPQueryLogging {
<#
    .SYNOPSIS
        Check the diagnostic LDAP query logging settings on a domain controller

    .DESCRIPTION
        Check the diagnostic LDAP query logging settings on a domain controller

    .FUNCTIONALITY
        Active Directory

    .PARAMETER ComputerName
        One or more domain controllers

    .EXAMPLE
        Get-LDAPQueryLogging -ComputerName DS999

        Check to see what the LDAP logging registry values are set to on DS999
    
    .EXAMPLE
        'DS1', 'DS2' | Get-LDAPQueryLogging -ComputerName DS999

        Check to see what the LDAP logging registry values are set to on DS1 and DS2

    .LINK
        https://github.com/RamblingCookieMonster/PSLDAPQueryLogging

    .LINK
        Test-LDAPQueryLoggingPrerequisites

    .LINK
        Enable-LDAPQueryLogging

    .LINK
        Disable-LDAPQueryLogging

    .LINK
        http://blogs.technet.com/b/askpfeplat/archive/2015/05/11/how-to-find-expensive-inefficient-and-long-running-ldap-queries-in-active-directory.aspx
    #>	
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$Computername = $env:COMPUTERNAME
    )
    process
    {
        foreach($Computer in $ComputerName)
        {
            # Enable
            Try
            {
                Get-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'System\CurrentControlSet\Services\NTDS\Diagnostics' -Value '15 Field Engineering'
            }
            Catch
            {
                Write-Warning "$Computer`: $($_.Exception.Message)"
            }

            # Get reasonably thresholds
            Try
            {
                Get-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Expensive Search Results Threshold' -ErrorAction Stop
            }
            Catch
            {
                Write-Warning "$Computer`: $($_.Exception.Message)"
            }
            Try
            {
                Get-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Inefficient Search Results Threshold' -ErrorAction Stop
            }
            catch
            {
                Write-Warning "$Computer`: $($_.Exception.Message)"
            }
            Try
            {
                Get-RegDWord -ComputerName $Computer -Hive LocalMachine -Key 'SYSTEM\CurrentControlSet\Services\NTDS\Parameters' -Value 'Search Time Threshold (msecs)' -ErrorAction Stop
            }
            Catch
            {
                Write-Warning "$Computer`: $($_.Exception.Message)"
            }
        }
    }
}