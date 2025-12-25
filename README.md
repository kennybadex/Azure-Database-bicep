W5 Database Copy and Deployment (PowerShell + Bicep)

This script triggers a Bicep deployment that creates a copy of an existing Azure SQL database, placing primary and secondary copies into their designated elastic pools across regions.




🚀 What This Script Does

- Executes a subscription-level Bicep deployment
- Copies an existing Azure SQL database
- Places the new DB copies into primary & secondary elastic pools
- Supports multi-region deployments
- Automates naming via clientCode



🧩 Parameters
Name	                            Description
Location	                        Azure deployment location (e.g., eastus)
primaryResourceGroup	            Resource group containing the source DB
primaryRegion	                    Region of the primary copy
secondaryRegion	                    Region of the secondary copy
clientCode	                        Client name Identifier used in deployment naming
primarySqlServerName	            Primary SQL Server name
secondarySqlServerName	            Secondary SQL Server name
primaryElasticPoolName	            Elastic pool for the primary DB copy
secondaryElasticPoolName	        Elastic pool for the secondary DB copy
databaseSourceName	                Name of the source SQL database being copied




Sample Usage 

1. First Authenticate using: Connect-AzAccount
2. Secondly ensure you are in the right subscription using: Set-AzContext -SubscriptionObject "Subscrption id goes here"

3. Run
.\5_DB_COPY.ps1 `
    -Location "eastus" `
    -primaryResourceGroup "rg-app-primary" `
    -primaryRegion "eastus" `
    -secondaryRegion "westus" `
    -clientCode "ABC" `
    -primarySqlServerName "sql-primary-001" `
    -secondarySqlServerName "sql-secondary-001" `
    -primaryElasticPoolName "primaryPool" `
    -secondaryElasticPoolName "secondaryPool" `
    -databaseSourceName "appdb"




The linked Bicep file handles:
Server/region validation
Database copy creation
Elastic pool placement
