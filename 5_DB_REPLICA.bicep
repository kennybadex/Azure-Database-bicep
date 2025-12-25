targetScope = 'resourceGroup'

param secondaryRegion string
param sqlServerName string
param databaseName string
param sourceDbId string
param secondaryElasticPoolName string
param weeklyLtrBackupMonths int
param diffBackupFrequencyHours int
param pointInTimeRestoreDays int

//Reference to existing secondary SQL Server
resource secondarySqlServer 'Microsoft.Sql/servers@2021-05-01-preview' existing = {
  name: sqlServerName
}

// Reference to existing secondary Elastic Pool
resource secondaryElasticPool 'Microsoft.Sql/servers/elasticPools@2021-05-01-preview' existing = {
  name: secondaryElasticPoolName
  parent: secondarySqlServer
}

// Create Replica
resource newClientSecondaryDB 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: databaseName
  parent: secondarySqlServer
  location: secondaryRegion
  properties: {
    createMode: 'Secondary'
    sourceDatabaseId: sourceDbId
    elasticPoolId: secondaryElasticPool.id
  }
}

// Configure Retention Policies
resource secondaryRetentionPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-05-01-preview' = {
  name: 'default'
  parent: newClientSecondaryDB
  properties: {
    weeklyRetention: 'P${weeklyLtrBackupMonths}M'
  }
}

resource primaryShortTermRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-08-01-preview' = {
  name: 'default'
  parent: newClientSecondaryDB
  properties: {
    retentionDays: pointInTimeRestoreDays
    diffBackupIntervalInHours: diffBackupFrequencyHours
  }
}

output databaseName string = newClientSecondaryDB.name
