chcp 1251
If not Exist "E:\TCPChatServerService" {
MkDir "E:\TCPChatServerService"
MkDir "E:\TCPChatServerService\log"
}
copy ".\Options.INI" "E:\TCPChatServerService\Options.INI"
copy ".\TCPChatServerService.exe" "E:\TCPChatServerService\TCPChatServerService.exe"
SC CREATE "TCP_Chat_Service" binpath= "E:\TCPChatServerService\TCPChatServerService.exe"
SC CONFIG TCP_Chat_Service start= auto
SC START TCP_Chat_Service