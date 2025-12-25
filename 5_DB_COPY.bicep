targetScope = 'resourceGroup'

param primaryRegion string
param sqlServerName string
param databaseName string
param sourceDbId string
param primaryElasticPoolName string
param weeklyLtrBackupMonths int
param diffBackupFrequencyHours int
param pointInTimeRestoreDays int

//Reference to existing primary SQL Server
resource primarySqlServer 'Microsoft.Sql/servers@2021-05-01-preview' existing = {
  name: sqlServerName
}

// Reference to existing primary Elastic Pool
resource primaryElasticPool 'Microsoft.Sql/servers/elasticPools@2021-05-01-preview' existing = {
  name: primaryElasticPoolName
  parent: primarySqlServer
}

// Create New ClientDatabase from orginal database
resource newClientPrimaryDB 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: databaseName
  parent: primarySqlServer
  location: primaryRegion
  properties: {
    createMode: 'Copy'
    sourceDatabaseId: sourceDbId
    elasticPoolId: primaryElasticPool.id
  }
  tags: {
    w5dbtype: 'clientprod'
  }
}

// Configure Retention Policies
resource primaryRetentionPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-05-01-preview' = {
  name: 'default'
  parent: newClientPrimaryDB
  properties: {
    weeklyRetention: 'P${weeklyLtrBackupMonths}M'
  }
}

resource primaryShortTermRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-08-01-preview' = {
  name: 'default'
  parent: newClientPrimaryDB
  properties: {
    retentionDays: pointInTimeRestoreDays
    diffBackupIntervalInHours: diffBackupFrequencyHours
  }
}

output databaseName string = newClientPrimaryDB.name
