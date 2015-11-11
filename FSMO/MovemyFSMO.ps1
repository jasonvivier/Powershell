#
#0 – PDCEmulator 
#1 – RIDMaster 
#2 – InfrastructureMaster 
#3 – SchemaMaster 
#4 – DomainNamingMaster
#

Move-ADDirectoryServerOperationMasterRole -Identity "Target-DC" -OperationMasterRole 0,1,2,3,4