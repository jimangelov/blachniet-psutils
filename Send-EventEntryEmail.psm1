<#
The MIT License (MIT)

Copyright (c) 2013 Brian Lachniet

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

<#
.SYNOPSIS
Sends information about one or more events in the EventLog in an email from a GMail account.

.DESCRIPTION
Sends information about one or more events in the EventLog in an email from a GMail account.
This script allows you to specify the email account you are sending the message from, the 
event source, the number of events to retrieve, and more. This script could be particularly
useful as a scheduled task that is triggered off of an event.

.PARAMETER LogName
The name of the log to look for the event in. Defaults to Application.

.PARAMETER Source
The event log source that will be retrieved. Defaults to AthleteDataSync.

.PARAMETER Newest
The number of latest events to retrieve. Defaults to 1.

.PARAMETER EntryType
The types of entries to look for. Defaults to Error.

.PARAMETER SmtpUser
The user name used to login to the gmail account.

.PARAMETER SmtpPassword
The password used to log into the user account.

.PARAMETER MailFrom
The email address that the message is from.. Takes the form of "Display Name <address@gmail.com>".

.PARAMETER MailTo
A comma-separated list of email addresses to send the email to.

.PARAMETER Subject
The subject line of the email. Defaults to 'EventLogAlert'.

.EXAMPLE
.\Send-EventEntryEmail.ps1 -Source 'MyApp' -SmtpUser 'example@gmail.com' -SmtpPassword 'password' -MailFrom 'Example User <example@gmail.com' -MailTo 'elpmaxe@gmail.com'

Description
-----------
A simple example with the miniumum number of parameters specified.

.EXAMPLE
.\Send-EventEntryEmail.ps1 -Source 'MyApp' -SmtpUser 'example@gmail.com' -SmtpPassword 'password' -MailFrom 'Example User <example@gmail.com' -MailTo 'elpmaxe@gmail.com,plexample@gmail.com'

Description
-----------
Sends an email to multiple email addresses.

.EXAMPLE
.\Send-EventEntryEmail.ps1 -Source 'MyApp' -SmtpUser 'example@gmail.com' -SmtpPassword 'password' -MailFrom 'Example User <example@gmail.com' -MailTo 'elpmaxe@gmail.com,plexample@gmail.com' -EntryType Error, Warning -Newest 10

Description
-----------
Includes Error and Warning event entry types, and includes the last 10 entries.

.LINK 
http://blachniet.com
#>

Function Send-EventEntryEmail{

    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $LogName = "Application",
    
        [Parameter(Mandatory=$true)]
        [string] $Source,
    
        [Parameter()]
        [int] $Newest = 1,
    
        [Parameter()]
        [string[]] $EntryType = "Error",
    
        [Parameter(Mandatory=$true)]
        [string] $SmtpUser,
    
        [Parameter(Mandatory=$true)]
        [string] $SmtpPassword,
    
        [Parameter()]
        [int] $SmtpPort = 587,
    
        [Parameter()]
        [string] $SmtpServer = "smtp.gmail.com",
    
        [Parameter(Mandatory=$true)]
        [string] $MailFrom,
    
        [Parameter(Mandatory=$true)]
        [string] $MailTo,
    
        [Parameter()]
        [string] $Subject = "EventLogAlert"
    )

    # Get the event entries.
    $eventEntries = Get-EventLog -LogName $LogName -Source $Source -Newest $Newest -EntryType $EntryType

    # Create a table row for each entry.
    $rows = ""
    foreach ($eventEntry in $eventEntries){
        $rows += @"
        <tr>
            <td style="text-align: center; padding: 5px;">$($eventEntry.TimeGenerated)</td>
            <td style="text-align: center; padding: 5px;">$($eventEntry.EntryType)</td>
            <td style="padding: 5px;">$($eventEntry.Message)</td>
        </tr>
"@
    }

    # Create the email.
    $email = New-Object System.Net.Mail.MailMessage( $MailFrom , $MailTo )
    $email.Subject = $Subject
    $email.IsBodyHtml = $true
    $email.Body = @"
    <table style="width:100%;border">
        <tr>
            <th style="text-align: center; padding: 5px;">Time</th>
            <th style="text-align: center; padding: 5px;">Type</th>
            <th style="text-align: center; padding: 5px;">Message</th>
        </tr>
    
    $rows

    </table>
"@

    # Send the email.
    $SMTPClient=New-Object System.Net.Mail.SmtpClient( $SmtpServer , $SmtpPort )
    $SMTPClient.EnableSsl=$true
    $SMTPClient.Credentials=New-Object System.Net.NetworkCredential( $SmtpUser , $SmtpPassword );
    $SMTPClient.Send( $email )
}

Export-ModuleMember Send-EventEntryEmail
