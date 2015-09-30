# PSLDAPQueryLogging

This module simplifies enabling the [LDAP query diagnostic logging](http://blogs.technet.com/b/askpfeplat/archive/2015/05/11/how-to-find-expensive-inefficient-and-long-running-ldap-queries-in-active-directory.aspx) discussed by Mark Morowczynski.

This is a quick hit, didn't spend much time generalizing or testing. Pull requests would be welcome!

Functions:

* **Test-LDAPQueryLoggingPrerequisites** : Check to see if a domain controller meets the prerequisites for this logging
* **Enable-LDAPQueryLogging**            : Enable diagnostic logging and set parameters as discussed by Mark
* **Get-LDAPQueryLogging**               : Check the current state, including whether logging is enabled, and parameter values.
* **Disable-LDAPQueryLogging**           : Disable diagnostic logging and set parameters back to defaults

## Prerequisites:

* Access to the domain controller
* Server 2012 R2 *or*
* Server 2008, 2008 R2, or 2012 with [KB2800945](https://support.microsoft.com/en-us/kb/2800945/en-us)

## Instructions

```powershell
# Download PSLDAPQueryLogging
# https://github.com/RamblingCookieMonster/PSLDAPQueryLogging/archive/master.zip
# Unblock the archive
# Copy the PSLDAPQueryLogging module to one of your module paths ($env:PSModulePath -split ";")

# Import the module
    Import-Module PSLDAPQueryLogging -force

# Get commands from the module
    Get-Command -module PSLDAPQueryLogging

# Get help for a command
    Get-Help Test-LDAPQueryLoggingPrerequisites -Full
   
# Check if a domain controller has the prerequisites
Test-LDAPQueryLoggingPrerequisites -ComputerName DS1, DS2, DS3

# Enable logging temporarily on DS1 and DS2
Enable-LDAPQueryLogging -ComputerName DS1, DS2

# Verify the registry settings....
Get-LDAPQueryLogging -ComputerName DS1, DS2

# Collect your logs!
# Many ways to do this. Not PowerShell, but I find wevtutil to be quite fast.
Invoke-Command -ComputerName DS1, DS2 {wevtutil epl 'Directory Service' "\\$ENV:ComputerName\c$\$ENV:ComputerName-Evil.evtx"}

# Disable the logging...
Disable-LDAPQueryLogging -ComputerName DS1, DS2

# Parse events as desired, perhaps using Ming's script
    # https://gallery.technet.microsoft.com/scriptcenter/Event-1644-reader-Export-45205268

```

## Notes:

Thanks to Shay Levy for PSRemoteRegistry. To reduce dependencies, we borrow two functions from that module. PSRemoteRegistry should be in your toolbelt : )

Thanks to Mark Morowczynski, Ming Chen, and anyone else who contributed to the great [write-up](http://blogs.technet.com/b/askpfeplat/archive/2015/05/11/how-to-find-expensive-inefficient-and-long-running-ldap-queries-in-active-directory.aspx) on this topic

Stuff that might be fun:

* Collect the logs. wevtutil epl seems to be the fastest.
* Parse the logs. Maybe leave this to [the script](https://gallery.technet.microsoft.com/scriptcenter/Event-1644-reader-Export-45205268) from Ming Chen. Would be nice to have this analysis without COM though...
* Add rudimentary tests
* Clean up code and output
* Write an investigation-oriented blog post, when life calms down a bit : )
