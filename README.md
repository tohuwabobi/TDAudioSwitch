# TDAudioSwitch

TDAudioSwitch ist ein einfaches PowerShell-CLI-Tool fuer Windows zum schnellen Umschalten von Standard-Audiogeraeten.

## Aktueller Funktionsumfang

- Aktive Wiedergabegeraete auflisten
- Aktive Mikrofone auflisten
- Wiedergabegeraet per einzelner Tasteneingabe waehlen
- Mikrofon per einzelner Tasteneingabe waehlen
- Standard-Ausgabe und Standard-Mikrofon direkt in Windows setzen
- Mit der Leertaste jederzeit ohne Aenderung abbrechen
- Ungueltige Eingaben abfangen und erneut abfragen

## Projektstruktur

- `main.ps1`: Hauptskript mit der CLI-Logik
- `TDAudioSwitch.bat`: Bequemer Starter fuer Windows

## Start

Empfohlen:

- `TDAudioSwitch.bat` per Doppelklick starten

Alternativ:

- `powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\main.ps1`

## Bedienung

1. Tool starten
2. Gewuenschte Ziffer fuer das Wiedergabegeraet druecken
3. Gewuenschte Ziffer fuer das Mikrofon druecken
4. Erfolgsmeldung in der Konsole pruefen

Hinweise:

- Es wird jeweils direkt eine Taste gelesen, ohne Enter
- Mit der Leertaste wird sofort ohne Aenderung beendet
- Das Tool setzt die ausgewaehlten Geraete fuer `Console`, `Multimedia` und `Communications`

## Anforderungen

- Windows
- PowerShell
- Interaktive Konsole fuer die Tasteneingabe

## Technische Basis

- Geraete-Erkennung ueber Windows Core Audio / MMDevice API
- Setzen des Standardgeraets ueber `PolicyConfig`

## Bekannte Einschraenkungen

- Der Start braucht eine echte Konsole, weil `ReadKey()` genutzt wird
- Automatisierte Tests fuer die interaktive Auswahl sind nur eingeschraenkt moeglich
- Das Tool ist aktuell bewusst auf den MVP ohne Hotkeys, GUI oder Konfigurationsdatei begrenzt

## Status

MVP funktionsfaehig.
