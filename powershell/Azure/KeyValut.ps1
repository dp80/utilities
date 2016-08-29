##### This powershell script creates a Key vault, adds key and pwd to vault and sets access for the serviceprincipal to the key and pwd##
##
##
##
##



$VaultName = "suppro-key"
$ResourceGroupName = "Core-SeRG"
$subscription = "e461-b3f4-cc7f65dd8cee"  #{IT core services}
$keyName = 'AzSto'
$convertString = ''
$location = 'west us'
$ServicePrincipal = ''
$logStorageAccountID = '/subscriptions/e461018b-4540-b3f4-cc7f65dd8cee/resourceGroups/core-services-scus-rg/providers/Microsoft.Storage/storageAccounts/keyvaultdiagnostics'


Login-AzureRmAccount

set-azurermcontext -SubscriptionId $subscription

$keyvault = New-AzureRmKeyVault -VaultName $VaultName -ResourceGroupName $ResourceGroupName -Location $location

### TODO: Do we need KeyName or Secret? 
###  TODO: Permission on the ServicePrincipal"  should not be all
###  TODO: Encriytption of serviceprincipal and serviceprincipalkey in configuration file
### Need to get clarificaiton from SupplyChain Team

$key = Add-AzureKeyVaultKey -VaultName $keyvault.VaultName -Name $keyName -Destination 'software'

$key.key.kid

$secretvalue = ConvertTo-SecureString $convertString -AsPlainText -Force
$secret = Set-AzureKeyVaultSecret -VaultName $keyvault.VaultName -Name $pwdName -SecretValue $secretvalue
$secret.Id

# : This command gets a tabular display of all keys and selected properties.
#$Keys = Get-AzureKeyVaultKey -VaultName $VaultName
#$vault = Get-AzureRmkeyVault -VaultName $VaultName

# : This command displays a full list of properties for the specified key


#$Keys[0]

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyvault.VaultName -ServicePrincipalName $ServicePrincipal -PermissionsToKeys Get,unwrapkey

Set-AzureRmKeyVaultAccessPolicy -VaultName $keyvault.VaultName -ServicePrincipalName $ServicePrincipal -PermissionsToSecrets Get

Set-AzureRmDiagnosticSetting -ResourceId $keyvault.ResourceId -StorageAccountId $logStorageAccountID -Enabled $true -Categories AuditEvent
#To Remove Keyvault
#Remove-AzureRmKeyVault -VaultName $VaultName