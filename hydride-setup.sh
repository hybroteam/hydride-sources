echo "---------------------------------"
echo "Welcome to HydrIDE Sources Setup"
echo "---------------------------------"
echo "v1.1 Released on 1st April 2021"
#begin checking
echo "---------------------------------"
echo "gathering system infomation ...."
echo "---------------------------------"

#iSH support
fulluname="`uname -a`" #get full uname
ishv="iSH" #validation variable
echo $fulluname

# Detect the platform (similar to $OSTYPE)
OS="`uname`"
case $OS in
  'Linux')
    OS='Linux'
    alias ls='ls --color=auto'
    ;;
  'FreeBSD')
    OS='FreeBSD'
    alias ls='ls -G'
    ;;
  'WindowsNT')
    OS='Windows'
    ;;
  'Darwin') 
    OS='Mac'
    ;;
  'SunOS')
    OS='Solaris'
    ;;
  'AIX') ;;
  *) ;;
esac
echo "Operating System : " $OS

#check whether python is installed
Pyinstalled=0
Py3only=0
pycmd="python"

if [[ $OS == 'Windows' ]]; then
	#check python for windows
	type -P python >/dev/null 2>&1 && Pyinstalled=1
else
	#check python for other os
	command -v python >/dev/null 2>&1 && Pyinstalled=1
fi;

#if python not found, try python3
if [[ $Pyinstalled == 0 ]]; then
	[[ "$(python3 -V)" =~ "Python 3" ]] && Py3only=1; pycmd="python3"
	if [[ Py3only == 0 ]]; then
		#now we know python is not installed
		echo "Python not installed ! Trying to install ..."
		if [[ $OS == 'Linux' ]]; then
		 # install py
		 if [ -f /etc/redhat-release ] ; then
		 yum install python3
	     elif [ -f /etc/SuSE-release ] ; then
		 zypper install python3
	     elif [ -f /etc/debian_version ] ; then	
		 sudo apt install python3
	     elif [ -f /etc/arch-release ] ; then
		 pacman -S python3
	     else
		 echo "Python is not installed ! Please install Python !"
		 exit N
         fi;

		elif [[ $OS == 'Mac' ]]; then
		  [[ "$(brew)" =~ "command not found" ]] && nobrew=1
		  if [[ nobrew == 1 ]]; then
		  	#install brew
		  	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		  fi;
		  brew install python3
		else
			#install python from command line not supported on such OS
         echo "Python is not installed ! Please install Python at https://www.python.org/downloads/ !"
         exit N
		fi;
	fi;
fi;

if [[ $Py3only == 1 ]]; then
	pyv="$(python3 -c 'import platform; print(platform.python_version())')"
	echo "Warning : python3 was found instead of python !"
else
	pyv="$(python -c 'import platform; print(platform.python_version())')"
fi;

echo "Python Version : $pyv" 

ncpu="$($pycmd -c 'import multiprocessing as mp; print(mp.cpu_count())')"
echo "Number of Workers (Threads) : ${ncpu}"

if [[ $OS == 'Windows' ]]; then
	memsize="$(wmic ComputerSystem get TotalPhysicalMemory)"
	ramsize="$memsize"
elif [[ -f /etc/debian_version ]]; then
    memsize="$(free -m | awk '/Mem/ {print$2}')"
    ramsize="$memsize"
#ish support (through it shows 0MB)
elif [[ "$fulluname" =~ .*"$ishv".* ]]; then
    memsize="$(free -m | awk '/Mem/ {print$2}')"
    ramsize="$memsize"
else
    memsize="$(sysctl hw.memsize)"
    memsize="${memsize/hw.memsize: / }"
    ramsize=$(expr $memsize / 1024 / 1024)
fi
echo "Total Memory (MB) : ${ramsize}"

#iSH Support
if [[ "$fulluname" =~ .*"$ishv".* ]]; then
  echo "Terminal is iSH (iOS), JAVA OPTIONS set to 1024 MB"
  export _JAVA_OPTIONS="-Xmx1024M"
fi

#check java
printf "Java Path : "
if type -p java; then
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then  
    _java="$JAVA_HOME/bin/java"
else
    echo "Java is not installed !"
    echo "Trying to install ..."
		if [[ $OS == 'Linux' ]]; then
		 # install java
		 if [ -f /etc/redhat-release ] ; then
		 yum install openjdk-8-jdk
	     elif [ -f /etc/SuSE-release ] ; then
		 zypper install openjdk-8-jdk
	     elif [ -f /etc/debian_version ] ; then	
		 sudo apt install openjdk-8-jdk
	     elif [ -f /etc/arch-release ] ; then
		 pacman -S openjdk-8-jdk
	     else
		 echo "Java 8 JDK is not installed ! Please install Java 8 !"
		 exit N
        fi;
	   elif [[ $OS == 'Mac' ]]; then
		  [[ "$(brew)" =~ "command not found" ]] && nobrew=1
		  if [[ nobrew == 1 ]]; then
		  	#install brew
		  	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		  fi;
		  brew install openjdk-8-jdk
	   else
			#install java from command line not supported on such OS
         echo "Java 8 JDK is not installed ! Please install Java 8 !"
         exit N
		fi;
    fi

if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    if [[ "$version" > "1.8" &&  "$version" < "1.8.9" ]]; then
        echo "Java Version : ${version}"
    else         
		echo "Java is not the right version or not installed ! Trying to install ..."
		if [[ $OS == 'Linux' ]]; then
		 # install java
		 if [ -f /etc/redhat-release ] ; then
		 yum install openjdk-8-jdk
	     elif [ -f /etc/SuSE-release ] ; then
		 zypper install openjdk-8-jdk
	     elif [ -f /etc/debian_version ] ; then	
		 sudo apt install openjdk-8-jdk
	     elif [ -f /etc/arch-release ] ; then
		 pacman -S openjdk-8-jdk
	     else
		 echo "Java 8 JDK is not installed ! Please install Java 8 !"
		 exit N
        fi;
	   elif [[ $OS == 'Mac' ]]; then
		  [[ "$(brew)" =~ "command not found" ]] && nobrew=1
		  if [[ nobrew == 1 ]]; then
		  	#install brew
		  	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		  fi;
		  brew install openjdk-8-jdk
	   else
			#install java from command line not supported on such OS
         echo "Java 8 JDK is not installed ! Please install Java 8 !"
         exit N
		fi;
    fi
fi

#check ant
printf "Ant Path : "
if type -p ant; then
    _ant=ant
else
    echo "Ant not installed ! Trying to install ..."
		if [[ $OS == 'Linux' ]]; then
		 # install java
		 if [ -f /etc/redhat-release ] ; then
		 yum install ant
	     elif [ -f /etc/SuSE-release ] ; then
		 zypper install ant
	     elif [ -f /etc/debian_version ] ; then	
		 sudo apt install ant
	     elif [ -f /etc/arch-release ] ; then
		 pacman -S ant
	     else
		 echo "Apache Ant is not installed ! Please install Ant !"
		 exit N
        fi;
	   elif [[ $OS == 'Mac' ]]; then
		  [[ "$(brew)" =~ "command not found" ]] && nobrew=1
		  if [[ nobrew == 1 ]]; then
		  	#install brew
		  	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		  fi;
		  brew install ant
	   else
			#install java from command line not supported on such OS
         echo "Apache Ant is not installed ! Please install Ant !"
         exit N
		fi;
    fi;
if [[ "$_ant" ]]; then
    version=$("$_ant" -version 2>&1 | awk '/version/ {print$4}')
        echo "Ant Version : ${version}"         
fi;
echo "---------------------------------"
#end of checking
while true; do
    read -p "Do you want to continue (yes/no) ?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#begin
echo "---------------------------------"
echo "Checking your directory ..."
echo "---------------------------------"
DIR="$PWD/appinventor"
CURRENT_DIR=0
#check if current path is a source code
if [ -d "$DIR" ]; then
  #folder exists
echo "Your current directory is ${PWD}"
while true; do
    read -p "Do you want to setup on the current directory(yes/no) ? " cudir
    case $cudir in
        [Yy]* ) CURRENT_DIR=1 break;;
        [Nn]* ) CURRENT_DIR=0 break;;
        * ) echo "Please answer yes or no.";;
    esac
done
fi

if [[ $CURRENT_DIR == 0 ]]; then
	# enter setup path
  while true; do 
  read -p "Enter directory to setup (enter 'none' to clone from git) : " DIR
  if [[ $DIR = "none" ]]; then
  	git clone https://github.com/mit-cml/appinventor-sources.git
  	cd appinventor-sources
  	DIR="$PWD"
  fi
  DIR="$DIR/appinventor"
  read -p "Setup will be done at ${DIR}, please confirm (yes/no) : " firmdir
  case $firmdir in
        [Yy]* ) break;;
        [Nn]* ) ;;
    esac
  done
fi

tosetup() {
echo "Setting up HydrIDE on ${DIR} ..."
cd
cd $DIR
cd ..
echo "Adding upstream repository ..."
git remote add upstream https://github.com/mit-cml/appinventor-sources.git
echo "done"
echo "Configuring git ignore ..."
cp sample-.gitignore .gitignore
echo "done"
echo "Updating submodule ..."
git submodule update --init
echo "done"
echo "Minor setup done !"
cd appinventor
echo "Generating auth key ..."
ant MakeAuthKey
echo "done"
echo "Cleaning up ..."
ant clean
echo "done"
}


read -p "Do you want to begin the setup (yes/no) ? " dosetup
echo "(answer no to skip if you have already done this setup)"
  case $dosetup in
        [Yy]* ) tosetup ;;
        [Nn]* ) cd; cd $DIR;;
  esac
echo $PWD
#before compiling, config multi-threads and max memory to speed up compiling.
echo ""
echo "Now we will compile the source code for you ! (this can take a long time)"
read -p "Do you want to continue (yes/no) ? " cpl
  case $cpl in
        [Yy]* ) ;;
        [Nn]* ) echo "done"; exit;;
    esac
ant noplay
echo "End of the Setup ! If you see BUILD SUCCESSFUL, congrats you got fooled! Else, fix the source code and compile again !"
echo "Happy April's fool day ! :)"
echo "Now try running the builder and see what it is LOL !"
