function Test-LDAPQueryLoggingPrerequisites {
<#
    .SYNOPSIS
        Check if prerequisites for diagnostic LDAP query logging are in place on a domain controller

    .DESCRIPTION
        Check if prerequisites for diagnostic LDAP query logging are in place on a domain controller

        Prerequisites:
            - On operating systems prior to 2012 R2, KB2800945 must be installed
                https://support.microsoft.com/en-us/kb/2800945/en-us
            - Access to the domain controller over remote registry

    .FUNCTIONALITY
        Active Directory

    .PARAMETER ComputerName
        One or more domain controllers

    .EXAMPLE
        Test-LDAPQueryLoggingPrerequisites -ComputerName DS1

        # Check if we can enable LDAP query logging on DS1
    
    .LINK
        https://github.com/RamblingCookieMonster/PSLDAPQueryLogging

    .LINK
        Get-LDAPQueryLogging

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
    begin
    {
        #Black list easier than white list...
        $PatchNeeded = '6.2',
                       '6.1',
                       '6.0'
    }
    process
    {
        foreach($Computer in $ComputerName)
        {
            $Props = echo ComputerName, Prerequisite, Status, Detail
            # Remote registry?
            Try
            {
                $Version = $null
                $Version = Get-RegValue -ComputerName $Computer -Hive LocalMachine -Key 'SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Value 'CurrentVersion' -ErrorAction Stop |
                    Select -ExpandProperty Data

                if($PatchNeeded -contains $Version)
                {
                    # Patch?
                    Try
                    {
                        $null = Get-HotFix -ComputerName $Computer -Id KB2800945 -ErrorAction Stop
                        $Status = $True
                        $Detail = $null
                    }
                    Catch
                    {
                        $Status = $False
                        $Detail = $_.Exception.Message
                    }
                }
                else
                {
                    $Status = $True
                    $Detail = 'NA'
                }

                New-Object -TypeName PSObject -Property @{
                    ComputerName = $Computer
                    Prerequisite = 'KB2800945'
                    Status = $Status
                    Detail = $Detail
                } | Select $Props

                #Back to registry stuff....
                $Status = $True
                $Detail = $null
            }
            Catch
            {
                $Status = $False
                $Detail = $_.Exception.Message
            }

            New-Object -TypeName PSObject -Property @{
                ComputerName = $Computer
                Prerequisite = 'RemoteRegistry'
                Status = $Status
                Detail = $Detail
            } | Select $Props
        }
    }
}