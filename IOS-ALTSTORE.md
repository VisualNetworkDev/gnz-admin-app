# GNZ Admin Pro para iPhone

Esta carpeta ya tiene la plataforma iOS creada para la app Flutter.

## Datos de la app

- Nombre visible: GNZ Admin Pro
- Bundle ID: com.gnzoilservices.gnzAdminFlutter
- Version actual: 1.0.5+5
- Logo: usa `assets/gnz-logo.png` en los iconos iOS.

## Compilacion desde Windows

Windows no ejecuta Xcode localmente. Este proyecto usa GitHub Actions con una maquina macOS para compilar y validar el `.ipa` desde esta misma PC.

## Flujo con AltStore

1. En GitHub, abrir `Actions`.
2. Seleccionar `Crear IPA GNZ para iPhone`.
3. Pulsar `Run workflow`.
4. Descargar el artefacto `GNZ-Admin-Pro-iOS-unsigned` cuando termine.
5. Instalar el `.ipa` con AltStore.

## Source oficial

Agregar esta direccion en AltStore como Source:

`https://raw.githubusercontent.com/VisualNetworkDev/gnz-admin-app/main/altstore-source.json`

## Updates con AltStore

AltStore detecta updates desde un Source JSON comparando la primera entrada de `versions` con la version instalada. Para cada version nueva hay que actualizar `version` y el numero posterior a `+` en `pubspec.yaml`, crear el commit y publicar una etiqueta como `v1.0.6`. GitHub Actions se encarga de:

1. Verificar el codigo con analisis y pruebas.
2. Compilar y validar el nuevo `.ipa`.
3. Publicar el `.ipa` en GitHub Releases.
4. Agregar la nueva version al inicio de `altstore-source.json`.

Ejemplo:

```json
{
  "name": "GNZ Oil Services",
  "identifier": "com.gnzoilservices.source",
  "apps": [
    {
      "name": "GNZ Admin Pro",
      "bundleIdentifier": "com.gnzoilservices.gnzAdminFlutter",
      "developerName": "GNZ Oil Services",
      "localizedDescription": "Panel administrativo GNZ para citas, tracking, catalogo, filtros y servicios.",
      "versions": [
        {
          "version": "1.0.5",
          "buildVersion": "5",
          "date": "2026-07-20",
          "localizedDescription": "Primera version iPhone preparada para AltStore.",
          "downloadURL": "https://github.com/VisualNetworkDev/gnz-admin-app/releases/download/v1.0.5/GNZ-Admin-Pro-1.0.5.ipa",
          "minOSVersion": "13.0"
        }
      ]
    }
  ]
}
```
