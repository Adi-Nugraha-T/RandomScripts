How to use
1. download the folder as zip
2. upload as application to VNware WS UEM
3. use below as uninstall command
   powershell -executionpolicy bypass -file ChangeDesktopBack.ps1
4. Set install context as user and command line
   powershell -executionpolicy bypass -file ChangeDesktop.ps1
6. Detect registry for Install complete criteria
   Registry Exists - HKCU\Control Panel\Desktop
   Registry Value - Value Name : CustomWallUEM
                    Value Type : String
                    Value Data : Equal - edit as per the script (default to uem)
8. to add new version remember to edit ChangeDesktop.ps1 CustomWallUEM to a different value from previously used and change the complete criteria
   
