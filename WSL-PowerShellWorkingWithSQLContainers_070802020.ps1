<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.159
	 Created on:   	2/25/2019 12:42 PM
	 Created by:   	max_t
	 Organization: 	SAPIEN Technologies, Inc.
	 Filename:     	WSL-PowerShellWorkingWithSQLContainers_07082020.ps1
	 Updated: 		07/01/2020
	===========================================================================
	.DESCRIPTION
	Docker Demo scripts updated for use on WSL.
	Get images at: 
	https://hub.docker.com/_/microsoft-mssql-server
	https://hub.docker.com/r/microsoft/mssql-server-windows-express/
	
#>

## First Thing To-Do => Make sure that WSL 2 is updated:
sudo apt update && sudo apt -y upgrade
sudo apt install -y smbclient cifs-utils

#region PullDockerContainerImage

## - Docker Pull to download SQL Server images -> 2017/2019 - latest-ubuntu:
#-> docker pull mcr.microsoft.com/mssql/server:2017-latest
docker pull mcr.microsoft.com/mssql/server:2019-latest

## - To work with Windows SQLServer, Docker needs to be set for Windows Containers - ##
#-> docker pull microsoft/mssql-server-windows-express

## - Check for pull images:
docker images

## - First time to create a container: (Linux)
# - SQL Server 2017 container uses a root user:
#->docker run -e "ACCEPT_EULA=Y" -e 'SA_PASSWORD=$SqlPwd01A' -e 'TZ=America/New_York' -e "MSSQL_PID=Developer" -p 1433:1433 --name sql2k17_01_original -d mcr.microsoft.com/mssql/server:2017-latest;

# - SQL Server 2019 container uses a non-root user: (Run in PowerShell)
pwsh
docker run -e 'ACCEPT_EULA=Y' `
-e 'SA_PASSWORD=$SqlPwd01A' `
-e 'TZ=America/New_York' `
-e "MSSQL_PID=Developer" `
-p 1434:1434 --name sql2k19_01_original `
-d mcr.microsoft.com/mssql/server:2019-latest;

# - Windows SQL Server, switch to Windows Containers:
#-> docker run -e "ACCEPT_EULA=Y" -e 'SA_PASSWORD=$SqlPwd01A' -e 'TZ=America/New_York' -e "MSSQL_PID=Developer" -p 1435:1435 --name sql2k17_01_original -d microsoft/mssql-server-windows-express

## - Check for active containers:
docker ps -a

#endregion DockerPullImages

#region CustomizingDockerContainerImage

## - Customizing the SQL Server 2019 container - ##

## - Execute commands non-interactive: (Using default user: mssql)
docker exec -i sql2k19_01_original cat /etc/os-release;

## <-- Start updating Docker SQL Server Container --> ##

## - Configuring your container using "root" user:
docker exec -it -u root sql2k19_01_original bash

## - First, do both apt update and upgrade: (Install existing update)
	apt update && apt -y upgrade

## - Install sudo utility to be use with mssql user:
	apt install -y sudo
	apt update && apt -y upgrade
	
## - Add mssql user to the sudoer group:
	adduser mssql sudo 

## - Use below command to edit the Sudoer file: (If needed)
	visudo

## - Resetting user mssql password:
	passwd mssql  #-> enter password twice
	
## - Add sqlcmd path to the bashrc file:
    ## - Open bashrc in VIM editor:
	sudo vim ~/.bashrc
	
	## - Insert line below in bashrc file to find SQLCMD for "root" user:
	export PATH="$PATH:/opt/mssql-tools/bin" 
	
	## - Save and exit vim editor:
	:wq

## - Reload bashrc after adding path:
	source ~/.bashrc	

## - Exit "root" user:
	exit
	
## - Continue to complete configuring container using "mssql" user:
docker exec -it -u mssql sql2k19_01_original bash

## - Create folders needed for "mssql" user:
	cd /home
	
	sudo mkdir mssql
	
	sudo chmod 777 mssql
	
	cd /home/mssql
	
	sudo mkdir Downloads
	
	sudo chmod 755 Downloads
	
	sudo mkdir Documents
	
	sudo chmod 755 Documents
	
## - Try executing the following commands:
	vim 
	ifconfig
	ping 
	
## - Check what applications are already installed in the container:
	dpkg --list	

## - Install in Bash missing components:
	sudo apt-get install -y \
	vim \
	iputils-ping \
	net-tools \
	smbclient \
	cifs-utils \
	powershell	
	
## - Open PowerShell and Download Anaconda with Python 3.7 (Dated: 07/06/2020):
	sudo pwsh
	
		cd /home/mssql/Downloads
		Invoke-WebRequest https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh `
		-OutFile Anaconda3-2020.02-Linux-x86_64.sh;
		
## - Install Anaconda with Python 3.7 and Exit PowerShell:
		bash Anaconda3-2020.02-Linux-x86_64.sh
		
		## - Install SQL Server and Az (Azure) Modules:
		Install-Module -Name SqlServer;
		
		Install-Module -Name Az;
		
		## - List all installed modules:
		Get-Module -ListAvailable | select name, version;
		
		## - Exit PowerShell
		exit
		
## - Add sqlcmd path to the bashrc file:
    ## - Open bashrc in VIM editor:
	sudo vim ~/.bashrc
	
	## - Insert line below in bashrc file to find SQLCMD for "root" user:
	export PATH="$PATH:/opt/mssql-tools/bin" 
	
	## - Save and exit vim editor:
	:wq

## - Reload bashrc after adding path:
	source ~/.bashrc	

## - Test SQLCMD to get prompt:
	sqlcmd -S localhost -U sa -P '$SqlPwd01A';

### Enter text in sqlcmd prompt:
	   	select @@Version
	  	go
	  
	  	select name from Sys.databases
	  	go
	    exit	
	
## - After installing additional components repeat:
	sudo apt update && sudo apt -y upgrade	

## - Exit "mssql" user:
	exit
	
## <-- End of updating Docker SQL Server Container --> ##
#endregion UpdateDockerContainers

#region CreatingNewDockerContainerImage

## - Get the "containerId" before committing changes:
docker ps -a

## - Stop Custom Container before commit:
docker stop sql2k19_01_original

## - Commit the container changes:
docker commit "Container_ID" sql2k19_01_original:MyVer1

## - List images included the committed ones:
docker images
docker ps -a

####----------------------------####

## - Save customized docker image:
docker save -o ./MyDockerImages/sql2k19_01_orgv1_07082020.tar sql2k19_01_original:MyVer1

## - Copy saved image to a Windows shared folder:
cp ./MyDockerImages/sql2k19_01_orgv1_07082020.tar /mnt/c/MySharedFiles/MyDockerImages
ll /mnt/c/MySharedFiles/MyDockerImages

####----------------------------####

#endregion


# -
# - Bonus Section:
# -

#region TestDockerContainers
## - Testing commited changes - ##

## - In another WSL 2 system map to a network drive:
sudo mkdir /mnt/z
sudo mount -t drvfs Z: /mnt/z

## - Load updated image:
docker load -i "Path-Of-Image"/sql2k19_01_orgv1_07082020.tar
docker images

## - Start and verify updated version has vim and execute sqlcmd command:
docker run -p 1450:1450 --name sql2k19_01_orgv1 -d sql2k19_01_original:MyVer1;
docker exec -it sql2k19_01_orgv1 bash

## - Try executing the following commands:
	vim ~/.bashrc
	ifconfig
	sqlcmd -S localhost -U sa -P '$SqlPwd01A'
		select * from sys.databases
		go
		exit
	
## - Exit Container:
	exit

#endregion TestDockerContainers#

#region DockerManaging&Troubleshooting

## - Inspecting Container: (JSON Output file)
docker container inspectsql2k19_01_orgv1

## - Get only the IPAddress:
(docker container inspect sql2k19_01_orgv1 `
| ConvertFrom-Json).NetworkSettings.IPAddress;

## - Run the ifconfig interacive:
docker exec -i sql2k19_01_original ifconfig

## - Checking for image missing dependencies issues:
docker image ls -a

## - Stopping all containers:
docker stop $(docker ps -a)
docker ps -a

## - Examing container logs:
docker logs "Container_ID"

## - Stopping all containers:
docker stop $(docker ps -a)
docker ps -a

## - Clean All Images only:
docker rmi $(docker images -q) -f
docker images

## - Clear all existing containers
docker rm $(docker ps -a)
docker ps -a

## - Stop a single container:
docker stop "Container_ID"

## - Remove a single container:
docker rm "Container_ID"

## - Remove a single image:
docker rmi "Image_ID"

#endregion DockerManaging&Troubleshooting

#region PersistDataSQLServer

## -> Bonus Persist Data Docker PowerShell Sample
## - Use a Local Machine Folder name to map SQL Server databases:
docker run --name sql2k19_01_orgv2 -p 1439:1439 `
-e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=$SqlPwd01A' `
-e 'TZ=America/New_York' -e 'MSSQL_PID=Developer' `
-v /home/maxt/MySQLDBdata:/var/opt/mssql `
-d sql2k19_01_original:MyVer1;;

#endregion BonusSection
