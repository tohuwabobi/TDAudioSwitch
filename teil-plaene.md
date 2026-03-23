# Teil-Plaene fuer TDAudioSwitch

## Teil-Plan 1: Projektgeruest

### Ziel

Eine minimale, startbare Projektbasis schaffen.

### Aufgaben

- `main.ps1` als Einstiegspunkt vorbereiten
- `TDAudioSwitch.bat` mit Startkommando versehen
- Konsolentitel und Begruessung ausgeben
- Saubere Grundstruktur fuer Funktionen anlegen

### Ergebnis

Das Tool laesst sich per Batch-Datei starten und beendet sich kontrolliert.

## Teil-Plan 2: Audio-Geraete auslesen

### Ziel

Alle relevanten Wiedergabe- und Aufnahmegeraete in PowerShell verfuegbar machen.

### Aufgaben

- Geeignete technische Methode zum Auslesen festlegen
- Ausgabegeraete ermitteln
- Mikrofone ermitteln
- Geraetenamen und technische IDs erfassen
- Nur sinnvolle, waehlbare Geraete anzeigen

### Ergebnis

Beide Geraetelisten koennen stabil in der Konsole angezeigt werden.

## Teil-Plan 3: Anzeige und Menuefuehrung

### Ziel

Eine einfache und gut lesbare CLI-Auswahl bauen.

### Aufgaben

- Ausgabegeraete nummeriert anzeigen
- Mikrofone nummeriert anzeigen
- Kurze Bedienhinweise einblenden
- Leertaste als Abbruch klar kommunizieren

### Ergebnis

Der Nutzer versteht sofort, welche Eingaben moeglich sind.

## Teil-Plan 4: Eingabe und Validierung

### Ziel

Zuverlaessige Tastatureingaben verarbeiten.

### Aufgaben

- Einzelne Tastendruecke lesen
- Zahlen einer Geraeteauswahl zuordnen
- Leertaste als Abbruch behandeln
- Ungueltige Eingaben abfangen
- Bei Fehlern eine neue Eingabe ermoeglichen

### Ergebnis

Die Bedienung funktioniert stabil ohne unklare Zustandswechsel.

## Teil-Plan 5: Standardgeraete setzen

### Ziel

Das gewaehlte Wiedergabe- oder Aufnahmegeraet als Windows-Standard setzen.

### Aufgaben

- Technik zum Setzen des Standardgeraets festlegen
- Wechsel fuer Ausgabegeraete umsetzen
- Wechsel fuer Mikrofone umsetzen
- Erfolg und Fehler sichtbar machen

### Ergebnis

Die Auswahl des Nutzers wird tatsaechlich in Windows uebernommen.

## Teil-Plan 6: Fehlerfaelle und Robustheit

### Ziel

Typische Problemfaelle sauber behandeln.

### Aufgaben

- Verhalten ohne gefundene Geraete absichern
- Verhalten bei fehlenden Rechten pruefen
- Fehler beim Setzen des Standardgeraets abfangen
- Verstaendliche Fehlermeldungen formulieren

### Ergebnis

Das Tool scheitert nachvollziehbar und nicht still.

## Teil-Plan 7: Start per Batch-Datei

### Ziel

Das PowerShell-Skript bequem fuer den Alltag startbar machen.

### Aufgaben

- `TDAudioSwitch.bat` mit passendem PowerShell-Aufruf fuellen
- Arbeitsverzeichnis sauber setzen
- Optional Ausfuehrungsrichtlinie fuer den Start beruecksichtigen
- Fehlermeldungen sichtbar lassen

### Ergebnis

Das Tool kann per Doppelklick oder Terminal bequem gestartet werden.

## Teil-Plan 8: Manuelle Tests

### Ziel

Das MVP auf einem echten Windows-System absichern.

### Aufgaben

- Test mit mehreren Ausgabegeraeten
- Test mit mehreren Mikrofonen
- Test mit Leertaste ohne Aenderung
- Test mit ungueltiger Eingabe
- Test ohne angeschlossene Alternativgeraete

### Ergebnis

Die wichtigsten Nutzungsszenarien sind einmal praktisch geprueft.

### Test-Checkliste fuer den aktuellen Stand

- `TDAudioSwitch.bat` per Doppelklick starten und pruefen, ob das Menue sichtbar bleibt
- Wiedergabegeraet per Ziffer waehlen und kontrollieren, ob danach die Mikrofon-Auswahl erscheint
- Mikrofon per Ziffer waehlen und kontrollieren, ob beide Standardgeraete uebernommen wurden
- In Schritt 1 oder 2 die Leertaste druecken und pruefen, ob ohne Aenderung beendet wird
- Eine ungueltige Taste wie `x` oder `0` druecken und pruefen, ob die Eingabe erneut abgefragt wird
- Mit mehreren angeschlossenen Geraeten pruefen, ob die angezeigten Namen zu den echten Windows-Geraeten passen
- Optional PowerShell als Administrator starten und erneut testen, falls beim Setzen ein Zugriffsproblem auftritt

## Teil-Plan 9: Dokumentation

### Ziel

Die reale Benutzung knapp und klar dokumentieren.

### Aufgaben

- README auf den echten technischen Stand bringen
- Startanleitung ergaenzen
- Bekannte Einschraenkungen nennen
- MVP-Grenzen knapp dokumentieren

### Ergebnis

Das Projekt ist fuer dich spaeter schnell wieder verstaendlich.

## Empfohlene Umsetzungsreihenfolge

1. Projektgeruest
2. Audio-Geraete auslesen
3. Anzeige und Menuefuehrung
4. Eingabe und Validierung
5. Standardgeraete setzen
6. Fehlerfaelle und Robustheit
7. Start per Batch-Datei
8. Manuelle Tests
9. Dokumentation
