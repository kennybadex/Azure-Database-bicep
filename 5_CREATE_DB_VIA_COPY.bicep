//TO BE DEPLOYED USING " New-AzSubscriptionDeployment -Location "canadacentral" -TemplateFile .\5_CREATE_DB_VIA_COPY.bicep  -Name 'DBtest13' "
// the -Location parameter is required but not used in the bicep as targetScope is 'subscription' So you can provide any location
// the -name parameter is just for deployment name tracking as well not used in the bicep, so you can provide any name

targetScope = 'subscription'

// Parameters
@description('The Resource Group Name')
param primaryResourceGroup string

param primaryRegion string
param secondaryRegion string
param clientCode string
param primarySqlServerName string
param primaryElasticPoolName string
param secondarySqlServerName string
param secondaryElasticPoolName string
param databaseSourceName string
param pointInTimeRestoreDays int = 35
param diffBackupFrequencyHours int = 12
param weeklyLtrBackupMonths int = 6

// Variables
var databaseName = '${clientCode}Database'

//Reference to existing original SQL database
resource databaseSource 'Microsoft.Sql/servers/databases@2021-05-01-preview' existing = {
  name: '${primarySqlServerName}/${databaseSourceName}'
  scope: resourceGroup(primaryResourceGroup)
}

// Create New ClientDatabase from original database (referencing db.bicep module file)
module dbModule './5_DB_COPY.bicep' = {
  name: 'createDatabase'
  scope: resourceGroup(primaryResourceGroup)
  params: {
    primaryRegion: primaryRegion
    sqlServerName: primarySqlServerName
    databaseName: databaseName
    primaryElasticPoolName: primaryElasticPoolName
    sourceDbId: databaseSource.id
    weeklyLtrBackupMonths: weeklyLtrBackupMonths
    diffBackupFrequencyHours: diffBackupFrequencyHours
    pointInTimeRestoreDays: pointInTimeRestoreDays
  }
}

// Create Replica (referencing db_replica.bicep module file)
module dbReplicaModule './5_DB_REPLICA.bicep' = {
  name: 'createDatabaseReplica'
  scope: resourceGroup(primaryResourceGroup)
  params: {
    secondaryRegion: secondaryRegion
    sqlServerName: secondarySqlServerName
    databaseName: databaseName
    secondaryElasticPoolName: secondaryElasticPoolName
    sourceDbId: databaseSource.id
    weeklyLtrBackupMonths: weeklyLtrBackupMonths
    diffBackupFrequencyHours: diffBackupFrequencyHours
    pointInTimeRestoreDays: pointInTimeRestoreDays
  }
}

// Outputs
output primaryDatabaseId string = dbModule.outputs.databaseName
output secondaryDatabaseId string = dbReplicaModule.outputs.databaseName
