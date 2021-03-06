<#        
    .SYNOPSIS
     A brief summary of the commands in the file.

    .DESCRIPTION
    A detailed description of the commands in the file.

    .NOTES
    ========================================================================
         Windows PowerShell Source File 
         Created with SAPIEN Technologies PrimalScript 2020
         
         NAME: WSL-PowerShellBonus_QueryingSQLServerInContainer.ps1
         
         AUTHOR: max_trinidad@hotmail.com , 
         DATE  : 7/8/2020
         
         COMMENT: Sample shows after committng more changes to the container
         and then using the PowerShell SqlServer module to run some queries.
          
    ==========================================================================
#>

## - Commit the container changes:
docker stop sql2k19_01_original

docker commit "Container_ID" sql2k19_01_original:MyVer1

## - List images included the committed ones:
docker images
docker ps -a

####----------------------------####

## - Save docker updated image:
docker save -o ./MyDockerImages/sql2k19_01_orgv1_07082020.tar sql2k19_01_original:MyVer1

## - Copy saved image to a Windows shared folder:
cp ./MyDockerImages/sql2k19_01_orgv1_07082020.tar /mnt/c/MySharedFiles/MyDockerImages
dir /mnt/c/MySharedFiles/MyDockerImages

## - 
## - Next steps are executed in another System
## - 

## - In another WSL 2 system map to a network drive:

## - Create drive letter folder before mapping the network drive:
#-> sudo mkdir /mnt/z

## - Mount Network Drive:
sudo mount -t drvfs Z: /mnt/z

## - Load updated image:(WSL)
docker load -i /mnt/z/MyDockerImages/sql2k19_01_orgv1_07082020.tar

## - Or in Windows:
docker load -i z:\MyDockerImages\sql2k19_01_orgv1_07082020.tar

## - Verify new image is loaded:
docker images

## - Start updated Container then run SQL queries from PowerShell:
docker run -p 1450:1450 --name sql2k19_01_orgv1 -d sql2k19_01_original:MyVer1;
docker exec -it sql2k19_01_orgv1 bash

	## - Open PowerShell:
	pwsh
	
	## - few ways to run SQL queries:
	
	# - Using SQLCMD:
	sqlcmd -S localhost -U sa -P '$SqlPwd01A'
	
	# - Using SqlServer module:
	Invoke-Sqlcmd -ServerInstance "172.17.0.2" -credential sa -query "select @@Version as SQLVersion";
	Invoke-Sqlcmd -ServerInstance "172.17.0.2" -credential sa -query "select name from sys.databases";
	
	# - Exit PowerShell:
	exit
	
	## - Exit Container:
	exit

## - To unmount mapped network drive:
cd /home/maxt
sudo umount /mnt/z
