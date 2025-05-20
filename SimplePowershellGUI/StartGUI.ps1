#=============================================================================================================
#This script is meant to identify the running environment, i.e:
#If it's in 32-bit or 64-bit shell, running as SYSTEM or user account, in Interactive or Non-Interactive shell
#
#And then run C-Sharp code (if necessary) to display a GUI to the currently logged on user
#
#Intended to be used in Configuration Manager or Intune applications/packages/scripts/task sequences
#
#Visit the github for more information:
#https://github.com/Ake-Andersson/SimplePowershellGUI
#=============================================================================================================

Write-Host "========== StartGUI.ps1 START =========="

#Default Exit code if an exit code from the GUI isn't returned, such as if no user is logged in
$GUIExitCode = 1621

#Path to the GUI Script
$GUIScriptPath = "$($PSScriptRoot)\SimplePowershellGUI.ps1"

#Get the path to Powershell
$CurrentProcess = Get-Process -Id $PID
$PSPath = $CurrentProcess.Path

#Use Sysnative if in 32-bit shell
if(-Not ([Environment]::Is64BitProcess)){
    Write-Host "Script is in 32-bit PS. Using sysnative."
    $PSPath = $PSPath.Replace("SysWOW64","SysNative")
}

#CSharp code to identify currently logged on user and run a process (the GUI) as that user
#Modified from https://github.com/murrayju/CreateProcessAsUser
$Source = @"
using System;  
using System.Runtime.InteropServices;
using Microsoft.Win32;
using System.Security.Principal;
using System.Diagnostics;

namespace UserContext.ProcessExtensions  
{
    public static class ProcessExtensions
    {
        #region Win32 Constants

        private const int CREATE_UNICODE_ENVIRONMENT = 0x00000400;
        private const int CREATE_NO_WINDOW = 0x08000000;

        private const int CREATE_NEW_CONSOLE = 0x00000010;

        private const uint INVALID_SESSION_ID = 0xFFFFFFFF;
        private static readonly IntPtr WTS_CURRENT_SERVER_HANDLE = IntPtr.Zero;

        #endregion

        #region DllImports

        [DllImport("advapi32.dll", EntryPoint = "CreateProcessAsUser", SetLastError = true, CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        private static extern bool CreateProcessAsUser(
            IntPtr hToken,
            String lpApplicationName,
            String lpCommandLine,
            IntPtr lpProcessAttributes,
            IntPtr lpThreadAttributes,
            bool bInheritHandle,
            uint dwCreationFlags,
            IntPtr lpEnvironment,
            String lpCurrentDirectory,
            ref STARTUPINFO lpStartupInfo,
            out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("advapi32.dll", EntryPoint = "DuplicateTokenEx")]
        private static extern bool DuplicateTokenEx(
            IntPtr ExistingTokenHandle,
            uint dwDesiredAccess,
            IntPtr lpThreadAttributes,
            int TokenType,
            int ImpersonationLevel,
            ref IntPtr DuplicateTokenHandle);

        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool OpenProcessToken(IntPtr processHandle, uint desiredAccess, out IntPtr tokenHandle);

        [DllImport("userenv.dll", SetLastError = true)]
        private static extern bool CreateEnvironmentBlock(ref IntPtr lpEnvironment, IntPtr hToken, bool bInherit);

        [DllImport("userenv.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool DestroyEnvironmentBlock(IntPtr lpEnvironment);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr hSnapshot);

        [DllImport("kernel32.dll")]
        private static extern uint WTSGetActiveConsoleSessionId();

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern UInt32 WaitForSingleObject(
            IntPtr hHandle,
            UInt32 dwMilliseconds);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetExitCodeProcess(IntPtr hProcess, out uint ExitCode);

        [DllImport("Wtsapi32.dll")]
        private static extern uint WTSQueryUserToken(uint SessionId, ref IntPtr phToken);

        [DllImport("wtsapi32.dll", SetLastError = true)]
        private static extern int WTSEnumerateSessions(
            IntPtr hServer,
            int Reserved,
            int Version,
            ref IntPtr ppSessionInfo,
            ref int pCount);

        #endregion

        #region Win32 Structs

        private enum SW
        {
            SW_HIDE = 0,
            SW_SHOWNORMAL = 1,
            SW_NORMAL = 1,
            SW_SHOWMINIMIZED = 2,
            SW_SHOWMAXIMIZED = 3,
            SW_MAXIMIZE = 3,
            SW_SHOWNOACTIVATE = 4,
            SW_SHOW = 5,
            SW_MINIMIZE = 6,
            SW_SHOWMINNOACTIVE = 7,
            SW_SHOWNA = 8,
            SW_RESTORE = 9,
            SW_SHOWDEFAULT = 10,
            SW_MAX = 10
        }

        private enum WTS_CONNECTSTATE_CLASS
        {
            WTSActive,
            WTSConnected,
            WTSConnectQuery,
            WTSShadow,
            WTSDisconnected,
            WTSIdle,
            WTSListen,
            WTSReset,
            WTSDown,
            WTSInit
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public uint dwProcessId;
            public uint dwThreadId;
        }

        private enum SECURITY_IMPERSONATION_LEVEL
        {
            SecurityAnonymous = 0,
            SecurityIdentification = 1,
            SecurityImpersonation = 2,
            SecurityDelegation = 3,
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct STARTUPINFO
        {
            public int cb;
            public String lpReserved;
            public String lpDesktop;
            public String lpTitle;
            public uint dwX;
            public uint dwY;
            public uint dwXSize;
            public uint dwYSize;
            public uint dwXCountChars;
            public uint dwYCountChars;
            public uint dwFillAttribute;
            public uint dwFlags;
            public short wShowWindow;
            public short cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        private enum TOKEN_TYPE
        {
            TokenPrimary = 1,
            TokenImpersonation = 2
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct WTS_SESSION_INFO
        {
            public readonly UInt32 SessionID;

            [MarshalAs(UnmanagedType.LPStr)]
            public readonly String pWinStationName;

            public readonly WTS_CONNECTSTATE_CLASS State;
        }

        #endregion

        // Gets the user token from the currently active session
        private static bool GetSessionUserToken(ref IntPtr phUserToken)
        {
            var bResult = false;
            var hImpersonationToken = IntPtr.Zero;
            var activeSessionId = INVALID_SESSION_ID;
            var pSessionInfo = IntPtr.Zero;
            var sessionCount = 0;

            // Get a handle to the user access token for the current active session.
            if (WTSEnumerateSessions(WTS_CURRENT_SERVER_HANDLE, 0, 1, ref pSessionInfo, ref sessionCount) != 0)
            {
                var arrayElementSize = Marshal.SizeOf(typeof(WTS_SESSION_INFO));
                var current = pSessionInfo;

                for (var i = 0; i < sessionCount; i++)
                {
                    var si = (WTS_SESSION_INFO)Marshal.PtrToStructure((IntPtr)current, typeof(WTS_SESSION_INFO));
                    current += arrayElementSize;

                    if (si.State == WTS_CONNECTSTATE_CLASS.WTSActive)
                    {
                        activeSessionId = si.SessionID;
                    }
                }
            }

            // If enumerating did not work, fall back to the old method
            if (activeSessionId == INVALID_SESSION_ID)
            {
                activeSessionId = WTSGetActiveConsoleSessionId();
            }

            Console.WriteLine("activeSessionId: " + activeSessionId);

            if (WTSQueryUserToken(activeSessionId, ref hImpersonationToken) != 0)
            {
                // Convert the impersonation token to a primary token
                bResult = DuplicateTokenEx(hImpersonationToken, 0, IntPtr.Zero,
                    (int)SECURITY_IMPERSONATION_LEVEL.SecurityImpersonation, (int)TOKEN_TYPE.TokenPrimary,
                    ref phUserToken);

                //CloseHandle(hImpersonationToken);
            }else
            {
                Console.WriteLine("Failed WTSQueryToken");
            }
            CloseHandle(hImpersonationToken);

            Console.WriteLine("GetSessionUserToken bResult = " + bResult);
            return bResult;
        }

        public static uint StartProcessAsCurrentUser(string appPath, string cmdLine = null, string workDir = null, bool visible = false)
        {
            Console.WriteLine("========== StartProcessAsCurrentUser START ==========");

            var hUserToken = IntPtr.Zero;
            var startInfo = new STARTUPINFO();
            var procInfo = new PROCESS_INFORMATION();
            var pEnv = IntPtr.Zero;
            int iResultOfCreateProcessAsUser;

            const UInt32 INFINITE = 0xFFFFFFFF;
            const UInt32 WAIT_FAILED = 0xFFFFFFFF;
            uint uiResultWait = WAIT_FAILED;
            uint ExitCode = $($GUIExitCode);

            startInfo.cb = Marshal.SizeOf(typeof(STARTUPINFO));

            try
            {
                if (!GetSessionUserToken(ref hUserToken))
                {
                    Console.WriteLine("GetSessionUserToken failed. Exiting with ExitCode $($GUIExitCode)");
                    //throw new Exception("StartProcessAsCurrentUser: GetSessionUserToken failed.");
                    return ExitCode;
                }

                uint dwCreationFlags = CREATE_UNICODE_ENVIRONMENT | (uint)(visible ? CREATE_NEW_CONSOLE : CREATE_NO_WINDOW);
                startInfo.wShowWindow = (short)(visible ? SW.SW_SHOW : SW.SW_HIDE);
                startInfo.lpDesktop = "winsta0\\default";

                if (!CreateEnvironmentBlock(ref pEnv, hUserToken, false))
                {
                    Console.WriteLine("CreateEnvironmentBlock failed");
                    throw new Exception("StartProcessAsCurrentUser: CreateEnvironmentBlock failed.");
                }

                using (WindowsIdentity identity = new WindowsIdentity(hUserToken))
                {
                    Console.WriteLine("Attempting to start process as user: " + identity.Name);
                }
                Console.WriteLine("hToken: " + hUserToken);
                Console.WriteLine("lpApplicationName: " + appPath);
                Console.WriteLine("lpCommandLine: " + cmdLine);
                Console.WriteLine("lpProcessAttributes: " + IntPtr.Zero);
                Console.WriteLine("lpThreadAttributes: " + IntPtr.Zero);
                Console.WriteLine("bInheritHandles: false");
                Console.WriteLine("dwCreationFlags: " + dwCreationFlags);
                Console.WriteLine("lpEnvironment: " + pEnv);
                Console.WriteLine("lpCurrentDirectory: " + workDir);
                Console.WriteLine("lpStartupInfo: " + startInfo);

                if (!CreateProcessAsUser(hUserToken,
                    null, // Application Name, this is null because we call the whole thing in the cmdLine parameter
                    cmdLine, // Command Line
                    IntPtr.Zero,
                    IntPtr.Zero,
                    false,
                    dwCreationFlags,
                    pEnv,
                    workDir, // Working directory
                    ref startInfo,
                    out procInfo))
                {
                    Console.WriteLine("CreateProcessAsUser failed");
                    throw new Exception("StartProcessAsCurrentUser: CreateProcessAsUser failed.\n");
                }

                try
                {
                    Console.WriteLine("Just created process - Trying to get info about PID: " + procInfo.dwProcessId);
                    Process proc = Process.GetProcessById((int)procInfo.dwProcessId);
                    Console.WriteLine("Process Name: {0}", proc.ProcessName);
                    Console.WriteLine("Main Window Handle: {0}", proc.MainWindowHandle);
                    Console.WriteLine("Start Time: {0}", proc.StartTime);
                    Console.WriteLine("Has Exited: {0}", proc.HasExited);
                    if(proc.HasExited)
                    {
                        Console.WriteLine("Exit Time: {0}", proc.ExitTime);
                        Console.WriteLine("ExitCode: {0}", proc.ExitCode);
                    }
                }catch (Exception ex){
                    Console.WriteLine("Error retrieving process details via System.Diagnostics.Process: {0}", ex.Message);
                }

                iResultOfCreateProcessAsUser = Marshal.GetLastWin32Error();

                uiResultWait = WaitForSingleObject(procInfo.hProcess, INFINITE);
                if (uiResultWait == WAIT_FAILED)
                    {
                        throw new Exception("WaitForSingleObject error #" + Marshal.GetLastWin32Error());
                    }

                GetExitCodeProcess(procInfo.hProcess, out ExitCode);
            }
            finally
            {
                CloseHandle(hUserToken);
                if (pEnv != IntPtr.Zero)
                {
                    DestroyEnvironmentBlock(pEnv);
                }
                CloseHandle(procInfo.hThread);
                CloseHandle(procInfo.hProcess);
            }

            Console.WriteLine("Exiting with ExitCode = " + ExitCode);
            Console.WriteLine("========== StartProcessAsCurrentUser END ==========");
            return ExitCode;
        }
    }
}


"@

#Check if running as the SYSTEM account
$PSUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')
if($PSUser[1] -eq "SYSTEM"){

    #Check if running in an interactive shell or not
    $NonInteractive = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
    if ([Environment]::UserInteractive -and -not $NonInteractive) {

        #Running as SYSTEM and interactive - load the code and start GUI as user
        Write-Host "StartGUI.ps1 is running in interactive"
        Write-Host "Adding C# code and calling StartProcessAsUser:"
        Write-Host "$($PSPath) -ExecutionPolicy Bypass -File `"$($GUIScriptPath)`""
        
        Add-Type -ReferencedAssemblies 'System', 'System.Runtime.InteropServices' -TypeDefinition $Source -Language CSharp 
        $GUIExitCode = [UserContext.ProcessExtensions.ProcessExtensions]::StartProcessAsCurrentUser($NULL, "$($PSPath) -ExecutionPolicy Bypass -File `"$($GUIScriptPath)`"")
    
    }else{

        #Running as SYSTEM and non-interactive - load the code and start GUI as user
        Write-Host "StartGUI.ps1 is running in non-interactive"
        Write-Host "Adding C# code and calling StartProcessAsUser:"
        Write-Host "$($PSPath) -ExecutionPolicy Bypass -File `"$($GUIScriptPath)`""
        
        Add-Type -ReferencedAssemblies 'System', 'System.Runtime.InteropServices' -TypeDefinition $Source -Language CSharp 
        $GUIExitCode = [UserContext.ProcessExtensions.ProcessExtensions]::StartProcessAsCurrentUser($NULL, "$($PSPath) -ExecutionPolicy Bypass -File `"$($GUIScriptPath)`"")
    
    }
}else{

    #Running as a user - start the GUI
    Write-Host "StartGUIAsUser.ps1 is running as user"
    Write-Host "Starting the GUI:"
    Write-Host "$($PSPath) -ExecutionPolicy Bypass -File `"$($GUIScriptPath)`""

    $GUIProcess = Start-Process -FilePath $PSPath -ArgumentList "-ExecutionPolicy Bypass -File `"$($GUIScriptPath)`"" -Wait -PassThru -NoNewWindow
    $GUIExitCode = $GUIProcess.ExitCode

}

Write-Host "Finishing with Exit Code: $($GUIExitCode)"
Write-Host "========== StartGUI.ps1 END =========="

Exit $GUIExitCode