# **POSIX_CAC**
## Introduction 
This is an alternative to [linux_cac](https://github.com/jdjaxon/linux_cac). The script avoids bashisms to conform to the POSIX standard. It also supports several different package managers.

## Usage
1. Download smartcard.sh
2. If a browser is currently running, you should exit it before continuing.
3. sudo ./smartcard.sh

## Supported Systems
| Distribution | Versions  |    Browsers     |     PKCS11 Modules     |
|    :-:       |    :-:    |       :-:       |       :-:      |
| Debian       | 11        | Firefox, Chrome | opensc |
| Ubuntu       | 18.04 LTS | Firefox, Chrome | opensc |
|              | 20.04 LTS | Firefox, Chrome | opensc |
| Manjaro      | 22.0      | Firefox, Chrome | opensc |
| Fedora       | 37.0      | Firefox, Chrome | opensc |
| openSUSE     | Tumbleweed| Firefox, Chrome | opensc, coolkey |

## TODO
1. Add cackey and coolkey support
2. Update to use modutils instead of printf on pkcs11.txt files
3. Add support for Ubuntu 21.10+ with removal of snap images.(May just wait for the fix)
4. Add support for other network tools ex. curl
5. Add double check all browsers are closed

## References
- https://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html
- https://militarycac.com/linux.htm
- https://github.com/jdjaxon/linux_cac
- https://public.cyber.mil/pki-pke/end-users/getting-started/linux-firefox/
- https://public.cyber.mil/pki-pke/admins/#toggle-id-6-closed
- https://public.cyber.mil/pki-pke/end-users/getting-started/#toggle-id-3
- https://en.opensuse.org/DoD_Common_Access_Card_(CAC)_Reader