# GNZ Admin Pro

Aplicacion Flutter administrativa de GNZ Oil Services para Windows y iPhone.

## Verificacion local

```powershell
flutter analyze
flutter test
flutter build windows --release
```

La compilacion iOS se ejecuta en GitHub Actions mediante `.github/workflows/build-ios-unsigned.yml`. El resultado es un `.ipa` sin firma preparado para instalar con AltStore.
