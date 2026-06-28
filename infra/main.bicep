@secure()
param vulnerabilityAssessments_Default_storageContainerPath string
param workspaces_Dataknow_dev_name string = 'Dataknow-dev'
param vaults_kv_dataknow_dev_eastus_name string = 'kv-dataknow-dev-eastus'
param accessConnectors_acc_dataknow_dev_name string = 'acc-dataknow-dev'
param servers_sv_db_dataknow_dev_centralus_001_name string = 'sv-db-dataknow-dev-centralus-001'
param storageAccounts_stdataknowdeveastus001_name string = 'stdataknowdeveastus001'

resource accessConnectors_acc_dataknow_dev_name_resource 'Microsoft.Databricks/accessConnectors@2026-01-01' = {
  name: accessConnectors_acc_dataknow_dev_name
  location: 'eastus'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource workspaces_Dataknow_dev_name_resource 'Microsoft.Databricks/workspaces@2026-01-01' = {
  name: workspaces_Dataknow_dev_name
  location: 'eastus'
  sku: {
    name: 'premium'
  }
  properties: {
    computeMode: 'Hybrid'
    defaultCatalog: {
      initialType: 'UnityCatalog'
    }
    managedResourceGroupId: '/subscriptions/b0c32288-84bb-4386-a198-f924532e5dda/resourceGroups/databricks-rg-${workspaces_Dataknow_dev_name}-l7aepjmbmz7nk'
    parameters: {
      enableNoPublicIp: {
        type: 'Bool'
        value: true
      }
      prepareEncryption: {
        type: 'Bool'
        value: false
      }
      requireInfrastructureEncryption: {
        type: 'Bool'
        value: false
      }
      storageAccountName: {
        type: 'String'
        value: 'dbstorages5vmmablicoda'
      }
      storageAccountSkuName: {
        type: 'String'
        value: 'Standard_ZRS'
      }
    }
    authorizations: [
      {
        principalId: '9a74af6f-d153-4348-988a-e2672920bee9'
        roleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
      }
    ]
    createdBy: {}
    updatedBy: {}
  }
}

resource vaults_kv_dataknow_dev_eastus_name_resource 'Microsoft.KeyVault/vaults@2026-03-01-preview' = {
  name: vaults_kv_dataknow_dev_eastus_name
  location: 'eastus'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '8db9f793-4e2c-4a93-96a6-64b0679f9a80'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    accessPolicies: [
      {
        tenantId: '8db9f793-4e2c-4a93-96a6-64b0679f9a80'
        objectId: 'f233a306-b10e-4462-9b99-57932cec1eb6'
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    vaultUri: 'https://${vaults_kv_dataknow_dev_eastus_name}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_resource 'Microsoft.Sql/servers@2025-02-01-preview' = {
  name: servers_sv_db_dataknow_dev_centralus_001_name
  location: 'centralus'
  kind: 'v12.0'
  properties: {
    administratorLogin: 'admin_dataknow'
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    retentionDays: -1
  }
}

resource storageAccounts_stdataknowdeveastus001_name_resource 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageAccounts_stdataknowdeveastus001_name
  location: 'eastus'
  tags: {
    'ms-resource-usage': 'azure-cloud-shell'
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dualStackEndpointPreference: {
      publishIpv6Endpoint: false
    }
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    isHnsEnabled: true
    networkAcls: {
      ipv6Rules: []
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource vaults_kv_dataknow_dev_eastus_name_finbank_sql_db 'Microsoft.KeyVault/vaults/secrets@2026-03-01-preview' = {
  parent: vaults_kv_dataknow_dev_eastus_name_resource
  name: 'finbank-sql-db'
  location: 'eastus'
  tags: {
    'file-encoding': 'utf-8'
  }
  properties: {
    attributes: {
      enabled: true
    }
  }
}

resource vaults_kv_dataknow_dev_eastus_name_finbank_sql_host 'Microsoft.KeyVault/vaults/secrets@2026-03-01-preview' = {
  parent: vaults_kv_dataknow_dev_eastus_name_resource
  name: 'finbank-sql-host'
  location: 'eastus'
  tags: {
    'file-encoding': 'utf-8'
  }
  properties: {
    attributes: {
      enabled: true
    }
  }
}

resource vaults_kv_dataknow_dev_eastus_name_finbank_sql_password 'Microsoft.KeyVault/vaults/secrets@2026-03-01-preview' = {
  parent: vaults_kv_dataknow_dev_eastus_name_resource
  name: 'finbank-sql-password'
  location: 'eastus'
  tags: {
    'file-encoding': 'utf-8'
  }
  properties: {
    attributes: {
      enabled: true
    }
  }
}

resource vaults_kv_dataknow_dev_eastus_name_finbank_sql_port 'Microsoft.KeyVault/vaults/secrets@2026-03-01-preview' = {
  parent: vaults_kv_dataknow_dev_eastus_name_resource
  name: 'finbank-sql-port'
  location: 'eastus'
  tags: {
    'file-encoding': 'utf-8'
  }
  properties: {
    attributes: {
      enabled: true
    }
  }
}

resource vaults_kv_dataknow_dev_eastus_name_finbank_sql_user 'Microsoft.KeyVault/vaults/secrets@2026-03-01-preview' = {
  parent: vaults_kv_dataknow_dev_eastus_name_resource
  name: 'finbank-sql-user'
  location: 'eastus'
  tags: {
    'file-encoding': 'utf-8'
  }
  properties: {
    attributes: {
      enabled: true
    }
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_CreateIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_DbParameterization 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_DefragmentIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_DropIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_ForceLastGoodPlan 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

resource Microsoft_Sql_servers_auditingPolicies_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  location: 'Central US'
  properties: {
    auditingState: 'Disabled'
  }
}

resource Microsoft_Sql_servers_auditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/auditingSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_connectionPolicies_servers_sv_db_dataknow_dev_centralus_001_name_default 'Microsoft.Sql/servers/connectionPolicies@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'default'
  location: 'centralus'
  properties: {
    connectionType: 'Default'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_FINBANK 'Microsoft.Sql/servers/databases@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'FINBANK'
  location: 'centralus'
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  kind: 'v12.0,user,vcore,serverless'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    requestedBackupStorageRedundancy: 'Local'
    minCapacity: json('0.5')
    maintenanceConfigurationId: '/subscriptions/b0c32288-84bb-4386-a198-f924532e5dda/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
    availabilityZone: 'NoPreference'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  location: 'Central US'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/auditingSettings@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource servers_sv_db_dataknow_dev_centralus_001_name_master_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Current'
  properties: {}
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_sv_db_dataknow_dev_centralus_001_name_master_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Current'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_sv_db_dataknow_dev_centralus_001_name_master_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2025-02-01-preview' = {
  name: '${servers_sv_db_dataknow_dev_centralus_001_name}/master/Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_devOpsAuditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_current 'Microsoft.Sql/servers/encryptionProtector@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'current'
  kind: 'servicemanaged'
  properties: {
    serverKeyName: 'ServiceManaged'
    serverKeyType: 'ServiceManaged'
    autoRotationEnabled: false
  }
}

resource Microsoft_Sql_servers_extendedAuditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/extendedAuditingSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_ClientIPAddress_2026_06_27_13_49_49 'Microsoft.Sql/servers/firewallRules@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'ClientIPAddress_2026-06-27_13-49-49'
  properties: {
    startIpAddress: '186.29.32.222'
    endIpAddress: '186.29.32.222'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_ClientIPAddress_2026_6_24_18_2_15 'Microsoft.Sql/servers/firewallRules@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'ClientIPAddress_2026-6-24_18-2-15'
  properties: {
    startIpAddress: '186.155.17.143'
    endIpAddress: '186.155.17.143'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_ClientIPAddress_2026_6_27_13_54_31 'Microsoft.Sql/servers/firewallRules@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'ClientIPAddress_2026-6-27_13-54-31'
  properties: {
    startIpAddress: '186.29.32.222'
    endIpAddress: '186.29.32.222'
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_ServiceManaged 'Microsoft.Sql/servers/keys@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'ServiceManaged'
  kind: 'servicemanaged'
  properties: {
    serverKeyType: 'ServiceManaged'
  }
}

resource Microsoft_Sql_servers_securityAlertPolicies_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/securityAlertPolicies@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
}

resource Microsoft_Sql_servers_sqlVulnerabilityAssessments_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource Microsoft_Sql_servers_vulnerabilityAssessments_servers_sv_db_dataknow_dev_centralus_001_name_Default 'Microsoft.Sql/servers/vulnerabilityAssessments@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_resource
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
    storageContainerPath: vulnerabilityAssessments_Default_storageContainerPath
  }
}

resource storageAccounts_stdataknowdeveastus001_name_default 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    staticWebsite: {
      enabled: false
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_stdataknowdeveastus001_name_default 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_resource
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {
        encryptionInTransit: {
          required: true
        }
      }
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: false
      days: 0
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_stdataknowdeveastus001_name_default 'Microsoft.Storage/storageAccounts/queueServices@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_stdataknowdeveastus001_name_default 'Microsoft.Storage/storageAccounts/tableServices@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  location: 'Central US'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/auditingSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupLongTermRetentionPolicies_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_default 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'default'
  properties: {
    timeBasedImmutability: 'Disabled'
    weeklyRetention: 'PT0S'
    monthlyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
    weekOfYear: 0
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Current'
  properties: {}
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Current'
  properties: {
    state: 'Enabled'
    scanState: 'Complete'
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_sv_db_dataknow_dev_centralus_001_name_FINBANK_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2025-02-01-preview' = {
  parent: servers_sv_db_dataknow_dev_centralus_001_name_FINBANK
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_sv_db_dataknow_dev_centralus_001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_bronze 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_default
  name: 'bronze'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_gold 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_default
  name: 'gold'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_silver 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  parent: storageAccounts_stdataknowdeveastus001_name_default
  name: 'silver'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_logs 'Microsoft.Storage/storageAccounts/fileServices/shares@2026-04-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccounts_stdataknowdeveastus001_name_default
  name: 'logs'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 6
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_csms_queue_40aa7639_042c_4f9b_8f1d_8d354a7e977d 'Microsoft.Storage/storageAccounts/queueServices/queues@2026-04-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_stdataknowdeveastus001_name_default
  name: 'csms-queue-40aa7639-042c-4f9b-8f1d-8d354a7e977d'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_csms_queue_61ecef5e_de64_4dd0_b69a_d209213997aa 'Microsoft.Storage/storageAccounts/queueServices/queues@2026-04-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_stdataknowdeveastus001_name_default
  name: 'csms-queue-61ecef5e-de64-4dd0-b69a-d209213997aa'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}

resource storageAccounts_stdataknowdeveastus001_name_default_csms_queue_9bdcc707_2685_475f_99b2_34b54deea758 'Microsoft.Storage/storageAccounts/queueServices/queues@2026-04-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_stdataknowdeveastus001_name_default
  name: 'csms-queue-9bdcc707-2685-475f-99b2-34b54deea758'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_stdataknowdeveastus001_name_resource
  ]
}
