Was ist dxlAPRS?

Das System wurde vom österreichischen Funkamateur Chris (OE5DXL) entwickelt. Die Philosophie dahinter unterscheidet sich grundlegend von herkömmlicher Software:

• Modularität: Jedes Programm erfüllt genau eine Aufgabe. Man kombiniert sie wie Bausteine.

• Kommandozeile: Es gibt keine klassischen Konfigurationsdateien. Alle Einstellungen werden beim Start direkt als Parameter im Terminal übergeben.

• Vernetzung: Die Tools kommunizieren untereinander über das Netzwerkprotokoll UDP (bzw. das amateurfunkspezifische AXUDP). Das macht das System extrem flexibel und universell einsetzbar.



--------------------------------------------------------------------------------

Die wichtigsten Werkzeuge der Toolchain

Hier sind die zentralen Komponenten, die den Kern von dxlAPRS bilden:

• aprsmap: Ein leistungsstarker APRS-Viewer, der OpenStreetMap-Karten nutzt, um Positionen von Funkstationen, Fahrzeugen oder Wetterballons grafisch darzustellen.

• udpgate4: Ein sehr stabiles und funktionsreiches APRS-iGate, das Daten zwischen dem Funkweg und dem Internet (APRS-IS) vermittelt und über ein eigenes Web-Interface verfügt.

• udpbox: Ein „intelligenter“ APRS-Digipeater. Dieses Tool kann Datenströme filtern, bearbeiten und an mehrere Empfänger gleichzeitig verteilen.

• afskmodem: Ein Software-Modem (Soundmodem), das AFSK/FSK-Modulationen von 300 bis 19200 Baud auf zwei Kanälen unterstützt. Es ersetzt quasi die Hardware-TNCs.

• sondemod \& sondeudp: Spezialwerkzeuge für das Tracking von Wetterballons. sondeudp fungiert als Modem für die Signale, während sondemod die Daten verschiedener Sondentypen (wie RS92, RS41, DFM06 oder SRC-C34) dekodiert.

• gps2aprs \& gps2digipos: Diese Tools verwandeln einen Rechner mit angeschlossener GPS-Maus in einen Tracker oder erzeugen präzise Positions-Baken für Digipeater und iGates.

• udpflex: Dient als Schnittstelle zwischen seriellen Protokollen (wie RMNC oder KISS) und der AXUDP-Welt von dxlAPRS.

• udphub: Fungiert wie ein Layer-2-Switch für AX25-Daten. Er erlaubt es, einen AXUDP-Port eines Digipeaters für viele verschiedene Nutzer gleichzeitig verfügbar zu machen.



--------------------------------------------------------------------------------

Was kann man damit konkret machen?

Die Einsatzszenarien reichen von einfachen Heimanwendungen bis hin zu komplexer Infrastruktur:

1\. APRS-Station und Visualisierung

Mit der Kombination aus afskmodem (für den Funkempfang), udpbox (zur Datenverteilung) und aprsmap hast du eine vollständige Bodenstation. Du siehst in Echtzeit alle Aktivitäten in deinem Einzugsbereich auf einer Karte.

2\. iGate und Digipeater-Betrieb

Durch udpgate4 kannst du ein professionelles Gateway betreiben, das lokale Funksignale ins weltweite Netz einspeist. Dank der intelligenten Logik von udpbox lassen sich auch komplexe Digipeater-Szenarien realisieren, die nur bestimmte Pakete weiterleiten, um den Funkkanal zu entlasten.

3\. Wettersonde-Tracking (Sondenjagd)

Dies ist eines der populärsten Einsatzgebiete. Du kannst Signale von Wetterballons empfangen, dekodieren und die Position direkt in APRS-Objekte umwandeln. So erscheinen die Sonden auf der Karte (auch auf Plattformen wie aprs.fi), was das Verfolgen und Bergen erheblich erleichtert.

4\. SDR-Anbindung und Flugfunk (ADS-B)

In Verbindung mit günstigen RTL-SDR-Sticks und dem Tool sdrsdr wird der Rechner zum vollwertigen Funkempfänger. Zusätzlich bietet die Toolchain Werkzeuge, um ADS-B-Transpondersignale von Flugzeugen zu dekodieren und diese lokal auf der Karte anzuzeigen.

5\. Packet Radio und LoRa

Die Toolchain unterstützt auch klassisches Packet Radio (z.B. als Terminal mit ax252ch) sowie modernes LoRa-APRS (über das Tool ra02), was sie zu einem Schweizer Taschenmesser für digitale Betriebsarten macht.



--------------------------------------------------------------------------------

Ein praktisches Beispiel: Der Datenfluss

Um zu verdeutlichen, wie die Tools zusammenarbeiten, hier eine typische Kette für den Empfang von APRS via SDR-Stick:

1\. SDR-Quelle: Ein Treiber stellt das Signal des USB-Sticks bereit.

2\. sdrsdr: Empfängt die Frequenz (z.B. 144.800 MHz) und gibt das Audio digital weiter.

3\. afskmodem: Hört das Audio und wandelt die Töne in digitale Datenpakete um.

4\. udpbox: Nimmt diese Pakete und schickt sie gleichzeitig an:

&nbsp;   ◦ aprsmap (damit du sie auf der Karte siehst).

&nbsp;   ◦ udpgate4 (damit sie ins Internet weitergeleitet werden).

Diese Flexibilität durch das "Hintereinanderschalten" kleiner Programme ist die größte Stärke von dxlAPRS. Es erfordert zwar eine gewisse Einarbeitungszeit in die Kommandozeile, bietet dafür aber Möglichkeiten, die mit herkömmlicher grafischer Software kaum erreichbar sind.

