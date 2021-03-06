<#        
    .SYNOPSIS
     A brief summary of the commands in the file.

    .DESCRIPTION
    A detailed description of the commands in the file.

    .NOTES
    ========================================================================
         Windows PowerShell Source File 
         Created with SAPIEN Technologies PrimalScript 2019
         
         NAME: WSL-WorkWithDockerCompose.ps1
         
         AUTHOR: maxt@sapien.com , 
         DATE  : 7/8/2020
         
         COMMENT: List of useful Docker Compose commands.
         
    ==========================================================================
#>

## - Check Docker compose version:
docker-compose -version

## - Create yml config file
Create docker-compose.yml

## - Validate yml file:
docker-compose config

## - Run Docker-Compose configuration:
docker-compose up -d

## - Stop Docker-Compose configuration:
docker-compose down

## - Run Docker-Compose configuration scaling databases:
docker-compose up -d --scale ms-sql=4

