chcp 1251

SET InstallDir=E:\TCPChatServerService\
If not Exist %InstallDir% {
MkDir %InstallDir%
MkDir %InstallDir%\log
}
copy ".\Options.INI" %InstallDir%"\Options.INI"
copy ".\Users_DB.mdb" %InstallDir%"\Users_DB.mdb"
copy ".\TCPChatServerService.exe" %InstallDir%\TCPChatServerService.exe
SC CREATE "TCP_Chat_Service" binpath=  %InstallDir%\TCPChatServerService.exe
SC CONFIG TCP_Chat_Service start= auto
SC START TCP_Chat_Service