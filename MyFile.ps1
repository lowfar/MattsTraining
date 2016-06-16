. D:\DBA\HIP\DataIntegration\FileTransferFunctionsA.ps1
#config file
[string]$ConfiguartionFile = ""

$ConfiguartionFile = "D:\DBA\HIP\DataIntegration\HIPTest.config"

#check transfer is active , this is a value set in the configuration file
[string]$Active = ""
[int]$ProcessId = 0

$Active = GetConfigProperty -path $ConfiguartionFile -setting ProcessSettings -property Run

<# only added for testing
write-host $Active

#>

if ($Active -eq "No")
    #action taken if transfer is not active
    { write-host "Transfer is not activiated" }
elseif ($Active -eq "Yes")
    {
#e.g. \\server\folder
[String]$SourcePath = ""
[String]$DestinationPath  = ""

$SourcePath = GetConfigProperty -path $ConfiguartionFile -setting TransferSettings -property Source

$DestinationPath = GetConfigProperty -path $ConfiguartionFile -setting TransferSettings -property Destination

$ProcessId = GetConfigProperty -path $ConfiguartionFile -setting ProcessSettings -Property ProcessId

$CopyDestination = GetConfigProperty -path $ConfiguartionFile -setting TransferSettings -property CopyTo

#define variables used to control execution
[int]$SourceFileCount = 0

$SourceFileCount = (Get-ChildItem $SourcePath | Measure-Object).Count
$SourceFileSize = (Get-ChildItem $SourcePath -Filter "*.*" | Measure-Object -Property length -Sum)
# $size = "{0:N2}" -f ($SourceFileSize.Sum / 1MB) + " MB"
$SourceFileSizeFormatted = "{0:N2}" -f ($SourceFileSize.Sum / 1KB)

$HistoryId = LogTransferProcess -FileCount $SourceFileCount -ProcessId $ProcessId -FileSize $SourceFileSizeFormatted -FileSource $SourcePath -FileDestination $DestinationPath 

#string formatting for file names etc
[String]$RobocopyLog = ""
[String]$FileDatetime = ""

$RobocopyLog = GetConfigProperty  -path $ConfiguartionFile -setting ProcessSettings -property LogFileLocation
$RobocopyCopyActionLog = GetConfigProperty  -path $ConfiguartionFile -setting ProcessSettings -property LogFileLocationCopyAction

$FileDatetime = (Get-Date ).ToUniversalTime().ToString("yyyyMMddThhmmssZ")

$RobocopyLog = $RobocopyLog + $FileDatetime + ".log"
$RobocopyCopyActionLog = $RobocopyCopyActionLog + $FileDatetime + ".log"

if ($SourceFileCount -gt 0 )
    { 
	ROBOCOPY $SourcePath $DestinationPath /MT:32 /LOG:$RobocopyLog 
	ROBOCOPY $SourcePath $CopyDestination /MOV /MT:32 /LOG:$RobocopyCopyActionLog
	
	LogUpdateTransferEnd -HistoryId $HistoryId -LogFile $RobocopyLog
	}
else
	{
#     { write-host "no files" }
    LogUpdateTransferEnd -HistoryId $HistoryId -LogFile "no files"
 } #run no files 
 
 }#run if active





