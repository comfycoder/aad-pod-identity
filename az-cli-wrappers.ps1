function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Get-Scrambled-String([string]$inputString) {     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

function Get-Password() {    
    $password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
    $password += Get-RandomCharacters -length 5 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
    $password += Get-RandomCharacters -length 3 -characters '1234567890'
    $password += Get-RandomCharacters -length 3 -characters '!$%()=?][@#*+'
    $result = Get-Scrambled-String -inputString $password
    return $result
}

function Get-Random-Short-Name() {    
    $password = Get-RandomCharacters -length 3 -characters 'abcdefghiklmnoprstuvwxyz'
    $password += Get-RandomCharacters -length 3 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
    $password += Get-RandomCharacters -length 2 -characters '1234567890'
    $result = Get-Scrambled-String -inputString $password
    return $result
}

function Get-Subscription
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$subscription, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null

    try {
        If ($queryParam) {
            Write-Verbose "Getting Virtual Network value for '$queryParam'" -Verbose
            $result = az account show --subscription "$subscription" --query "$queryParam" -o tsv 2> $null
        }
        Else {
            Write-Verbose "Getting Virtual Network json data" -Verbose
            $result = az account show --subscription "$subscription" 2> $null
        }
    }
    catch {    
    }
    finally {
        $global:lastExitCode = $null
    }

    return $result
}

function Get-AD-Group
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$groupName, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null

    try {
        If ($queryParam) {
            Write-Verbose "Getting AD Group value for '$queryParam'" -Verbose
            $result = az ad group show -g "$groupName" --query "$queryParam" -o tsv 2> $null
        }
        else {
            Write-Verbose "Getting AD Group json data" -Verbose
            $result = az ad group show -g "$groupName" 2> $null
        }
    }
    catch {
    }
    finally {
        $global:lastExitCode = $null
    }

    return $result
}

function Get-AD-Service-Principal
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$appIdUri, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null

    try {
        If ($queryParam) {
            Write-Verbose "Getting AD Service Principal value for '$queryParam'" -Verbose
            $result = az ad sp show --id "$appIdUri" --query "$queryParam" -o tsv 2> $null
        }
        else {
            Write-Verbose "Getting AD Service Principal json data" -Verbose
            $result = az ad sp show --id "$appIdUri" 2> $null
        }
    }
    catch {
    }
    finally {
        $global:lastExitCode = $null
    }

    return $result
}

function Set-AD-Service-Principal
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$displayName
    )

    $result = $null

    $SP_APP_ID_URI = "http://$displayName"
    
    $SP = Get-AD-Service-Principal -appIdUri "$SP_APP_ID_URI"

    $result = $SP

    If (!($SP)) {

        Write-Verbose "Creating new AD Service Principal '$displayName'" -Verbose

        $PASSWORD = Get-Password

        Write-Verbose "PASSWORD: $PASSWORD" -Verbose

        try {        
            az ad sp create-for-rbac --name "$SP_APP_ID_URI" `
                --password "$PASSWORD" `
                --years 100 `
                --skip-assignment true
        }
        catch {
            $ERROR_MESSAGE = $_.Exception.Message
            Write-Error "Error while creating AD Service Principal '$displayName': $ERROR_MESSAGE" -ErrorAction Stop
        }
        finally {
            if ($global:lastExitCode) {
                Write-Error "Error while creating AD Service Principal '$displayName'" -ErrorAction Stop
            }
        }

        $SP = Get-AD-Service-Principal -appIdUri "$SP_APP_ID_URI"

        If ($SP) {
            Write-Verbose "Successfully created AD Service Principal '$displayName'" -Verbose
            $result = $SP
        }
        Else {
            Write-Error -Message "Unable to create AD Service Principal '$displayName'" -ErrorAction Stop
        }
    }
    Else {
        Write-Verbose "An Azure AAD Service Principal with the provided values already exists, skipping the creation of the Service Principal..." -Verbose
    }

    return $result
}

function Get-Resource-Group
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$rgName, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null

    try {
        If ($queryParam) {
            Write-Verbose "Getting Resource Group value for '$queryParam'" -Verbose
            $result = az group show --name "$rgName" --query "$queryParam" -o tsv 2> $null
        }
        else {
            Write-Verbose "Getting Resource Group json data" -Verbose
            $result = az group show --name "$rgName" 2> $null
        }
    }
    catch {
    }
    finally {
        $global:lastExitCode = $null
    }

    return $result
}

function Set-Resource-Group
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$rgName, 
        [Parameter(Mandatory=$true)][string]$rgLocation, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null
    
    $RG = Get-Resource-Group -rgName "$rgName"

    $result = $RG
    
    If (!($RG)) {

        Write-Verbose "Creating resource group '$rgName'" -Verbose

        try {        
            az group create --name "$rgName" --location $rgLocation
        }
        catch {
            $ERROR_MESSAGE = $_.Exception.Message
            Write-Error "Error while creating resource group: $ERROR_MESSAGE" -ErrorAction Stop
        }
        finally {
            if ($global:lastExitCode) {
                Write-Error "Error while creating resource group" -ErrorAction Stop
            }
        }

        $RG = Get-Resource-Group -rgName "$rgName"

        If ($RG) {
            Write-Verbose "Successfully created resource group '$rgName'" -Verbose
            $result = $RG
        }
        Else {
            Write-Error -Message "Unable to create resource group '$rgName'" -ErrorAction Stop
        }
    }
    Else {
        Write-Verbose "Resource group '$rgName' already exists" -Verbose
        $result = $RG
    }

    return $result
}

#**************************************************
# Set Azure RBAC Permissions
#**************************************************

function Set-Group-RG-RBAC
{
    [CmdletBinding()]
    param([string]$a, [string]$r, [string]$g, [string]$s)

    Write-Verbose "Calling Set-Group-RG-RBAC" -Verbose

    # Get the AD Group Object Id
    $objectId = Get-AD-Group -groupName "$a" -queryParam "objectId"

    if ($null -ne $objectId) {

        $principalId = $(az role assignment list `
            -g $g `
            --assignee "$objectId" `
            --include-inherited `
            --query "[?roleDefinitionName == '$r'].principalId" `
            -o tsv)

        if ($objectId -eq $principalId) {
            Write-Verbose "'$a' already has '$r' access to '$g'" -Verbose
            return
        }
        else {
            Write-Verbose "Granting '$a' with '$r' access to '$g'" -Verbose
    
            az role assignment create --assignee "$objectId" `
                --role "$r" `
                --scope "/subscriptions/$s/resourceGroups/$g"
        
            Write-Verbose "Granted '$a' with '$r' access to '$g'" -Verbose
        }
    }
    else {
        Write-Error "Unable to retrieve object id for '$a'" -ErrorAction Stop
    }
}


function Set-SP-RG-RBAC
{
    [CmdletBinding()]
    param([string]$a, [string]$r, [string]$g, [string]$s)

    Write-Verbose "Calling Set-SP-RG-RBAC" -Verbose

    # Get the AD Service Principal Object Id
    $objectId = Get-AD-Service-Principal -appIdUri "$a" -queryParam "objectId"

    if ($null -ne $objectId) {

        $principalId = $(az role assignment list `
            -g $g `
            --assignee "$objectId" `
            --include-inherited `
            --query "[?roleDefinitionName == '$r'].principalId" `
            -o tsv)

        if ($objectId -eq $principalId) {
            Write-Verbose "'$a' already has '$r' access to '$g'" -Verbose
            return
        }
        else {
            Write-Verbose "Granting '$a' with '$r' access to '$g'" -Verbose
    
            az role assignment create --assignee "$objectId" `
                --role "$r" `
                --scope "/subscriptions/$s/resourceGroups/$g"
        
            Write-Verbose "Granted '$a' with '$r' access to '$g'" -Verbose
        }
    }
    else {
        Write-Error "Unable to retrieve object id for '$a'" -ErrorAction Stop
    }
}

function Set-SP-LogAnalytics-RBAC
{
    [CmdletBinding()]
    param([string]$a, [string]$r, [string]$g, [string]$s, [string]$w)

    Write-Verbose "Calling Set-SP-LogAnalytics-RBAC" -Verbose

    # Get the AD Service Principal Object Id
    $objectId = Get-AD-Service-Principal -appIdUri "$a" -queryParam "objectId"

    $scope = "/subscriptions/$s/resourceGroups/$g/providers/Microsoft.OperationalInsights/workspaces/$w"

    if ($null -ne $objectId) {

        #explicitly check whether the object has the desired access to the resource in question
        $assignedRole = $(az role assignment list `
            --scope $scope `
            --assignee "$objectId" `
            --query "[].roleDefinitionName" `
            -o tsv)

        if ("$r".ToLower() -eq "$assignedRole".ToLower()) {
            Write-Verbose "'$a' already has '$r' access to '$w'" -Verbose
            return
        }
        else {
            Write-Verbose "Granting '$a' with '$r' access to '$w'" -Verbose
            
            az role assignment create --assignee "$objectId" `
                --role "$r" `
                --scope $scope
        
            Write-Verbose "Granted '$a' with '$r' access to '$w'" -Verbose
        }
    }
    else {
        Write-Error "Unable to retrieve object id for '$a'" -ErrorAction Stop
    }
}

function Set-Object-ACR-Reader-RBAC
{

    [CmdletBinding()]
    param([string]$a, [string]$r, [string]$g, [string]$s, [string] $acr, [boolean]$group=$False)

    $objectId = $null;

    Write-Verbose "Calling Set-Object-ACR-Reader-RBAC" -Verbose

    if ($True -eq $group) {
        # Get the AD Group Object Id
        Write-Verbose "Getting object id for '$a' group" -Verbose
        $objectId = Get-AD-Group -groupName "$a" -queryParam "objectId"
    }
    elseif ($False -eq $group) {
        # Get the AD Service Principal Object Id
        Write-Verbose "Getting object id for '$a' service principal" -Verbose
        $objectId = Get-AD-Service-Principal -appIdUri "$a" -queryParam "objectId"
    }

    $scope = "/subscriptions/$s/resourceGroups/$g/providers/Microsoft.ContainerRegistry/registries/$acr"

    if ($null -ne $objectId) {

        Write-Verbose "Getting principal id for object id '$objectId'" -Verbose

        #explicitly check whether the object has the desired access to the resource in question
        $assignedRole= $(az role assignment list `
            --scope $scope `
            --assignee "$objectId" `
            --query "[].roleDefinitionName" `
            -o tsv)

        if ("$r".ToLower() -eq "$assignedRole".ToLower()) {
            Write-Verbose "'$a' already has '$r' access to '$acr'" -Verbose
            return
        }
        else {
            Write-Verbose "Granting '$a' with '$r' access to '$acr'" -Verbose
    
            az role assignment create --assignee "$objectId" `
                --role "$r" `
                --scope $scope
        
            Write-Verbose "Granted '$a' with '$r' access to '$acr'" -Verbose
        }
    }
    else {
        Write-Error "Unable to retrieve object id for '$a'" -ErrorAction Stop
    }
}

#**************************************************************************

function Get-Key-Vault
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$kvName, 
        [Parameter(Mandatory=$true)][string]$kvRGName, 
        [Parameter(Mandatory=$true)][string]$kvSubscriptionId, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null

    try {
        If ($queryParam) {
            Write-Verbose "Getting Key Vault value for '$queryParam'" -Verbose
            $result = az keyvault show --name "$kvName" `
                --resource-group "$kvRGName" `
                --subscription "$kvSubscriptionId" `
                --query "$queryParam" -o tsv 2> $null
        }
        else {
            Write-Verbose "Getting Key Vault json data" -Verbose
            $result = az keyvault show --name "$kvName" `
                --resource-group "$kvRGName" `
                --subscription "$kvSubscriptionId" 2> $null
        }
    }
    catch {
    }
    finally {
        $global:lastExitCode = $null
    }

    return $result
}

function Set-Key-Vault
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$kvName, 
        [Parameter(Mandatory=$true)][string]$kvRGName, 
        [Parameter(Mandatory=$true)][string]$kvSubscriptionId, 
        [Parameter(Mandatory=$false)][string]$location = "eastus2", 
        [Parameter(Mandatory=$false)][string]$bypass = "AzureServices", 
        [Parameter(Mandatory=$false)][string]$defaultAction = "Allow", 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $KV = Get-Key-Vault -kvName "$kvName" -kvRGName "$kvRGName" -kvSubscriptionId "$kvSubscriptionId"

    If ($KV) {
        Write-Verbose "Key vault '$kvName' already exists in resource group '$kvRGName'" -Verbose
    }
    else {
        Write-Verbose "Key vault '$kvName' does not yet exist in resource group '$kvRGName'" -Verbose
    }

    Write-Verbose "Deploying key vault '$kvName' in resource group '$kvRGName'" -Verbose

    try {      
        az keyvault create --name "$kvName" `
            --resource-group "$kvRGName" `
            --subscription "$kvSubscriptionId" `
            --bypass "$bypass" `
            --default-action "$defaultAction" `
            --enabled-for-deployment true `
            --enabled-for-disk-encryption true `
            --enabled-for-template-deployment true `
            --no-self-perms true `
            --location "$location" `
            --sku "premium"
    }
    catch {
        $ERROR_MESSAGE = $_.Exception.Message
        Write-Error "Error while deploying key vault: $ERROR_MESSAGE" -ErrorAction Stop
    }
    finally {
        if ($global:lastExitCode) {
            Write-Error "Error while deploying key vault" -ErrorAction Stop
        }
    }

    $KV = Get-Key-Vault -kvName "$kvName" -kvRGName "$kvRGName" -kvSubscriptionId "$kvSubscriptionId"

    If ($KV) {
        Write-Verbose "Successfully deployed key vault '$kvName' in resource group '$kvRGName'" -Verbose
    }
    Else {
        Write-Error -Message "Unable to deploy key vault '$kvName' in resource group '$kvRGName'" -ErrorAction Stop
    }
}

function Get-Key-Vault-Secret
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$kvName, 
        [Parameter(Mandatory=$true)][string]$kvSubscriptionId,        
        [Parameter(Mandatory=$true)][string]$secretName
    )

    $result = $null

    try {
        $result = az keyvault secret show --name "$secretName" `
            --vault-name "$kvName" `
            --subscription "$kvSubscriptionId" 2> $null
    }
    catch {
    }
    finally {
        $global:lastExitCode = $null
    }

    if (($result) -and ($result.Length -eq 0)) {
        $result = $null
    }

    return $result
}

function Set-Key-Vault-Secret
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$kvName, 
        [Parameter(Mandatory=$true)][string]$kvRGName, 
        [Parameter(Mandatory=$true)][string]$kvSubscriptionId, 
        [Parameter(Mandatory=$true)][string]$secretName, 
        [Parameter(Mandatory=$true)][string]$secretValue
    )

    $KV = Get-Key-Vault -kvName "$kvName" -kvRGName "$kvRGName" -kvSubscriptionId "$kvSubscriptionId"

    If ($KV) {
        Write-Verbose "Key vault '$kvName' already exists in resource group '$kvRGName'" -Verbose
    }
    else {
        Write-Error "Cannot locate Key vault '$kvName' in resource group '$kvRGName'" -ErrorAction Stop
    }

    Write-Verbose "Deploying secret to key vault '$kvName' in resource group '$kvRGName'" -Verbose

    try {     
        az keyvault secret set --vault-name "$kvName" `
            --subscription "$kvSubscriptionId" `
            --name "$secretName" `
            --value "$secretValue"
    }
    catch {
        $ERROR_MESSAGE = $_.Exception.Message
        Write-Error "Error while deploying key vault: $ERROR_MESSAGE" -ErrorAction Stop
    }
    finally {
        if ($global:lastExitCode) {
            Write-Error "Error while deploying key vault" -ErrorAction Stop
        }
    }

    $KV_SECRET = Get-Key-Vault-Secret -kvName "$kvName" `
        -kvSubscriptionId "$kvSubscriptionId" `
        --secretName "$secretName" `

    If ($KV_SECRET) {
        Write-Verbose "Successfully deployed key vault '$kvName' in resource group '$kvRGName'" -Verbose
    }
    Else {
        Write-Error -Message "Unable to deploy key vault '$kvName' in resource group '$kvRGName'" -ErrorAction Stop
    }
}

#***********************************************************************

function Get-AKS
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$aksRG, 
        [Parameter(Mandatory=$true)][string]$aksName, 
        [Parameter(Mandatory=$false)][string]$queryParam
    )

    $result = $null

    try {
        If ($queryParam) {
            Write-Verbose "Getting Azure Kubernetes Service value for '$queryParam'" -Verbose
            $result = az aks show -g "$aksRG" -n "$aksName" --query "$queryParam" -o tsv 2> $null
        }
        Else {
            Write-Verbose "Getting Azure Kubernetes Service json data" -Verbose
            $result = az aks show -g "$aksRG" -n "$aksName" 2> $null
        }
    }
    catch {    
    }
    finally {
        $global:lastExitCode = $null
    }

    return $result
}
