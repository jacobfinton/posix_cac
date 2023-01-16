# Description: A POSIX way to prepare an environment for using a CAC.

main()
{
    EXIT_SUCCESS=0
    EXIT_FAILURE=1
    TEMP_DIR="/tmp"

    root_check
    install_middleware
    module_check
    certificate_check

    print_style "\n***Complete***\n" "success"
    exit "$EXIT_SUCCESS"
}

# prints colored text
print_style () 
{
    if [ "$2" = "info" ] ; then
        COLOR="96m";
    elif [ "$2" = "success" ] ; then
        COLOR="92m";
    elif [ "$2" = "warning" ] ; then
        COLOR="93m";
    elif [ "$2" = "danger" ] ; then
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1";
}

# Check to ensure the script is executed as root
root_check ()
{
    if [ "$(id -u)" -ne 0 ] ;then
        print_style "\n***Must be run as root***\n" "danger"
        exit "$EXIT_FAILURE"
    fi
}

# Install required pcsc middleware and remembers package manager.
install_middleware ()
{
    if type apt > /dev/null 2>&1; then # Debian
        PACKAGE_MANAGER="apt install"
        $PACKAGE_MANAGER pcscd pcsc-tools libccid libpcsclite1
    elif type pacman > /dev/null 2>&1; then # Arch
        PACKAGE_MANAGER="pacman -S"
        $PACKAGE_MANAGER pcsclite pcsc-tools ccid
    elif type yum > /dev/null 2>&1; then # Red-Hat legacy
        PACKAGE_MANAGER="yum install"
        $PACKAGE_MANAGER pcsc-lite pcsc-tools
    elif type dnf > /dev/null 2>&1; then # Red-Hat Future
        PACKAGE_MANAGER="dnf install"
        $PACKAGE_MANAGER pcsc-lite pcsc-tools
    elif type zypper > /dev/null 2>&1; then # OpenSUSE
        PACKAGE_MANAGER="zypper install"
        $PACKAGE_MANAGER pcsc-lite pcsc-ccid perl-pcsc pcsc-tools
    else
        print_style "***\nNo currently supported package manager available***" "danger"
        exit "$EXIT_FAILURE"
    fi
    # Ensures middleware is running
    systemctl enable pcscd
    systemctl restart pcscd

    print_style "\n***Middleware installed successfully***\n" "success"
}

# PKCS #11 module the user wants to use ex. opensc vs cackey
module_check ()
{
            option=''
            while [ "$option" != "opensc" ] && [ "$option" != "coolkey" ] && [ "$option" != "cackey" ]
            do
                printf "\nWould you like to install "
                print_style "[opensc, coolkey, cackey]?\n" "warning"
                read -r option
            done
            if [ "$option" = "opensc" ]; then
                opensc_install
            elif [ "$option" = "coolkey" ]; then
                 print_style "WIP\n" "danger"
                coolkey_install
            elif [ "$option" = "cackey" ]; then
                print_style "TODO\n" "danger"
                # cackey_install
                exit "$EXIT_FAILURE"
            else
                print_style "\n***Nothing installed***\n" "danger"
                exit "$EXIT_FAILURE"
            fi
}

opensc_install ()
{
    $PACKAGE_MANAGER opensc
    print_style "\n***opensc installed successfully***\n" "success"
}

coolkey_install ()
{
    $PACKAGE_MANAGER coolkey
    print_style "\n***coolkey installed successfully***\n" "success"
}

# TODO
cackey_install ()
{
    CACKEY_URL="http://cackey.rkeene.org/download/"

    wget -qP "$TEMP_DIR" "$CACKEY_URL"

    print_style "\n***cackey installed successfully***\n" "success"
}

# Does the user want us to install DOD certificates
certificate_check ()
{
    option=''
    while [ "$option" != "y" ] && [ "$option" != "n" ]
    do
        printf "\nWould you like the script to install DOD certifcates?"
        print_style "(y/n)\n" "info"
        read -r option
    done
    if [ "$option" = "y" ]; then
        certificate_install
    else
        print_style "\nSkipping certificate installation\n" "warning"
    fi
}

# Installs DOD certificates
certificate_install ()
{
    PKCS_FILE="pkcs11.txt" # TODO Will be replaced with modutil
    CERT_FILE="DoD_Approved_External_PKIs_Trust_Chains_v9.5_20221018/_DoD/Intermediate_and_Issuing_CA_Certs"
    ZIP_FILE="unclass-dod_approved_external_pkis_trust_chains.zip"
    PKI_URL="https://dl.dod.cyber.mil/wp-content/uploads/pki-pke/zip/$ZIP_FILE"

    download_check
    browser_check

    print_style "\n***Broswer certificates installed***\n" "success"
}

# Determines programs on host and downloads/extracts certificates
download_check ()
{
    nettool_check

    unzip_check

    certutil_check
}

nettool_check ()
{
    if type wget > /dev/null; then
        print_style "wget is installed and will be used\n" "info"
        wget -qP "$TEMP_DIR" "$PKI_URL"
    elif type curl > /dev/null; then # TODO
        print_style "curl is installed and will be used\n" "info"
    else
        print_style "You currently do not have a network client like wget or curl\n" "warning"

        option=''
        while [ "$option" != "y" ] && [ "$option" != "n" ]
        do
            print_style "\nWould you like to install wget?(y/n)\n" "info"
            read -r option
        done
        if [ "$option" = "y" ]; then
            $PACKAGE_MANAGER wget
            print_style "wget has been installed\n" "info"
        else
            print_style "\n***Nothing installed***\n" "danger"
            exit "$EXIT_FAILURE"
        fi
    fi
}

unzip_check ()
{
    # unzip check
    if type unzip > /dev/null; then
        print_style "unzip is installed and will be used\n" "info"
    else
        OPTION=''
        while [ "$OPTION" != "y" ] && [ "$OPTION" != "n" ]
        do
            print_style "\nWould you like to install unzip?(y/n)\n" "info"
            read -r OPTION
        done
        if [ "$OPTION" = "y" ]; then
            $PACKAGE_MANAGER unzip
            print_style "unzip has been installed\n" "info"
        else
            print_style "\n***Nothing installed***\n" "danger"
            exit "$EXIT_FAILURE"
        fi
    fi

    # Extracts certs
    unzip "$TEMP_DIR/$ZIP_FILE" -d "$TEMP_DIR"
}

certutil_check ()
{
    if type certutil > /dev/null; then
        print_style "\n***certutil is installed and will be used**\n" "info"
    else
        option=''
        while [ "$option" != "y" ] && [ "$option" != "n" ]
        do
            print_style "\ncerutil is needed to auto install DoD certificates\n" "warning"
            print_style "\nWould you like to install certutil?(y/n)\n" "info"
            read -r option
        done
        if [ "$option" = "y" ]; then
            $PACKAGE_MANAGER libnss3-tools
            $PACKAGE_MANAGER nss-tools
            $PACKAGE_MANAGER mozilla-nss-tools
            print_style "\n***Certutils has been installed***\n" "info"
        else
            print_style "\n***Nothing installed***\n" "danger"
            exit "$EXIT_FAILURE"
        fi
    fi
}

browser_check ()
{
    ff_installed=false
    chrome_installed=false

    print_style "\n***Looking for Browsers***\n" "info"
    check_for_firefox
    check_for_chrome

    if [ "$ff_installed" = true ] || [ "$chrome_installed" = true ]; then
        import_certificates
    else
        print_style "\n***No version of Mozilla Firefox or Chrome installed***\n" "danger"

        exit "$EXIT_FAILURE"
    fi
}

check_for_firefox ()
{
    if type firefox > /dev/null; then
        ff_installed=true
        print_style "\n***Found Firefox***\n" "info"
        print_style "\n***Running firefox to generate databases***\n" "info"
        sudo -u "$SUDO_USER" firefox --headless --first-startup > /dev/null 2>&1 &
        sleep 3
        pkill -9 firefox
        sleep 2
        # Run a second time just in case to produce profiles
        sudo -u "$SUDO_USER" firefox --headless > /dev/null 2>&1 &
        sleep 3
        pkill -9 firefox
        sleep 2
    else
        print_style "\n***Firefox not found***\n" "warning"
    fi
}

check_for_chrome ()
{
    if type google-chrome > /dev/null; then
        chrome_installed=true
        print_style "\n***Found Google Chrome***\n" "info"
    else
        print_style "\n***Chrome not found***\n" "warning"
    fi
}

# TODO Reduce
import_certificates ()
{
    print_style "\n***Starting Import***\n" "info"

    find ~/.mozilla* ~/snap/firefox/common/.mozilla* /home/*/.mozilla* /home/*/snap/firefox/common/.mozilla* ~/.pki /home/*/.pki -name "cert9.db" > tmp
    while IFS= read -r nss_db
    do
        # TODO Check for no databases found
        nss_dir=$(dirname "$nss_db");

        # Load CAC Module
        ## TODO modutil is currently having indeterministic behavior on firefox
        ## modutil -dbdir sql:"$nss_dir" -add "CAC Module" -libfile "/usr/lib/opensc-pkcs11.so"
        print_style "\n***Saving CAC Module into $nss_dir***\n" "info"

        if find /usr/lib/opensc-pkcs11.so > /dev/null 2>&1; then
            if ! grep 'library=/usr/lib/opensc-pkcs11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib/opensc-pkcs11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib64/opensc-pkcs11.so > /dev/null 2>&1; then
            if ! grep 'library=/usr/lib64/opensc-pkcs11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib64/opensc-pkcs11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so > /dev/null 2>&1; then # Ubuntu 18.04
            if ! grep 'library=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so > /dev/null 2>&1; then # Ubuntu 20.04
            if ! grep 'library=/usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib/pkcs11/libcoolkeypk11.so > /dev/null 2>&1; then
            if ! grep 'library=/usr/lib/pkcs11/libcoolkeypk11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib/pkcs11/libcoolkeypk11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib64/libcoolkeypk11.so > /dev/null 2>&1; then
            if ! grep 'library=/usr/lib64/libcoolkeypk11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib64/libcoolkeypk11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib64/pkcs11/libcoolkeypk11.so > /dev/null 2>&1; then
            if ! grep 'library=/usr/lib64/pkcs11/libcoolkeypk11.so\|name=CAC Module' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib64/pkcs11/libcoolkeypk11.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        elif find /usr/lib64/libcackey.so > /dev/null 2>&1; then
            if ! grep 'library=/usr/lib64/libcackey.so\|name=CAC Module\n' "$nss_dir/$PKCS_FILE" >/dev/null; then
                printf "library=/usr/lib64/libcackey.so\nname=CAC Module\n" >> "$nss_dir/$PKCS_FILE"
            fi
        else
            print_style "\n***Error No module found***\n" "danger"
            exit "$EXIT_FAILURE"
        fi

        print_style "\n***Loading certificates into $nss_dir***\n" "info"

        # Import certificate into pki DB
        for cert in "$TEMP_DIR/$CERT_FILE/"*."cer"
        do
            echo "$cert"
            certutil -d sql:"$nss_dir" -A -t TC -n "$cert" -i "$cert"
        done
    done < tmp
    rm tmp
    print_style "\n***All certificates imported and CAC Module Added***\n" "success"

}

main