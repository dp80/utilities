$username = "devopsazuresvc001"
$azurePassword = "fan"
$location = 'West US'
$resourceGroupName = 'BastionResourceGroup'
$subscriptionName = 'IM-DW-Dev-ITG'

$password = ConvertTo-SecureString $azurePassword -ASPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($username, $password)

Login-AzureRmAccount -Credential $psCred

Write-output "Checking resource group $($resourceGroupName)"

$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location

if (-not $resourceGroup){
	Write-output "Resource group not found"
}
else
{
	write-output "Resource group $($resourceGroupName) exists"

}
