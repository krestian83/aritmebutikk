# Project Notes

## Launching the Web Server

Always use this compound command to avoid port conflicts from lingering dart
processes:

```sh
powershell -Command "Get-NetTCPConnection -LocalPort 10001 -EA 0 | % { Stop-Process -Id $_.OwningProcess -Force }"; sleep 2 && flutter run -d web-server --web-port=10001 --web-hostname=192.168.10.2
```

## Forked Packages

`packages/fluttermoji` is a local fork of `fluttermoji 1.0.2` from pub.dev.
The fork changes the "Blonde" hair color to bright yellow (`#F5D623`) in both
`hairStyle.dart` and `facialHair.dart`. The `analysis_options.yaml` excludes
`packages/**` from analysis since the upstream code has many lint warnings.
