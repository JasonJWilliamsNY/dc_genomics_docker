# dc_genomics_docker
Container development for Data Carpentry Genomics lessons

To run:

# Draft instructions

- Docker image: https://hub.docker.com/r/jasonjwilliamsny/dc_genomics
- Docker pull command: `docker pull jasonjwilliamsny/dc_genomics:dev_1.6`

## Setup config files

### Enter usernames for your hub users

1. Clone this repo and place `docker-persistant/` in
   a convenient location on your server. In `docker-persistant/`
   edit `usernames.txt`; this file should have one or more valid linux
   username(s) (one name per line). Accounts will be created in your
   container for each user. The sample list has `dcuser` which will be assigned
   the password by the script 'data4Carp'

   *tip*: You can edit the password in line 25 and 39 of `initiate.sh`

   Note: Your user will have a home directory at `/home/$user`
   This will be a symbolic link to a folder `docker-persistant/$user`
   that will be created on the machine running the docker container.
   In this way, data and changes made by the user on the hub will exist
   persistently outside of the container.

### Copy docker-persistant

1. Place `docker-persistant/` in a suitable location on the
   machine where Docker is hosted. The `-v` option used at execution
   will bind this folder.
2. Make sure `/docker-persistant/initiate.sh` is executable:

        chmod +x SOMEPATH/docker-persistant/initiate.sh


## Running the container

1. Pull the image from dockerhub

        docker pull jasonjwilliamsny/dc_genomics:dev_1.6

2. Start the container with this command (remember to edit the location of
   `docker-persistant/`)

        docker run -p 8787:8787 -p 22:22 --name dc_genomics -d -v SOMEPATH/docker-persistant:/docker-persistant jasonjwilliamsny/dc_genomics:dev_1.6

3. Rstudio will be available at the ip address of the machine

        127.0.0.1:8787
        localhost:8787

4. SSH will be accessible at the ip address of the machine

        127.0.0.1:22
        localhost:22

    Login
         dcuser
         data4Carp
