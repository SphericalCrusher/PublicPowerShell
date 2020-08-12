#Set Outlook Auto Responder Remotely 

Set-MailboxAutoReplyConfiguration -Identity katlyn.weeks -AutoReplyState Enabled -InternalMessage "Internal auto-reply message." -ExternalMessage "External auto-reply message."
