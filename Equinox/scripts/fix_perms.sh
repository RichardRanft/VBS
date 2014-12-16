#! /bin/sh

# fix_perms.sh
#
# Boot & Root FS Build setup
#
# Sets permissions and extracts toolchains
#
# Use -e to extract toolchain tar files
# in addition to the standard permissions
# fixing. This should only need to be done
# once per computer. 
#
# Note that the standard invocation
# is performed by the platform build
# scripts.

if [ -z "$DIR" ];then
  DIR=`dirname $0`
fi

TOOLS_TAR=$DIR/toolchain_stargames.tgz
TOOLS_DIR=/
MBTOOLS_TAR=$DIR/microblaze-elf-tools-20040603.tar.gz
MBTOOLS_DIR=/mbtools

function check_tars()
{
  if [[ ! -e "$TOOLS_TAR" || ! -e "$MBTOOLS_TAR" ]]; then
    echo "Couldn't find necessary tar files:" >&2
    echo "$TOOLS_TAR" >&2
    echo "$MBTOOLS_TAR" >&2
    exit 1
  fi
}

function check_root()
{
  if [ `id -ur` -ne 0 ];then
    echo "Warning: Not root, tars will probably fail to extract" >&2
  fi
}

function critical()
{
  echo "$1"
  shift
  echo "  $@"
  "$@"
  if [ $? -ne 0 ];then
    echo "Command '$@' failed, aborting." >&2
    exit 2
  fi
}

case "$1" in
  --extract|-e)
    extract=1;;
esac


if [ "$extract" == "1" ];then
  check_root
  check_tars
  critical "Extracting tools to $TOOLS_DIR..." tar xfz "$TOOLS_TAR" -C "$TOOLS_DIR"
  critical "Creating $MBTOOLS_DIR directory..." mkdir -p "$MBTOOLS_DIR"
  critical "Extracting mbtools to $MBTOOLS_DIR..." tar xfz "$MBTOOLS_TAR" -C "$MBTOOLS_DIR"
fi
critical "Setting execute permissions for bootloaders..." chmod +x "$DIR"/build/bootfs/*/make_bootloader.sh
critical "Setting execute permissions for patch script..." chmod +x "$DIR"/build/rootfs/sources/patch-kernel00.sh
critical "Setting execute permissions for utils/bin..." chmod -R +x "$DIR"/build/utils/bin/
critical "Setting execute permissions for utils/sbin..." chmod -R +x "$DIR"/build/utils/sbin/

