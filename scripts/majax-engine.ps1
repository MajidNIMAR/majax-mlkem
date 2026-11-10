param(
    [ValidateSet('start', 'health', 'run', 'test', 'test-prebuilt', 'logs', 'stop')]
    [string]$Action = 'test',
    [string]$Message = 'MAJAX ML-KEM authenticated exchange'
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'majax-demo.ps1') -Action $Action -Message $Message
