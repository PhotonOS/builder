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

makefile $(whoami):$(id -g -n) 0744 "$TMP/root/.xinitrc" <<EOF
#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
   xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
   xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
   xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
   xmodmap "$usermodmap"
fi

# First try ~/.xinitrc
if [ -f "$HOME/.xinitrc" ]; then
  XINITRC="$HOME/.xinitrc"
  if [ -x $XINITRC ]; then
    exec $XINITRC "$@"
  else
    exec /bin/sh "$HOME/.xinitrc" "$@"
  fi
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

exec startlxqt
EOF
