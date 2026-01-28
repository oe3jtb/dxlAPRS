#!/bin/bash

#   ***************************************************************** OE3JTB *************************************************************************
#   * Starten des DXLAPRS unter Verwendung von TMUX.        											 *
#   * Die Programme und Konfigfiles muessen unter /home/pi/dxlAPRS/aprs zu finden sein - wenn anders bitte entsprechend die Pfade aendern            *
#   *********************************************************************************************************************** OE3JTB  2020-03-21 * V1.0*

#------------------------------------------------------------------------------------------------------------------------------------------------------
# Als erstes beenden wir vorsorgend alle Programme die wir vielleicht schon gestartet haben (sonden tools)
#------------------------------------------------------------------------------------------------------------------------------------------------------
# 
#

#killall -9 getalmd rtl_tcp sondeudp sdrtst sondemod udpgate4 udpbox dxlAPRS-SHUE sendmail encrypted-tg-notifier
#tmux kill-server 
sleep 25
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Definieren wir das Sondenverzeichnis
#------------------------------------------------------------------------------------------------------------------------------------------------------

PATH=/home/pi/dxlAPRS/aprs/:$PATH


#tmux session starten
tmux new -d -s sonde



echo "$(tput setaf 3)getalmd starten..."
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Holen wir uns den aktuellen Almanach 
#------------------------------------------------------------------------------------------------------------------------------------------------------
#tmux GETALMD window erstellen
tmux select-pane -t 0
tmux new-window -t sonde -n GETALMD
#tmux pane starten
tmux split-window -v
tmux select-pane -t 0

tmux send-keys "$HOME/dxlAPRS/aprs/./getalm " C-m
tmux select-pane -t 1

tmux send-keys "$HOME/dxlAPRS/aprs/./getalmd " C-m

echo "$(tput setaf 1)gestartet"
echo
sleep 3

echo "$(tput setaf 3)rx server starten..."
#tmux RX window erstellen
tmux new-window -t sonde -n RX
#tmux panes erstellen und starten
tmux split-window -v
tmux split-window -v

tmux select-pane -t 0
tmux send-keys "rtl_tcp -a 127.0.0.1 -d0  -n 1 -p 18100 " C-m
tmux select-pane -t 1
tmux send-keys "rtl_tcp -a 127.0.0.1 -d2  -n 1 -p 18101 " C-m
tmux select-pane -t 2
tmux send-keys "rtl_tcp -a 127.0.0.1 -d3  -n 1 -p 18102 " C-m
echo "$(tput setaf 1)gestartet"
echo
sleep 3
#tmux SondeUDP window erstellen
tmux new-window -t sonde -n SONDEUDP
#tmux panes erstellen und starten
tmux split-window -v
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "$HOME/dxlAPRS/aprs/./sondeudp -f 25000 -o /home/pi/dxlAPRS/aprs/pipe0 -L omni -I OE3JTB-11 -u 127.0.0.1:18000 -S 5 -c 0 -v -n 0 -M 127.0.0.1:18500" C-m
tmux select-pane -t 1
tmux send-keys "$HOME/dxlAPRS/aprs/./sondeudp -f 25000 -o /home/pi/dxlAPRS/aprs/pipe1 -L omni -I OE3JTB-11 -u 127.0.0.1:18000 -S 5 -c 0 -v -n 0 -M 127.0.0.1:18501" C-m
tmux select-pane -t 2
tmux send-keys "$HOME/dxlAPRS/aprs/./sondeudp -f 25000 -o /home/pi/dxlAPRS/aprs/pipe2 -L omni -I OE3JTB-11 -u 127.0.0.1:18000 -S 5 -c 0 -v -n 0 -M 127.0.0.1:18502" C-m
echo
sleep 3



#tmux SDRTST window erstellen
tmux new-window -t sonde -n SDRTST
#tmux panes erstellen und starten
tmux split-window -v
tmux split-window -v
tmux select-pane -t 0
tmux send-keys "$HOME/dxlAPRS/aprs/./sdrtst -t 127.0.0.1:18100 -r 25000 -s /home/pi/dxlAPRS/aprs/pipe0 -Z 100 -c /home/pi/dxlAPRS/sdrcfg-400402.txt -v -e -k -L 127.0.0.1:18500" C-m
tmux select-pane -t 1
tmux send-keys "$HOME/dxlAPRS/aprs/./sdrtst -t 127.0.0.1:18101 -r 25000 -s /home/pi/dxlAPRS/aprs/pipe1 -Z 100 -c /home/pi/dxlAPRS/sdrcfg-402404.txt -v -e -k -L 127.0.0.1:18501" C-m
tmux select-pane -t 2
tmux send-keys "$HOME/dxlAPRS/aprs/./sdrtst -t 127.0.0.1:18102 -r 25000 -s /home/pi/dxlAPRS/aprs/pipe2 -Z 100 -c /home/pi/dxlAPRS/sdrcfg-404406.txt -v -e -k -L 127.0.0.1:18502" C-m
echo
sleep 3


#tmux MODBOX window erstellen
tmux new-window -t sonde -n MODBOX
#tmux panes erstellen und starten
tmux split-window -v

tmux select-pane -t 0
tmux send-keys "$HOME/dxlAPRS/aprs/./sondemod -o 18000 -I OE3JTB-11 -J 127.0.0.1:18010 -r 127.0.0.1:9001  -b 29:19:9:2 -M -A 3000:2000:1500 -X /$HOME/dxlAPRS/aprs/logs/encrypt.txt -x /tmp/e.txt -T 360 -R 240 -d -p 2 -L 6=DFM06,7=PS-15,9=PS-15,A=DFM09,B=DFM17,C=DFM09P,D=DFM17,FF=DFMx -t /home/pi/dxlAPRS/aprs/sondecom.txt -v -N 1313 -P JN77TX33FG -S /home/pi" C-m
tmux select-pane -t 1
tmux send-keys "$HOME/dxlAPRS/aprs/./udpbox -R 127.0.0.1:9001 -r 127.0.0.1:9101 -r 127.0.0.1:9102 -r 127.0.0.1:9105 -l 127.0.0.1:18001 -v" C-m
echo
sleep 3


#------------------------------------------------------------------------------------------------------------------------------------------------------
# UDPGATE4 - in aprs-is format wandeln, zugleich server zum Verteilen der Daten - oder an einen vorhandenen igate senden der axudp kann (-R <ip:port> ...), 
# oder an APRSMAP an einen "RF Port" --> M <ip:port> ..., -t=lokaler TCP port (14580) des igate fuer incomming connections, -p=dein aprs.fi passwort
# 
# entsprechende Zeile das # Zeichen entfernen und die anderen 2 mit # vorstellen! nur 1 Auswahl ist gültig!!!
#------------------------------------------------------------------------------------------------------------------------------------------------------
# Sondendaten to Radiosondy.info and forward to APRS Network Server (Port 14580)
# xfce4-terminal --title UDPGATE4 -e 'bash -c "udpgate4 -s OE3JTB-15 -R 0.0.0.0:0:9001 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g radiosondy.info:14580 -p 23471 -t 14580 -w 14501 -v -D /home/pi/dxlAPRS/aprs/www/"'

#tmux UPGATE window erstellen
tmux new-window -t sonde -n UPGATE
#tmux panes erstellen und starten
tmux split-window -v
tmux split-window -v
tmux split-window -v
tmux split-window -v


# Sondendaten to Radiosondy.info and forward to APRS Network Server (Port 14580)
#tmux select-pane -t 0
#tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4 -s OE3JTB-15 -R 0.0.0.0:0:9001 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g radiosondy.info:14580 -p 23471 -t 14580 -w 14501 -v -D /home/pi/dxlAPRS/aprs/www/" C-m

# Sondendaten to Radiosondy.info only!!! NOT forwarding to APRS Network Server (Port 14590)
tmux select-pane -t 0
tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4 -f m/100  -s OE3JTB-15 -R 0.0.0.0:0:9101 -B 1440  -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g radiosondy.info:14580 -p 23471  -H 1440 -I 30 -t 14590 -w 14501 -v -D /home/pi/dxlAPRS/aprs/www/" C-m

# Sondendaten zu APRS Network Server only!!!
tmux select-pane -t 1
#tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4  -f b/CHRIS2-* -s OE3JTB-15 -R 0.0.0.0:0:9102 -B 1440 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g postler.mooo.com:14580 -p 23471  -H 1440 -I 30 -t 14580 -w 14502 -v -D /home/pi/dxlAPRS/aprs/www/" C-m
tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4  -f b/CHRIS2-* -s OE3JTB-15 -R 0.0.0.0:0:9102 -B 1440 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g wettersonde.net:14580 -p 23471 -l 1:/tmp/aprs.log   -H 1440 -I 30 -t 14580 -w 14502 -v -D /home/pi/dxlAPRS/aprs/www/" C-m

# Sondendaten zu APRSMAP only!!!
tmux select-pane -t 4
##tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4 -s OE3JTB-15 -R 0.0.0.0:0:9105 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -M 127.0.0.1:9106 -w 14505 -v -D /home/pi/dxlAPRS/aprs/www/" C-m
#tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4  -s OE3JTB-15 -R 0.0.0.0:0:9102 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g wettersonde.net:14580 -p 23471 -l 1:/tmp/aprs.log   -t 14580 -w 14503 -v -D /home/pi/dxlAPRS/aprs/www/" C-m

# Sondendaten zu Sondehub
tmux select-pane -t 2
#tmux send-keys "$HOME/dxlAPRS/aprs/./udpgate4  -f b/CHRIS2-* -s OE3JTB-15 -R 0.0.0.0:0:9102 -B 1440 -n 10:/home/pi/dxlAPRS/aprs/netbeacon.txt -g austria.aprs2.net:14580 -p 23471  -H 1440 -I 30 -t 14580 -w 14502 -v -D /home/pi/dxlAPRS/aprs/www/" C-m
tmux send-keys "python3 $HOME/dxlAPRS-SHUE/dxlAPRS-SHUE.py -i 3 -j 3 -t 0 -a 127.0.0.1 -p 18010 -s 0 -d /home/pi/dxlAPRS-SHUE/log -w 0 -z 0 -k 1 -q 20 -f 600 -c OE3JTB -l 47.97181796000214,15.610408766219116,1313 -v "Diamond X50" -u OE3JTB@gmail.com -g 6 -r 15 -o 20 -e 5" C-m

# Verschluesselte Sondendaten per Telegram abschicken
tmux select-pane -t 3
tmux send-keys "python3 $HOME/encrypted_telegram_notifier.py" C-m


echo
sleep 3


#------------------------------------------------------------------------------------------------------------------------------------------------------
# Wasserfalldisplay für jeden Stick
#------------------------------------------------------------------------------------------------------------------------------------------------------


#tmux Waterfall window erstellen
tmux new-window -t sonde -n WATERFALL
#tmux panes erstellen und starten
tmux split-window -v
tmux split-window -v


# Waterfall Stick 0
tmux select-pane -t 0
tmux send-keys "python3 $HOME/waterfall0.py -n 50" C-m

# Waterfall Stick 1
tmux select-pane -t 1
tmux send-keys "python3 $HOME/waterfall1.py -n 50" C-m

# Waterfall Stick 2
tmux select-pane -t 2
tmux send-keys "python3 $HOME/waterfall2.py -n 50" C-m


echo
sleep 30
gpicview /tmp/w0.png &
#--- ENDE ---------------------------------------------------------------------------------------------------------------------------------------------------








