# Define os endereços IPv4 e IPv6 dos servidores AdGuard e o template DoH
$dohServerIPv4_1 = "94.140.14.14"
$dohServerIPv4_2 = "94.140.14.15"
$dohServerIPv6_1 = "2a10:50c0::ad1:ff"
$dohServerIPv6_2 = "2a10:50c0::ad2:ff"
$dohTemplate = "https://dns.adguard-dns.com/dns-query"

# Adiciona os servidores DoH apenas se eles ainda não estiverem na lista
# Isso evita o erro de "objeto já existe"
Write-Host "Verificando e adicionando servidores DoH (IPv4)..."
$dohServers = Get-DnsClientDohServerAddress
if ($dohServers.ServerAddress -notcontains $dohServerIPv4_1) {
    Add-DnsClientDohServerAddress -ServerAddress $dohServerIPv4_1 -DohTemplate $dohTemplate -AllowFallbackToUdp $False -AutoUpgrade $True
}
if ($dohServers.ServerAddress -notcontains $dohServerIPv4_2) {
    Add-DnsClientDohServerAddress -ServerAddress $dohServerIPv4_2 -DohTemplate $dohTemplate -AllowFallbackToUdp $False -AutoUpgrade $True
}

Write-Host "Verificando e adicionando servidores DoH (IPv6)..."
if ($dohServers.ServerAddress -notcontains $dohServerIPv6_1) {
    Add-DnsClientDohServerAddress -ServerAddress $dohServerIPv6_1 -DohTemplate $dohTemplate -AllowFallbackToUdp $False -AutoUpgrade $True
}
if ($dohServers.ServerAddress -notcontains $dohServerIPv6_2) {
    Add-DnsClientDohServerAddress -ServerAddress $dohServerIPv6_2 -DohTemplate $dohTemplate -AllowFallbackToUdp $False -AutoUpgrade $True
}

# Configura os adaptadores de rede

Write-Host "Configurando DNS para todos os adaptadores de rede ativos..."
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

foreach ($adapter in $adapters) {
    Write-Host "Configurando adaptador: $($adapter.InterfaceAlias)"
    
    # Define os servidores DNS estáticos para o adaptador
    Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses @($dohServerIPv4_1, $dohServerIPv4_2, $dohServerIPv6_1, $dohServerIPv6_2)
}
netsh dns show encryption
Write-Host "Configuração DoH concluída com sucesso!"