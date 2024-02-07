param location string = resourceGroup().location
param cloudServiceName string = 'mycloudservice'
param defaultSubnetName string = 'default'
param internalSubnetName string = 'MyInternalSubnet'
param virtualNetworkName string = 'MyVnet'
param frontendIpNameExternal string = 'MyFrontendIPExternal'
param frontendIpNameInternal string = 'MyFrontendIPInternal'
param deploymentLabel string = 'DeploymentLabel'
param internalLBName string = 'MyInternalLB'
param externalLBName string = 'MyExternalLB'

var resourceGroupID = resourceGroup().id
var externalLBResourceID = '${resourceGroupID}/providers/Microsoft.Network/loadBalancers/${externalLBName}'
var internalLBResourceID = '${resourceGroupID}/providers/Microsoft.Network/loadBalancers/${internalLBName}'
var internalSubnetResourceID = '${resourceGroupID}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${internalSubnetName}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: defaultSubnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: internalSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource CloudService 'Microsoft.Compute/cloudServices@2022-09-04' = {
  name: cloudServiceName
  location: location
  dependsOn: [
    virtualNetwork
  ]
  tags: {
    DeploymentLabel: deploymentLabel
  }
  properties: {
    configurationUrl: 'https://fabianra.blob.core.windows.net/vsdeploy/ServiceConfiguration.Cloud.cscfg?sp=r&st=2023-05-17T20:56:25Z&se=2023-07-02T04:56:25Z&spr=https&sv=2022-11-02&sr=b&sig=5wo7RAmhinziOiyFLJoa7CHnCAt7RfzvFRudX%2BwsVX8%3D'
    networkProfile: {
      loadBalancerConfigurations: [
        {
          id: internalLBResourceID
          name: internalLBName
          properties: {
            frontendIpConfigurations: [
              {
                name: frontendIpNameInternal
                properties: {
                  privateIPAddress: '10.0.1.5'
                  subnet: {
                    id: internalSubnetResourceID
                  }
                }
              }
            ]
          }
        }
      ]
    }
    packageUrl: 'https://fabianra.blob.core.windows.net/vsdeploy/internalLBtest3.cspkg?sp=r&st=2023-05-17T20:54:26Z&se=2023-07-02T04:54:26Z&spr=https&sv=2022-11-02&sr=b&sig=neNwEkwNj7l4LgSMG14yE8yfHSEbNZhnUHxbbuvNKmA%3D'
    roleProfile: {
      roles: [
        {
          name: 'WebRole1'
          sku: {
            capacity: 2
            name: 'Standard_D1_v2'
          }
        }
      ]
    }
  }
}