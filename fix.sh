#!/bin/sh
#
# Sets up the Allegro package for building with the specified compiler,
# and if possible converting text files from CR/LF to LF format.

proc_bcc32()
{
   AL_COMPILER="Windows (BCC32)"
   AL_MAKEFILE="makefile.bcc"
   AL_PLATFORM="ALLEGRO_BCC32"
}

proc_beos()
{
   AL_COMPILER="BeOS"
   AL_MAKEFILE="makefile.be"
   AL_PLATFORM="ALLEGRO_BEOS"
}

proc_djgpp()
{
   AL_COMPILER="DOS (djgpp)"
   AL_MAKEFILE="makefile.dj"
   AL_PLATFORM="ALLEGRO_DJGPP"
}

proc_mingw32()
{
   AL_COMPILER="Windows (Mingw32)"
   AL_MAKEFILE="makefile.mgw"
   AL_PLATFORM="ALLEGRO_MINGW32"
}

proc_msvc()
{
   AL_COMPILER="Windows (MSVC)"
   AL_MAKEFILE="makefile.vc"
   AL_PLATFORM="ALLEGRO_MSVC"
}

proc_qnx()
{
   AL_COMPILER="QNX"
   AL_MAKEFILE="makefile.qnx"
   AL_PLATFORM="ALLEGRO_QNX"
}

proc_rsxnt()
{
   AL_COMPILER="Windows (RSXNT)"
   AL_MAKEFILE="makefile.rsx"
   AL_PLATFORM="ALLEGRO_RSXNT"
}

proc_unix()
{
   AL_COMPILER="Unix"
   AL_MAKEFILE="dummy"
   AL_PLATFORM="ALLEGRO_UNIX"
   AL_NOMAKE="1"
}

proc_mac()
{
   AL_COMPILER="Mac"
   AL_MAKEFILE="dummy"
   AL_PLATFORM="ALLEGRO_MPW"
   AL_NOMAKE="1"
}

proc_watcom()
{
   AL_COMPILER="DOS (Watcom)"
   AL_MAKEFILE="makefile.wat"
   AL_PLATFORM="ALLEGRO_WATCOM"
}

proc_help()
{
   echo ""
   echo "Usage: ./fix.sh <platform> [--quick|--dtou|--utod|--utom|--mtou]"
   echo ""
   echo "Where platform is one of: bcc32, beos, djgpp, mingw32, msvc, qnx, rsxnt, unix"
   echo "mac and watcom."
   echo "The --quick parameter turns of text file conversion, --dtou converts from"
   echo "DOS/Win32 format to Unix, --utod converts from Unix to DOS/Win32 format,"
   echo "--utom converts from Unix to Macintosh format and --mtou converts from"
   echo "Macintosh to Unix format. If no parameter is specified --dtou is assumed."
   echo ""
}

proc_fix()
{
   echo "Configuring Allegro for $AL_COMPILER..."

   if [ "$AL_NOMAKE" != "1" ]; then
      echo "# generated by fix.sh" > makefile
      echo "MAKEFILE_INC = $AL_MAKEFILE" >> makefile
      echo "include makefile.all" >> makefile
   fi

   echo "/* generated by fix.sh */" > include/allegro/alplatf.h
   echo "#define $AL_PLATFORM" >> include/allegro/alplatf.h
}

proc_filelist()
{
   AL_FILELIST_DOS_OK=`find . -type f "(" \
      -name "*.c" -o -name "*.cfg" -o -name "*.cpp" -o -name "*.dep" -o \
      -name "*.h" -o -name "*.hin" -o -name "*.in" -o -name "*.inc" -o \
      -name "*.m4" -o -name "*.mft" -o -name "*.s" -o \
      -name "*.spec" -o -name "*.pl" -o -name "*.txt" -o -name "*._tx" -o \
      -name "makefile.*" -o -name "readme.*" \
      ")"`

   AL_FILELIST="$AL_FILELIST_DOS_OK `find . -type f -name '*.sh'`"
}

proc_utod()
{
   proc_filelist
   for file in $AL_FILELIST_DOS_OK; do
      echo "$file"
      perl -p -i -e "s/([^\r]|^)\n/\1\r\n/" $file
   done
}

proc_dtou()
{
   proc_filelist
   for file in $AL_FILELIST; do
      echo "$file"
      mv $file _tmpfile
      tr -d '\015' < _tmpfile > $file
      touch -r _tmpfile $file
      rm _tmpfile
   done
   chmod +x configure *.sh misc/*.sh misc/*.pl
}

proc_utom()
{
   proc_filelist
   for file in $AL_FILELIST; do
      echo "$file"
      mv $file _tmpfile
      tr '\012' '\015' < _tmpfile > $file
      touch -r _tmpfile $file
      rm _tmpfile
   done
}

proc_mtou()
{
   proc_filelist
   for file in $AL_FILELIST; do
      echo "$file"
      mv $file _tmpfile
      tr '\015' '\012' < _tmpfile > $file
      touch -r _tmpfile $file
      rm _tmpfile
   done
}

# take action!

if [ "$1" = "bcc32" ]; then
   proc_bcc32
   proc_fix
elif [ "$1" = "beos" ]; then
   proc_beos
   proc_fix
elif [ "$1" = "djgpp" ]; then
   proc_djgpp
   proc_fix
elif [ "$1" = "mingw32" ]; then
   proc_mingw32
   proc_fix
elif [ "$1" = "msvc" ]; then
   proc_msvc
   proc_fix
elif [ "$1" = "qnx" ]; then
   proc_qnx
   proc_fix
elif [ "$1" = "rsxnt" ]; then
   proc_rsxnt
   proc_fix
elif [ "$1" = "unix" ]; then
   proc_unix
   proc_fix
elif [ "$1" = "mac" ]; then
   proc_mac
   proc_fix
elif [ "$1" = "watcom" ]; then
   proc_watcom
   proc_fix
elif [ "$1" = "help" ]; then
   proc_help
   AL_NOCONV="1"
else
   proc_help
   AL_NOCONV="1"
fi

# someone ordered a text conversion?

if [ "$2" = "--utod" ]; then
   echo "Converting files from Unix to DOS/Win32..."
   proc_utod
elif [ "$2" = "--dtou" ]; then
   echo "Converting files from DOS/Win32 to Unix..."
   proc_dtou
elif [ "$2" = "--utom" ]; then
   echo "Converting files from Unix to Macintosh..."
   proc_utom
elif [ "$2" = "--mtou" ]; then
   echo "Converting files from Macintosh to Unix..."
   proc_mtou
elif [ "$2" = "--quick" ]; then
   echo "No text file conversion..."
else
   if [ "$AL_NOCONV" != "1" ]; then
      echo "Converting files from DOS/Win32 to Unix..."
      proc_dtou
   fi
fi

echo "Done!"
