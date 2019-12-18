#!/bin/sh

TRUE=0
FALSE=1
MISSING_PARAM_ERROR=2
YOUTUBEDL_PATH="/usr/local/bin/youtube-dl"
YOUTUBEDL_URL="https://yt-dl.org/downloads/latest/youtube-dl"


check_commands() {
    if [ ! -f /bin/sh ]; then
        echo "'sh' not found."
        exit $FALSE
    fi

    if [ ! -f /bin/grep ]; then
        echo "'grep' not found."
        exit $FALSE
    fi

    if [ ! -f /usr/bin/wget ]; then
        echo "'wget' not found."
        exit $FALSE
    fi

    if [ ! -f /bin/rm ]; then
        echo "'rm' not found."
        exit $FALSE
    fi

    if [ ! -f /bin/chmod ]; then
        echo "'chmod' not found."
        exit $FALSE
    fi
}


remove() {
    /bin/rm -f $YOUTUBEDL_PATH &>/dev/null
}


exists() {
    if [ $# -eq 0 ]; then
        return $MISSING_PARAM_ERROR
    fi

    if [ -f $1 ]; then
        return $TRUE
    fi
        return $FALSE
}


perform_update() {
    printf "Updating youtube-dl... "

    WGET_OUTPUT=$(/usr/bin/wget $YOUTUBEDL_URL -O $YOUTUBEDL_PATH 2>&1)
    WGET_RETURN=$?

    if [ ! $WGET_RETURN -eq 0 ]; then
        echo "$WGET_OUTPUT" | /bin/grep -qi "permission denied"

        if [ $? -eq 0 ]; then
            printf "FAILED!\nMaybe you are not running as a superuser.\n"
        else
            printf "FAILED!\n\n"
            printf "URL -> $YOUTUBEDL_URL\nERROR -> "
            echo -e "$WGET_OUTPUT" | grep -i "failed\|error"
        fi

        exit $FALSE
    else
        printf "DONE.\n"
    fi
}


check_installation() {
    printf "Checking installation... "

    exists $YOUTUBEDL_PATH
    RETURN=$?

    if [ $RETURN -eq $MISSING_PARAM_ERROR ]; then
        printf "FAILED!\nexists(): Missing param error.\n"
    elif [ $RETURN -eq $TRUE ]; then
        printf "DONE.\n"
    else
        printf "FAILED!\nFile not found: $YOUTUBEDL_PATH.\n"
    fi
}


set_permissions() {
    printf "Setting permission... "

    CHMOD_OUTPUT=$(/bin/chmod a+rx $YOUTUBEDL_PATH 2>&1)

    if [ ! $? -eq 0 ]; then
        echo $CHMOD_OUTPUT | grep -qi "operation not permitted"

        if [ $? -eq 0 ]; then
            printf "FAILED!\nMaybe you are not running as a superuser.\n"
        else
            printf "FAILED!\nERROR -> $CHMOD_OUTPUT"
        fi

        exit $FALSE
    else
        printf "DONE.\n"
    fi
}


show_version() {
    YOUTUBEDL_VERSION=$($YOUTUBEDL_PATH --version)
    echo "\nyoutube-dl version: $YOUTUBEDL_VERSION"
}


main() {
    check_commands
    perform_update
    check_installation
    set_permissions
    show_version
}


main
