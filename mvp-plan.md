# MVP-Plan fuer TDAudioSwitch

## Ziel

Ein kleines Windows-CLI-Tool in PowerShell, das vorhandene Audio-Ausgabegeraete und Mikrofone anzeigt und dem Nutzer erlaubt, per Tastatureingabe das Standard-Ausgabegeraet und das Standard-Mikrofon zu wechseln.

## MVP-Funktionsumfang

- Alle relevanten Audio-Ausgabegeraete auflisten
- Alle relevanten Mikrofone auflisten
- Auswahl per Tastatur fuer Ausgabegeraet anbieten
- Auswahl per Tastatur fuer Mikrofon anbieten
- Leertaste beendet ohne Aenderung
- Nach erfolgreicher Aenderung kurze Rueckmeldung ausgeben
- Start ueber `TDAudioSwitch.bat` ermoeglichen

## Nicht Teil des MVP

- Grafische Oberflaeche
- Maussteuerung
- Persistente Konfigurationsdatei
- Hotkeys im Hintergrund
- Automatisches Umschalten nach App oder Kontext
- Erweiterte Fehlerdiagnose

## Technischer Ansatz

- `main.ps1` enthaelt die komplette Logik
- `TDAudioSwitch.bat` startet das PowerShell-Skript bequem per Doppelklick
- Audio-Geraete werden ueber eine Windows-taugliche Methode ausgelesen
- Das Setzen des Standardgeraets wird ueber eine praktikable, lokal verfuegbare Loesung umgesetzt

## Arbeitspakete

## 1. Projektstart

- Batch-Datei mit Startkommando fuellen
- Grundstruktur im PowerShell-Skript anlegen
- Konsolenausgabe fuer Menues vorbereiten

## 2. Geraete-Erkennung

- Ausgabegeraete ermitteln
- Mikrofone ermitteln
- Geraete sauber nummeriert anzeigen

## 3. Auswahl-Logik

- Tastenabfrage fuer beide Kategorien
- Leertaste als Abbruch ohne Aenderung
- Ungueltige Eingaben abfangen

## 4. Standardgeraet wechseln

- Gewaehltes Ausgabegeraet als Standard setzen
- Gewaehltes Mikrofon als Standard setzen
- Erfolg oder Fehler in der Konsole anzeigen

## 5. Abschluss

- README nachziehen, sobald die Technik feststeht
- Einmal manuell mit mehreren Geraeten testen
- Typische Fehlerfaelle pruefen

## Offene Entscheidung

Die wichtigste technische Frage ist, auf welchem Weg PowerShell das Standard-Audiogeraet aendert. Falls die reine Bordmittel-Loesung zu unzuverlaessig ist, sollte fuer den MVP eine kleine, robuste externe Helferloesung eingeplant werden.

## Definition of Done fuer MVP

- Tool startet per Batch-Datei
- Ausgabe- und Eingabegeraete werden getrennt angezeigt
- Nutzer kann je ein Standardgeraet auswaehlen
- Leertaste beendet ohne Aenderung
- Aenderung funktioniert in einem realen Windows-Test
