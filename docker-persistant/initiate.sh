#!/bin/bash
# Is anything with this many if statements going to be a good idea?
# This script will create linux users from a list (usernames.txt)
# Multiple conditionals are writen so that users are only created when needed
# and for the case where the hub needs to be resarted.


# Create users if needed and deal with existing or missing persistant folders
# and home directory symbolic links inside the container

# Check to see if the user in the usernames.txt exists
for user in $(cat /docker-persistant/usernames.txt)
  do
  # Senario where user does not exist on the container (i.e launching or
  # restarting a container )
  if ! id "$user" >/dev/null 2>&1
  then
      # if the user does not exist in the container but they have a folder at
      # docker-persistant/$user create the user and use their existing folder
      # in docker-persistant/ as a target for a symbolic link to ~/$user
      if [ -d "/docker-persistant/$user" ]
      then
          echo "Using existing persistant folder for $user"
          base=$user
          password=$(openssl passwd -1 -salt xyz 'data4Carp')
          useradd -p $password $user
          ln -s /docker-persistant/$user /home/$user
          chown -R $user /docker-persistant/$user
          chown -R $user /home/$user
          echo "user $user added successfully!"
      # if the user does not exist in the container and they do not have a
      # folder in docker-persistant/ create docker-persistant/$user
      # create the user on the container and use docker-persistant/$user as a
      # target for a symbolic link to ~/$user
      else
          echo "Creating persistant folder for $user"
          cp -r /docker-persistant/skel /docker-persistant/$user
          base=$user
          password=$(openssl passwd -1 -salt xyz 'data4Carp')
          useradd -p $password $user
          ln -s /docker-persistant/$user /home/$user
          chown -R $user /docker-persistant/$user
          chown -R $user /home/$user
          echo "user $user added successfully!"
      fi
  # Senario where user already exists in the container (i.e. restarting a
  # service but not the container)
  else
      # Check to see if the symbolic link ~/$user exists and that its target
      # /docker-persistant exists. Create or use existing links and folders
      # as needed
      if [ ! -L "/home/$user" ]
      then
          if [ ! -d "/docker-persistant/$user" ]
          then
              cp -r /docker-persistant/skel /docker-persistant/$user
              echo "Creating persistant folder for $user"
              ln -s /docker-persistant/$user /home/$user
              chown -R $user /docker-persistant/$user
              chown -R $user /home/$user
          else
              echo "Using existing persistant folder for $user"
              ln -s /docker-persistant/$user /home/$user
              chown -R $user /docker-persistant/$user
              chown -R $user /home/$user
          fi
      else
          if [ ! -d "/docker-persistant/$user" ]
          then
              echo "Creating persistant folder for $user"
              cp -r /docker-persistant/skel /docker-persistant/$user
              rm /home/$user
              ln -s /docker-persistant/$user /home/$user
              chown -R $user /docker-persistant/$user
              chown -R $user /home/$user
          else
              echo "Nothing to do"
          fi
      fi
  fi
  done

#configure shell
rm /bin/sh
ln -s /bin/bash /bin/sh
echo "SHELL=/bin/bash" >> /etc/environment

# Add dcuser to the ssh list and resart the service
mkdir /run/sshd
echo "Port 22
PermitRootLogin yes
AllowUsers dcuser
" > /etc/ssh/sshd_config
service ssh --full-restart
# Sart Rsudio server
echo "server-app-armor-enabled=0" >> /etc/rstudio/rserver.conf
rstudio-server start --server-daemonize=0 --server-app-armor-enabled=0
# keep this script running forever so the container does not exit
sleep infinity
