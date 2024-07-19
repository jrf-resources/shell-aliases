### Jesse Russell's default settings and aliases
# This file should be kept safe for public usage

### init
# store session start date & time
alias SESSION_START_TIME='echo `date +"%m-%d-%Y %T"`'
# start ssh-agent
eval "$(ssh-agent -s)" &>/dev/null

### custom settings
# set username and id
export usr=`id -un`
export USERNAME=$usr
export uid=`id -u`
export USERID=$uid
# store newline string
export NEWLINE=$(printf "\r\n")
# make piping thru pgp work right
export GPG_TTY=`tty`
# refresh SSH_AUTH_SOCK because it gets stale when using screen which causes the connection to drop
export SSH_AUTH_SOCK=$(find /tmp/ssh-* -user `whoami` -name agent\* -printf '%T@ %p\n' 2>/dev/null | sort -k 1nr | sed 's/^[^ ]* //' | head -n 1)
# don't add duplicate commands the command history
export HISTCONTROL=ignoreboth

# custom functions
# prints the repo and branch
git_repo_branch() {
  repo=$(git remote -v 2>/dev/null | head -n 1 | sed -nE 's@^.*/(.*).git.*$@\1@p')
  if [ "$repo" != "" ]; then
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    printf "[$repo $branch]"
  else
    printf ""
  fi
}
# sets the prompt with or without color
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[01;32m\]\u@\h:\[\033[00m\] $(git_repo_branch) \n\[\033[01;34m\]\w\033[00m\] $ '
else
    PS1='\u@\h \w\n$ '
fi

# prints only the first row, e.g.
#   cat filename.txt | printheader
printheader() {
  IFS= read -r header
  printf '%s\n' "$header"
  "$@"
}

# if ~/.bin exists, add to PATH, otherwise try ~/bin, otherwise print warning
if [ -d "$HOME/.bin" ] ; then
  PATH="$HOME/.bin:$PATH"
  alias lsbin="ls -l $HOME/.bin"
  alias cdbin="cd $HOME/.bin"
elif [ -d "$HOME/bin" ] ; then
  PATH="$HOME/bin:$PATH"
  alias lsbin="ls -l $HOME/bin"
  alias cdbin="cd $HOME/bin"
else
  alias lsbin="echo 'no bin folder found'"
  alias cdbin="echo 'no bin folder found'"
fi

# function that prompts for displaying aliases
function aliasprompt {
  if [[ -f ~/.bash_aliases ]] ; then
    less ~/.bash_aliases
  fi
  if [[ -f ~/.custom_aliases ]] ; then
    less ~/.custom_aliases
  fi
  read -n1 -p ' >> Press A to display all aliases >> ' alias_key; echo $NEWLINE
  if [[ "$alias_key" == "a" || "$alias_key" == "A" ]] ; then
    alias | cut -d " " -f 2- | less
  fi
}

# function that calls ssh with the user by default
function sshuser {
  sshuser=''
  if [[ -z $1 ]] ; then
    sshuser=$1
  fi
  while [[ -z "$sshuser" ]]
  do
      read -p "ssh $USER@[ip/dns] >> " sshjrs
  done
  echo "> command to run >"
  echo "ssh $USER@$sshuser"
}

### custom aliases
# bash aliases
alias a="aliasprompt"
alias listalias="aliasprompt"
alias lista="aliasprompt"
alias aliases="less ~/.bash_aliases; less ~/.custom_aliases"
alias printalias="alias | cut -d ' ' -f 2- | less"
alias printa="printalias"
alias bashalias="nano ~/.bash_aliases; source ~/.bashrc"
alias customalias="nano ~/.custom_aliases; source ~/.bashrc"
alias editalias="bashalias; customalias"
alias edita="editalias"

# bash profile
alias hist='history'
alias lesshistory='history | less'
alias grephistory='cat history | grep'
alias currentshell='echo "Current shell: $SHELL"'
alias sourceme="source ~/.bashrc"
alias srcme="sourceme"
alias srcm="sourceme"
alias showprofile="less ~/.bashrc"
alias editprofile="nano ~/.bashrc; source ~/.bashrc"
alias root='sudo su'

# navigation
alias cd-alias="alias | grep cd"
alias cd..="cd .."
alias cdup="cd .."
alias cd1="cd .."
alias cd2="cd ../.."
alias cd3="cd ../../.."
alias cd-="cd -"
alias cdback="cd -"
alias cd~="cd ~"
alias cdhome="cd ~"
alias cdssh="cd ~/.ssh/"

# dates
alias date-alias="alias | grep date  | grep -v update"
alias sessionstarttime='echo `SESSION_START_TIME`'
alias currentdate='echo $(date +"%m-%d-%Y")'
alias datenow='currentdate'
alias currenttime='echo $(date +"%m-%d-%Y %T")'
alias datetimenow='currenttime'
alias filedate='echo $(date +"%Y%m%d")'
alias fdate='filedate'
alias filedatetime='echo $(date +"%Y%m%d_%H%M%S")'
alias fdatetime='filedatetime'

# files
# listing
alias ls-alias="alias | grep 'ls -'"
alias l='ls -l | awk '\''{print $9}'\'' | tail -n +2'
alias la='ls -al | awk '\''{print $9}'\'' | tail -n +2'
alias ll="ls -al"
alias lr="ls -lrt"
alias llgrep='ls -al ./ | grep'
# links
alias lns='ln -s'
# sizes
alias sizedir='du -sh * | sort -rn'
alias sizeit='du -sh'
alias sizeme='du -sh $(pwd)'
# viewing
alias firstln="head -n 1"
alias secondln="head -n 2 | tail -n 1"
alias skipfirstln="tail -n +2"
alias skipfirsttwo="tail -n +3"
alias les='less'
alias logdiff="read -p 'logfile=' logfile; egrep -v ^# $logfile"
# editing
alias su-nano='sudo nano'
alias sunano='su-nano'
alias su-vim='sudo vim'
alias suvim='su-vim'
# permissions
alias addexec='chmod +x'
# zip
alias setzipdir='read -p "folder to compress (w/o trailing slash) -> " zip_dir; zip_file="$zip_dir.zip"'
alias zipdir='setzipdir; zip -r "$zip_file" "$zip_dir"'
alias setzipfiles='read -p "files to compress (separated by spaces) -> " zip_files; zip_file="_zipped_files.zip"'
alias zipfile='setzipfiles; zip $zip_file $zip_files'

# networking
# port forwarding
alias setlocalport='read -p "127.0.0.1:<port> -> " localport'
alias setremoteport='read -p "hostname:<port> -> " remoteport'
alias setremotehost='read -p "<hostname>:$remoteport -> " remotehost'
alias setremoteuser='read -p "<username@$remotehost -> " remoteuser'
alias portforward="setlocalport && setremoteport && setremotehost && setremoteuser && ssh -f -N -L 127.0.0.1:$localport:$remotehost:$remoteport $remoteuser:$remotehost"
# ssh
alias loadoldkey='ssh-add ~/.ssh/id_rsa_old &>/dev/null'
alias addsshkey='bash <(curl -sSL https://jrussell.sh/add-ssh-key)'
alias convertkey='ssh-keygen -e -f'
alias sshgenkey='ssh-keygen -t ed25519 -C "jrussellfreelance@gmail.com"'
alias sshpubkey='cat ~/.ssh/id_rsa.pub'
alias showpubkey='cat ~/.ssh/id_rsa.pub'
alias sshprivkey='cat ~/.ssh/id_rsa | less'
alias showprivkey='cat ~/.ssh/id_rsa | less'
alias knownhosts='nano ~/.ssh/known_hosts'
alias authkeys='nano ~/.ssh/authorized_keys'
alias sshconfig='nano ~/.ssh/config'
# netstat
alias port-alias="alias | grep netstat; alias | grep port; alias | grep tcp"
alias allports="sudo netstat -tulpn | awk '{print $1 $4 $5 $7 $8}'"
alias nets='allports'
alias netports="nets | secondln; nets | skipfirsttwo"
alias tcpports="nets | secondln; nets | skipfirsttwo | grep tcp | grep -v tcp6"
alias tcpp='tcpports'
alias udpports="nets | secondln; nets | skipfirsttwo | grep udp | grep -v udp6"
alias udpp='udpports'
alias grepport="sudo netstat -tulpn | grep "
alias portcheck='grepport'
# ufw
alias lsufw="sudo ufw status"
# ssl
alias readcert='openssl x509 -noout -text -in'
alias readkey='openssl rsa -noout -text -in'
# ipv4
alias pubip='curl ifconfig.me; echo ""'
alias hostip='echo "$(sudo hostname): $(sudo hostname -I)"'
alias iprange='echo $(sudo hostname -I)'
alias ips='iprange'
# hosts
alias showhosts='cat /etc/hosts'
alias shosts='showhosts'
alias edithosts='sudo nano /etc/hosts'
alias ehosts='edithosts'

# if docker is installed, add docker aliases
if command -v docker > /dev/null; then
alias docker-alias="alias | grep docker"
alias lsdocker="sudo docker ps -a"
alias lsd='lsdocker'
alias dstoprm='read -p "name of container to stop and remove -> " dcrcont; sudo docker stop $dcrcont && sudo docker rm $dcrcont'
alias dockerstopremove='dstoprm'
alias dcnano='sudo nano docker-compose.yml'
alias dcvim='sudo vim docker-compose.yml'
alias dcless='sudo less docker-compose.yml'
alias dccat='sudo cat docker-compose.yml'
alias dcedit='dcnano'
alias dcreplace='echo '' > docker-compose.yml && dcedit'
alias dcprint='dccat'
alias dcshow='dcless'
# if docker-compose is installed, add those aliases
if command -v docker-compose > /dev/null; then
alias dc='sudo docker-compose'
alias dcup='sudo docker-compose up -d'
alias dcupbuild='sudo docker-compose up -d --build'
alias dcrestart='sudo docker-compose restart'
alias dcstart='sudo docker-compose start'
alias dcstop='sudo docker-compose stop'
alias dcdown='sudo docker-compose down'
alias dclogs='sudo docker-compose logs'
else
alias dc='sudo docker compose'
alias dcup='sudo docker compose up -d'
alias dcupbuild='sudo docker compose up -d --build'
alias dcrestart='sudo docker compose restart'
alias dcstart='sudo docker compose start'
alias dcstop='sudo docker compose stop'
alias dcdown='sudo docker compose down'
alias dclogs='sudo docker compose logs'
fi
fi

# if git is installed, add other git aliases
if command -v git > /dev/null; then
alias git-alias="alias | grep git"
alias gitconfig='bash <(curl -sSL https://jrussell.sh/configure-git)'
alias gitclone="bash <(curl -sSL https://jrussell.sh/recursive-git-clone)"
alias gitops="bash <(curl -sSL https://jrussell.sh/git-ops)"
alias gitseturl="git remote set-url origin"
# git aliases from Eric, plus new ones
alias ga='git add'
alias gitaddall='git add . --all'
alias gaa='gitaddall'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -D'
alias gbr="git br"
alias gc='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout master'
alias gcp='git cherry-pick'
alias gdh='git diff HEAD'
alias gdno='git diff --name-only'
alias gdom='git diff origin/master...'
alias gdoml='git diff origin/master:./ -- ' # diff files in master with uncommitted local files
alias gf='git fetch'
alias gfo='git fetch origin'
alias gits='git status'
alias gl='git log'
alias glsf='git ls-files --others --exclude-standard'
alias gm='git merge'
alias gmnn='git merge --no-ff --no-commit'
alias gmom='git merge origin/master'
alias gms='git merge --squash'
alias gmsn='git merge --squash --no-commit'
alias gp='git pull'
alias gpo='git pull origin'
alias gpom='git pull origin master'
alias gpso='git push origin'
alias gpsom='git push origin master'
alias grom='git rebase origin/master'
alias grv="git remote -v"
alias gitremote="git remote -v | grep fetch | awk {'print \$2'}"
alias gitr="gitremote"
# save git password to GIT_PASSWD
alias storegitpass='read -sp "Please enter your Git password: " GIT_PASSWD; echo "$NEWLINE"'
# to store git password on login: add storefitpass to init
fi

# if nginx is installed, add nginx aliases
if command -v nginx > /dev/null; then
alias nginx-alias="alias | grep nginx"
alias cdnginx="cd /etc/nginx"
alias sitesa='cd /etc/nginx/sites-available'
alias sitese='cd /etc/nginx/sites-enabled'
alias lssites='ls -l /etc/nginx/sites-enabled'
alias lssitesa='ls -l /etc/nginx/sites-available'
alias nginxstart='sudo systemctl start nginx'
alias nginxstop='sudo systemctl stop nginx'
alias nginxrestart='sudo systemctl restart nginx'
alias nginxreload='sudo systemctl reload nginx'
alias nginxtest='sudo nginx -t'
alias ngint='nginxtest'
alias nginxstatus='sudo systemctl status nginx'
alias nginxerrors='sudo tail -f /var/log/nginx/error.log'
alias nginxaccess='sudo tail -f /var/log/nginx/access.log'
alias createproxy='bash <(curl -sSL https://jrussell.sh/create-nginx-proxy)'
alias nginxedit='echo "current live sites:" && lssites; read -p "file=" filename; sudo nano /etc/nginx/sites-available/$filename'
alias nginxnew='nginxedit'
alias nginxcopy='lssites; read -p "oldfile=" oldfile; read -p "newfile=" newfile; sudo rm -rf /etc/nginx/sites-available/$newfile && sudo cp -ar /etc/nginx/sites-available/$oldfile /etc/nginx/sites-available/$newfile && sudo nano /etc/nginx/sites-available/$newfile && nginxlink && nginxreload'
alias nginxlink='read -p "nginx config to link -> " confname; sudo ln -s /etc/nginx/sites-available/$confname /etc/nginx/sites-enabled/$confname && echo "current live sites:" && lssites | grep $confname'
alias nginxunlink='echo "current live sites:" && lssites && read -p "nginx config to unlink -> " confname; sudo unlink /etc/nginx/sites-enabled/$confname'
alias nginxrename='read -p "nginx config to rename -> " confname; sudo mv /etc/nginx/sites-available/$confname /etc/nginx/sites-available/$confname'
fi

# if ollama is installed, add ollama aliases
if command -v ollama > /dev/null; then
alias ollama-alias='alias | grep ollama'
alias oa='ollama-alias'
alias o='ollama'
alias oh='ollama help'
alias op='ollama pull'
alias ols='ollama list'
alias ops='ollama ps'
alias orm='ollama rm'
fi

# if nvidia is installed, add nvidia aliases
if command -v nvidia-smi > /dev/null; then
alias gpu='watch -n 1 nvidia-smi'
fi

# unsorted
