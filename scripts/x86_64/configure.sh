#!/bin/sh -e

#
#   BACKBONE INTERNET SERVICES
#   __________________________
#
#   [2020] - [2021] Backbone Internet Services
#   All Rights Reserved.
# 
#   NOTICE:  All information contained herein is, and remains
#   the property of Backbone Internet Services and its suppliers,
#   if any.  The intellectual and technical concepts contained
#   herein are proprietary to Backbone Internet Services
#   and its suppliers and may be covered by EU and Foreign Patents,
#   patents in process, and are protected by trade secret or copyright law.
#   Dissemination of this information or reproduction of this material
#   is strictly forbidden unless prior written permission is obtained
#   from Backbone Internet Services.
#

unset HOSTNAME
readonly ARCHITECTURE='x86_64'
readonly DEFAULT_USER='default'

#=============================  M a i n  ==============================#

print_help() {
cat <<EOF
  
   Architecture $ARCHITECTURE (only)
   [2020] - [2021] Backbone Internet Services
   All Rights Reserved.
 
		-r | --github-repository    (Required) GitHub URI of the Repository to clone into /root
		-t | --github-token         (Optional) GitHub Personal Access Token if required to clone
		-d | --tmp-dir              (Optional) When assigned, the created files will be ONLY created inside the defined directory.
		-c | --cache-dir            (Optional) When assigned, the Cache / Permanent Storage locaction will default to this option.
		-h | --hostname             (Optional) When assigned, the Hostname of the machine will default to this option.
		     --ns-check-url         (Optional) When assigned, the Nameserver Test of the machine will default to this option.
		     --ns-primary           (Optional) When assigned, the (Primary) Nameserver of the machine will default to this option.
		     --ns-secondary         (Optional) When assigned, the (Secondary) Nameserver of the machine will default to this option.
		     --debug                (Optional) Enable/Disable Debug Logging by passing "--debug true/false"
		     --help

EOF
}

while [ $# -gt 0 ]; do
	n=2
	case "$1" in
		-r | --github-repository) GITHUB_REPOSITORY="$2";;
		-t | --github-token) GITHUB_TOKEN="$2";;
		-d | --tmp-dir) TMP="$2";;
		-c | --cache-dir) CACHE="$2";;
		-h | --hostname) HOSTNAME="$2";;
		     --ns-check-url) NS_CHECK_URL="$2";;
		     --ns-primary) NS_PRIMARY="$2";;
		     --ns-secondary) NS_SECONDARY="$2";;
		     --debug) DEBUG="$2";;
		     --help) print_help; exit 0;;
		--) shift; break;;
	esac
	shift $n
done

if [ -z "$GITHUB_REPOSITORY" ]; then
  MISSING_ARGUMENT="--github-repository"
  printf "\n\033[31;2m [!] %s %s \033[0m\n" "Missing required argument!" "$MISSING_ARGUMENT" >&2
  print_help && exit 1
fi

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. "$SCRIPTPATH"/src/polyfill.sh

# Emuns
enum status { ASSIGNED, UNASSIGNED }

# Defaults
: ${CACHE:="/cache"}
: ${TMP:=$(mktemp -d /tmp/configure-script.XXXXXX)}
: ${HOSTNAME:="node"}
: ${STATUS:=$UNASSIGNED}
: ${NS_CHECK_URL:="backbone-internet.com"}
: ${NS_PRIMARY:="8.8.8.8"}
: ${NS_SECONDARY:="8.8.4.4"}
: ${DEBUG:=false}

# WARNING: Configured to run on AlpineOS Extended x86_64
# @website: https://alpinelinux.org/downloads/

task() {
        printf '\n\033[1;36m ╭─ %s \033[0m\033[1;30m%s\033[0m\n' "$1" "$(basename -- $2)" >&2
        (. $2 && \
            printf '\033[1;36m ╰─ Finished \033[0m\n' "$1" >&2) || \
            (printf '\033[1;36m ╰─ ⛔️ \033[31;2mFailed! (Process Exit %s)\033[0m\n' "$?" >&2 && exit 1)
}

warning() {
        echo "$@" | while IFS= read -r line ; do printf '\033[1;36m │ \033[0m \033[33;2m ╰─ %s \033[0m\n' "$line" >&2; done
}

error() {
        echo "$@" | while IFS= read -r line ; do printf '\033[1;36m │ \033[0m \033[31;2m ╰[!]─ %s \033[0m\n' "$line" >&2; done
        exit 1
}

step() {
	printf '\033[1;36m │ \033[0m %s \n' "$@" >&2  # bold cyan
}

makefile() {    
	OWNER="$1"
	PERMS="$2"
        FULLPATH="$3"
        FILEPATH=$(dirname -- $FULLPATH)
        FILENAME=$(basename -- $FULLPATH)
        step "Create directory $FILEPATH"
        step "Create file $FULLPATH"
        mkdir -p $FILEPATH
	cat > "$FULLPATH"
	chown "$OWNER" "$FULLPATH"
	chmod "$PERMS" "$FULLPATH"
}

makedirectory() {    
	OWNER="$1"
	PERMS="$2"
        FULLPATH="$3"
        step "Create directory $FILEPATH"
        mkdir -p $FULLPATH
	chown "$OWNER" "$FULLPATH"
	chmod "$PERMS" "$FULLPATH"
}

rc_add() {
        step "Adding \"$1\" to OpenRC Runlevels for \"$2\""
	mkdir -p "$TMP"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$TMP"/etc/runlevels/"$2"/"$1"
}

if [[ -f "$CACHE"/environment ]]; then
    source "$CACHE"/environment
    STATUS=READY
fi

if [ "$DEBUG" = true ]; then
  printf "\n\033[1;30m············· DEBUG INFORMATION ·············\033[0m\n"
  echo "TMP=${TMP}"
  echo "PWD=${PWD}"
  echo "SCRIPTPATH=${SCRIPTPATH}"
  echo "CACHE=${CACHE}"
  echo "GITHUB_REPOSITORY=${GITHUB_REPOSITORY}"
  echo "GITHUB_TOKEN=${GITHUB_TOKEN}"
  echo "HOSTNAME=${HOSTNAME}"
  echo "STATUS=${STATUS}"
  echo "NS_CHECK_URL=${NS_CHECK_URL}"
  echo "NS_PRIMARY=${NS_PRIMARY}"
  echo "NS_SECONDARY=${NS_SECONDARY}"
  printf "\033[1;30m·············································\033[0m\n"
fi

# Create default user (UID: 1000)
useradd $DEFAULT_USER

task "System Setup" $SCRIPTPATH/src/system-setup.sh
task "Copyright & Warning" $SCRIPTPATH/src/copyright-warning.sh
task "Download Project" $SCRIPTPATH/src/download-project.sh
task "Prepare Shell" $SCRIPTPATH/src/prepare-shell.sh
task "Package Manager" $SCRIPTPATH/src/package-manager.sh
task "Setup OpenVPN" $SCRIPTPATH/src/setup-openvpn.sh
task "Setup Network" $SCRIPTPATH/src/setup-network.sh
task "Setup SSH" $SCRIPTPATH/src/setup-ssh.sh
task "Setup SDDM" $SCRIPTPATH/src/setup-sddm.sh
task "Setup X11" $SCRIPTPATH/src/setup-x11.sh
task "OpenRC Services" $SCRIPTPATH/src/openrc-services.sh

echo -e "\nFinished! Output created in $TMP"
