
param(
    [string] $OutputName,
    [string] $MicrophoneName,
    [switch] $GetCurrentDefaults
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Initialize-AudioInterop {
    [CmdletBinding()]
    param()

    if ('TDAudioSwitch.AudioDeviceEnumerator' -as [type]) {
        return
    }

    $source = @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace TDAudioSwitch
{
    public enum DeviceFlow
    {
        Render = 0,
        Capture = 1
    }

    internal enum ERole
    {
        eConsole = 0,
        eMultimedia = 1,
        eCommunications = 2
    }

    public sealed class AudioDeviceInfo
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Flow { get; set; }
    }

    internal enum EDataFlow
    {
        eRender = 0,
        eCapture = 1,
        eAll = 2
    }

    [Flags]
    internal enum DeviceState : uint
    {
        Active = 0x00000001
    }

    [StructLayout(LayoutKind.Sequential)]
    internal struct PROPERTYKEY
    {
        public Guid fmtid;
        public uint pid;

        public PROPERTYKEY(Guid formatId, uint propertyId)
        {
            fmtid = formatId;
            pid = propertyId;
        }
    }

    [StructLayout(LayoutKind.Explicit)]
    internal struct PROPVARIANT
    {
        [FieldOffset(0)]
        public ushort vt;

        [FieldOffset(8)]
        public IntPtr pointerValue;
    }

    [ComImport]
    [Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
    internal class MMDeviceEnumeratorComObject
    {
    }

    [ComImport]
    [Guid("870AF99C-171D-4F9E-AF0D-E63DF40C2BC9")]
    internal class PolicyConfigClientComObject
    {
    }

    [ComImport]
    [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IMMDeviceEnumerator
    {
        int EnumAudioEndpoints(EDataFlow dataFlow, DeviceState stateMask, out IMMDeviceCollection devices);
        int GetDefaultAudioEndpoint(EDataFlow dataFlow, ERole role, out IMMDevice device);
    }

    [ComImport]
    [Guid("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IMMDeviceCollection
    {
        int GetCount(out uint count);
        int Item(uint deviceNumber, out IMMDevice device);
    }

    [ComImport]
    [Guid("D666063F-1587-4E43-81F1-B948E807363F")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IMMDevice
    {
        int Activate(ref Guid iid, uint clsCtx, IntPtr activationParams, out IntPtr interfacePointer);
        int OpenPropertyStore(uint storageAccessMode, out IPropertyStore properties);
        int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);
        int GetState(out DeviceState state);
    }

    [ComImport]
    [Guid("F8679F50-850A-41CF-9C72-430F290290C8")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IPolicyConfig
    {
        int GetMixFormat();
        int GetDeviceFormat();
        int ResetDeviceFormat();
        int SetDeviceFormat();
        int GetProcessingPeriod();
        int SetProcessingPeriod();
        int GetShareMode();
        int SetShareMode();
        int GetPropertyValue();
        int SetPropertyValue();
        int SetDefaultEndpoint([MarshalAs(UnmanagedType.LPWStr)] string deviceId, ERole role);
        int SetEndpointVisibility();
    }

    [ComImport]
    [Guid("886d8eeb-8cf2-4446-8d02-cdba1dbdcf99")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    internal interface IPropertyStore
    {
        int GetCount(out uint propertyCount);
        int GetAt(uint propertyIndex, out PROPERTYKEY key);
        int GetValue(ref PROPERTYKEY key, out PROPVARIANT value);
        int SetValue(ref PROPERTYKEY key, ref PROPVARIANT value);
        int Commit();
    }

    internal static class NativeMethods
    {
        [DllImport("ole32.dll")]
        internal static extern int PropVariantClear(ref PROPVARIANT propVariant);
    }

    public static class AudioDeviceEnumerator
    {
        private static readonly PROPERTYKEY FriendlyNameKey =
            new PROPERTYKEY(new Guid("A45C254E-DF1C-4EFD-8020-67D146A850E0"), 14);

        public static AudioDeviceInfo[] GetDevices(DeviceFlow flow)
        {
            IMMDeviceEnumerator enumerator = (IMMDeviceEnumerator)new MMDeviceEnumeratorComObject();
            IMMDeviceCollection collection;

            Marshal.ThrowExceptionForHR(
                enumerator.EnumAudioEndpoints(ToDataFlow(flow), DeviceState.Active, out collection));

            uint count;
            Marshal.ThrowExceptionForHR(collection.GetCount(out count));

            var devices = new List<AudioDeviceInfo>();

            for (uint index = 0; index < count; index++)
            {
                IMMDevice device;
                Marshal.ThrowExceptionForHR(collection.Item(index, out device));

                string id;
                Marshal.ThrowExceptionForHR(device.GetId(out id));

                IPropertyStore properties;
                Marshal.ThrowExceptionForHR(device.OpenPropertyStore(0, out properties));

                PROPERTYKEY friendlyNameKey = FriendlyNameKey;
                PROPVARIANT value;
                Marshal.ThrowExceptionForHR(properties.GetValue(ref friendlyNameKey, out value));

                try
                {
                    string friendlyName = Marshal.PtrToStringUni(value.pointerValue) ?? id;

                    devices.Add(new AudioDeviceInfo
                    {
                        Id = id,
                        Name = friendlyName,
                        Flow = flow.ToString()
                    });
                }
                finally
                {
                    NativeMethods.PropVariantClear(ref value);
                }
            }

            return devices.ToArray();
        }

        public static void SetDefaultDevice(string deviceId)
        {
            IPolicyConfig policyConfig = (IPolicyConfig)new PolicyConfigClientComObject();

            Marshal.ThrowExceptionForHR(policyConfig.SetDefaultEndpoint(deviceId, ERole.eConsole));
            Marshal.ThrowExceptionForHR(policyConfig.SetDefaultEndpoint(deviceId, ERole.eMultimedia));
            Marshal.ThrowExceptionForHR(policyConfig.SetDefaultEndpoint(deviceId, ERole.eCommunications));
        }

        public static AudioDeviceInfo GetDefaultDevice(DeviceFlow flow)
        {
            IMMDeviceEnumerator enumerator = (IMMDeviceEnumerator)new MMDeviceEnumeratorComObject();
            IMMDevice device;

            Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(ToDataFlow(flow), ERole.eConsole, out device));

            string id;
            Marshal.ThrowExceptionForHR(device.GetId(out id));

            IPropertyStore properties;
            Marshal.ThrowExceptionForHR(device.OpenPropertyStore(0, out properties));

            PROPERTYKEY friendlyNameKey = FriendlyNameKey;
            PROPVARIANT value;
            Marshal.ThrowExceptionForHR(properties.GetValue(ref friendlyNameKey, out value));

            try
            {
                string friendlyName = Marshal.PtrToStringUni(value.pointerValue) ?? id;

                return new AudioDeviceInfo
                {
                    Id = id,
                    Name = friendlyName,
                    Flow = flow.ToString()
                };
            }
            finally
            {
                NativeMethods.PropVariantClear(ref value);
            }
        }

        private static EDataFlow ToDataFlow(DeviceFlow flow)
        {
            return flow == DeviceFlow.Render ? EDataFlow.eRender : EDataFlow.eCapture;
        }
    }
}
'@

    Add-Type -TypeDefinition $source -Language CSharp
}

function Set-ConsoleUi {
    [CmdletBinding()]
    param()

    $Host.UI.RawUI.WindowTitle = 'TDAudioSwitch'
}

function Write-Header {
    [CmdletBinding()]
    param()

    Write-Host ''
    Write-Host 'TDAudioSwitch' -ForegroundColor Cyan
    Write-Host 'Einfaches Windows-CLI zum Umschalten von Standard-Audiogeraeten.'
    Write-Host ('=' * 64) -ForegroundColor DarkGray
    Write-Host ''
}

function Write-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    Write-Host "[INFO] $Message" -ForegroundColor DarkGray
}

function Write-WarningMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Test-InteractiveConsole {
    [CmdletBinding()]
    param()

    return -not [System.Console]::IsInputRedirected
}

function Get-FriendlyErrorMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Exception] $Exception
    )

    if ($Exception -is [System.Management.Automation.MethodInvocationException] -and $Exception.InnerException) {
        return Get-FriendlyErrorMessage -Exception $Exception.InnerException
    }

    if ($Exception -is [System.Runtime.InteropServices.COMException]) {
        switch ($Exception.HResult) {
            -2147024891 { return 'Zugriff verweigert. Bitte PowerShell einmal als Administrator pruefen.' }
            -2147467259 { return 'Windows hat das Standardgeraet nicht gesetzt. Bitte pruefe, ob das Geraet noch verbunden ist.' }
        }

        return "COM-Fehler beim Audiozugriff (HRESULT: $('{0:X8}' -f ($Exception.HResult -band 0xffffffff)))."
    }

    if ($Exception -is [System.InvalidOperationException] -and $Exception.Message -like '*ReadKey*') {
        return 'Das Tool braucht eine echte Konsole. Bitte direkt per PowerShell-Fenster oder Batch-Datei starten.'
    }

    return $Exception.Message
}

function Get-AudioDevices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Render', 'Capture')]
        [string] $Flow
    )

    Initialize-AudioInterop
    [TDAudioSwitch.AudioDeviceEnumerator]::GetDevices([TDAudioSwitch.DeviceFlow]::$Flow)
}

function Find-AudioDeviceByName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Devices,

        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Label
    )

    $exactMatches = @($Devices | Where-Object { $_.Name -eq $Name })
    if ($exactMatches.Count -eq 1) {
        return $exactMatches[0]
    }

    $partialMatches = @($Devices | Where-Object { $_.Name -like "*$Name*" })
    if ($partialMatches.Count -eq 1) {
        return $partialMatches[0]
    }

    if ($exactMatches.Count -gt 1 -or $partialMatches.Count -gt 1) {
        throw "Mehrere $Label passen zu '$Name'. Bitte den Namen genauer angeben."
    }

    throw "$Label '$Name' wurde nicht gefunden."
}

function Write-DeviceSection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Title,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Devices
    )

    Write-Host ('[{0}]' -f $Title) -ForegroundColor Yellow

    if ($Devices.Count -eq 0) {
        Write-Host '  Keine aktiven Geraete gefunden.' -ForegroundColor DarkYellow
        Write-Host ''
        return
    }

    for ($index = 0; $index -lt $Devices.Count; $index++) {
        $device = $Devices[$index]
        Write-Host ('  [{0}] {1}' -f ($index + 1), $device.Name)
        Write-Host ('       ID: {0}' -f $device.Id) -ForegroundColor DarkGray
    }

    Write-Host ''
}

function Write-UsageHints {
    [CmdletBinding()]
    param()

    Write-Host '[Bedienung]' -ForegroundColor Green
    Write-Host '  1. Wiedergabegeraet per Ziffer waehlen.'
    Write-Host '  2. Mikrofon per Ziffer waehlen.'
    Write-Host '  Leertaste: Sofort beenden, ohne etwas zu aendern.'
    Write-Host ''
    Write-Host 'Es wird jeweils genau eine Taste gelesen, ohne Enter.' -ForegroundColor DarkGray
    Write-Host ''
}

function Read-SelectionKey {
    [CmdletBinding()]
    param()

    if (-not (Test-InteractiveConsole)) {
        throw [System.InvalidOperationException]::new('ReadKey ist ohne echte Konsole nicht verfuegbar.')
    }

    $keyInfo = [System.Console]::ReadKey($true)
    Write-Host ('> {0}' -f $keyInfo.KeyChar) -ForegroundColor Cyan
    return $keyInfo
}

function Read-DeviceSelection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Prompt,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $Devices
    )

    if ($Devices.Count -eq 0) {
        Write-Status "$Prompt uebersprungen, da keine Geraete verfuegbar sind."
        return $null
    }

    while ($true) {
        Write-Host $Prompt -ForegroundColor Green -NoNewline
        Write-Host ' '

        $keyInfo = Read-SelectionKey

        if ($keyInfo.Key -eq [System.ConsoleKey]::Spacebar) {
            Write-Status 'Abbruch per Leertaste erkannt.'
            return $null
        }

        if ([char]::IsDigit($keyInfo.KeyChar)) {
            $selectedIndex = [int]::Parse([string]$keyInfo.KeyChar) - 1

            if ($selectedIndex -ge 0 -and $selectedIndex -lt $Devices.Count) {
                $selectedDevice = $Devices[$selectedIndex]
                Write-Status ("Ausgewaehlt: {0}" -f $selectedDevice.Name)
                Write-Host ''
                return $selectedDevice
            }
        }

        Write-Host 'Ungueltige Eingabe. Bitte eine angezeigte Ziffer oder Leertaste druecken.' -ForegroundColor Yellow
        Write-Host ''
    }
}

function Set-DefaultAudioDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object] $Device
    )

    Initialize-AudioInterop
    [TDAudioSwitch.AudioDeviceEnumerator]::SetDefaultDevice($Device.Id)
}

function Get-CurrentAudioDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Render', 'Capture')]
        [string] $Flow
    )

    Initialize-AudioInterop
    return [TDAudioSwitch.AudioDeviceEnumerator]::GetDefaultDevice([TDAudioSwitch.DeviceFlow]::$Flow)
}

function Start-TDAudioSwitch {
    [CmdletBinding()]
    param()

    Set-ConsoleUi
    Write-Header

    $renderDevices = Get-AudioDevices -Flow Render
    $captureDevices = Get-AudioDevices -Flow Capture

    Write-Status 'Aktive Audio-Geraete wurden eingelesen.'
    Write-Host ''

    if ($renderDevices.Count -eq 0 -and $captureDevices.Count -eq 0) {
        Write-WarningMessage 'Es wurden keine aktiven Audio-Geraete gefunden.'
        return
    }

    if ($renderDevices.Count -eq 0) {
        Write-WarningMessage 'Es wurden keine aktiven Wiedergabegeraete gefunden.'
        return
    }

    if ($captureDevices.Count -eq 0) {
        Write-WarningMessage 'Es wurden keine aktiven Mikrofone gefunden.'
        return
    }

    if ($GetCurrentDefaults) {
        $currentOutput = Get-CurrentAudioDevice -Flow Render
        $currentMicrophone = Get-CurrentAudioDevice -Flow Capture

        Write-Output ("OUTPUT={0}" -f $currentOutput.Name)
        Write-Output ("MICROPHONE={0}" -f $currentMicrophone.Name)
        return
    }

    if (-not [string]::IsNullOrWhiteSpace($OutputName) -or -not [string]::IsNullOrWhiteSpace($MicrophoneName)) {
        if ([string]::IsNullOrWhiteSpace($OutputName) -or [string]::IsNullOrWhiteSpace($MicrophoneName)) {
            throw 'Fuer den Preset-Modus muessen OutputName und MicrophoneName gemeinsam gesetzt sein.'
        }

        $selectedRenderDevice = Find-AudioDeviceByName -Devices $renderDevices -Name $OutputName -Label 'Wiedergabegeraet'
        $selectedCaptureDevice = Find-AudioDeviceByName -Devices $captureDevices -Name $MicrophoneName -Label 'Mikrofon'

        Write-Status ("Preset-Ausgabe gefunden: {0}" -f $selectedRenderDevice.Name)
        Write-Status ("Preset-Mikrofon gefunden: {0}" -f $selectedCaptureDevice.Name)

        Set-DefaultAudioDevice -Device $selectedRenderDevice
        Set-DefaultAudioDevice -Device $selectedCaptureDevice

        Write-Host ''
        Write-Host '[Erfolg]' -ForegroundColor Green
        Write-Host ("  Standard-Ausgabe gesetzt: {0}" -f $selectedRenderDevice.Name)
        Write-Host ("  Standard-Mikrofon gesetzt: {0}" -f $selectedCaptureDevice.Name)
        Write-Host ''
        return
    }

    Write-UsageHints

    Write-DeviceSection -Title 'Wiedergabegeraete' -Devices $renderDevices
    $selectedRenderDevice = Read-DeviceSelection -Prompt 'Wiedergabegeraet waehlen:' -Devices $renderDevices

    if ($null -eq $selectedRenderDevice) {
        Write-Status 'Keine Aenderung vorgenommen.'
        return
    }

    Write-DeviceSection -Title 'Mikrofone' -Devices $captureDevices
    $selectedCaptureDevice = Read-DeviceSelection -Prompt 'Mikrofon waehlen:' -Devices $captureDevices

    if ($null -eq $selectedCaptureDevice) {
        Write-Status 'Keine Aenderung vorgenommen.'
        return
    }

    Set-DefaultAudioDevice -Device $selectedRenderDevice
    Set-DefaultAudioDevice -Device $selectedCaptureDevice

    Write-Host ''
    Write-Host '[Erfolg]' -ForegroundColor Green
    Write-Host ("  Standard-Ausgabe gesetzt: {0}" -f $selectedRenderDevice.Name)
    Write-Host ("  Standard-Mikrofon gesetzt: {0}" -f $selectedCaptureDevice.Name)
    Write-Host ''
}

try {
    Start-TDAudioSwitch
}
catch {
    Write-Host ''
    Write-Host "Fehler: $(Get-FriendlyErrorMessage -Exception $_.Exception)" -ForegroundColor Red
    exit 1
}
