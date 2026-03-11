# MerGattos-IC10-Library

## Compile all `.slang` scripts

Run this from the repository root:

```powershell
npm run build
```

Currently, `build` runs the slang compiler step. The script compiles every `.slang` file using `slang.exe -z` and writes outputs to `compiled\` as `<name>.compiled.ic10`.

You can also run only this step directly:

```powershell
npm run compile:slang
```

If PowerShell blocks `npm.ps1` due execution policy, use:

```powershell
npm.cmd run compile:slang
```
