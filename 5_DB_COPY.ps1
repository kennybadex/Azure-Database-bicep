param(
    [string]$Location,
    [string]$primaryResourceGroup,
    [string]$primaryRegion,
    [string]$secondaryRegion,
    [string]$clientCode,
    [string]$primarySqlServerName ,
    [string]$secondarySqlServerName,
    [string]$primaryElasticPoolName ,
    [string]$secondaryElasticPoolName ,
    [string]$databaseSourceName
)


# Deploy Bicep
Write-Host "🚀 Deploying DB copy using Bicep ..." -ForegroundColor Cyan

New-AzSubscriptionDeployment -Location $Location `
                            -TemplateFile "./5_CREATE_DB_VIA_COPY.bicep" `
                            -Name "DBCopy_${clientCode}" `
                            -primaryResourceGroup $primaryResourceGroup `
                            -primaryRegion $primaryRegion `
                            -secondaryRegion $secondaryRegion `
                            -clientCode $clientCode `
                            -primarySqlServerName $primarySqlServerName `
                            -secondarySqlServerName $secondarySqlServerName `
                            -primaryElasticPoolName $primaryElasticPoolName `
                            -secondaryElasticPoolName $secondaryElasticPoolName `
                            -databaseSourceName $databaseSourceName


Write-Host "✅ DB copy deployment completed." -ForegroundColor Green

