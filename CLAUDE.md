# Project Notes

## Forked Packages

`packages/fluttermoji` is a local fork of `fluttermoji 1.0.2` from pub.dev.
The fork changes the "Blonde" hair color to bright yellow (`#F5D623`) in both
`hairStyle.dart` and `facialHair.dart`. The `analysis_options.yaml` excludes
`packages/**` from analysis since the upstream code has many lint warnings.
