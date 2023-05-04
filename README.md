# **POSIX_CAC**
## Introduction 
This is an alternative to [linux_cac](https://github.com/jdjaxon/linux_cac). The script avoids bashisms to conform to the POSIX standard. It also supports several different package managers. Though this script gives the option for several different PKCS11 modules. [opensc](https://github.com/OpenSC/OpenSC) is the recommended module as it is supported on more systems and actively maintained.

**Warning** Currently snap packaged browsers do not support adding PKCS11 modules (Ex. Firefox on Ubuntu 21.10+). If the script sees you are currently using a snap browser it will not continue. This can be fixed by removing that package and installing a non snap version of your browser.

## Usage
1. Download smartcard.sh
2. sudo ./smartcard.sh

## Supported Systems
| Distribution | Versions  |    Browsers     |     PKCS11 Modules     |
|    :-:       |    :-:    |       :-:       |       :-:      |
| Debian       | 11        | Firefox, Chrome | opensc |
| Ubuntu       | 18.04 LTS | Firefox, Chrome | opensc, cackey |
|              | 20.04 LTS | Firefox, Chrome | opensc, cackey |
|              | 22.04 LTS | Firefox(Non Snap), Chrome | opensc |
|              | 23.04 LTS | Firefox(Non Snap), Chrome | opensc |
| Manjaro      | 22.0      | Firefox, Chrome | opensc |
| Fedora       | 37.0      | Firefox, Chrome | opensc |
| openSUSE     | Tumbleweed| Firefox, Chrome | opensc, coolkey, cackey |

## Contribute
Code contributions are welcome! Please commit any pull requests against the main branch.

## References
- https://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html
- https://militarycac.com/linux.htm
- https://github.com/jdjaxon/linux_cac
- https://public.cyber.mil/pki-pke/end-users/getting-started/linux-firefox/
- https://public.cyber.mil/pki-pke/admins/#toggle-id-6-closed
- https://public.cyber.mil/pki-pke/end-users/getting-started/#toggle-id-3
- https://en.opensuse.org/DoD_Common_Access_Card_(CAC)_Reader