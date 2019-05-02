# Vabavaraline ringhääling veebis
Hetkel saab skriptidega paigaldada veebiraadiot. Kasutajal palutakse sisestada vaid hädavajalik info. Muu protsess on automatiseeritud.

## Mis on protsessi tulemuseks?
Olles teinud läbi paigalduse, on sul olemas kõik vajalik omanenda veebiraadio tegevusega alustamiseks.

## Mida mul vaja on?
Sisuliselt on selleks vaja serveri riistvara, USB helikaarti koos mikrofonidega ja juhtmega internetiühendust.

Võimalik, et vaja läheb ka mõne arvutitega kodus oleva inimese abi. Seda eriti juhul, kui tahate raadiot kasutusele võtta kohas kus on keerulisem sisevõrk, või kui tahate raadio otse internetist (mitte vaid sisevõrgust) kuulatavaks teha.

## Ettevalmistused
Esiteks tuleks välja mõelda mis saab olema teie raadio nimi. Seda küsitakse tarkvara paigaldamise käigus.

Vaikimisi on raadio nimeks *"Meie oma raadio"*, ning välja saab sealt vahetada fraasi *Meie oma*. Sõna *raadio* vaikimisi välja vahetada ei saa. Erinimevajadustega kasutajatel on raadio nime pärast paigaldust lihtne HTML'is muuta.

Kohalikku arvutispetsialisti võiks pärast raadioteemalist vestlust kostitada järgmiste küsimustega:
- *"Kuidas saada raadioruumi juhtmega võrguühendus?"*
- *"Vajalik on üles seada staatiline IP. Millises vahemikus ma seda teha võin?"*
- *"Kas meie kohalikus võrgus on VLANid või muud piirangud? Seade peaks olema võimalikult paljudele kättesaadav."*
- *"Internetist kuulamiseks oleks vaja suunata suvaline väline port enne mainitud IP port 80 peale."*
- *"Kas sa aitaksid mind selle kõigega?"*

## Uppusin praegu tehnilistesse mõistetesse!
Ei maksa lasta end hirmutada. Ülejäänud juhend põhineb Raspberry Pi'l mis on mõeldud vanusele alates 8. eluaastast. Kui see on tööle saadud, läheb veebiringhäälingu püsti panekuks (sõltuvalt interneti kiirusest) umbes veerand tundi. Lisaks siis vajadusel kohaliku arvutispetsialisti lisaseadistused.

## Soovitatav riistvara
- Raspberry Pi 3
- Vähemalt 32GB class 10 microSD kaart
- microSD kaardi lugeja
- Kuvar, klaviatuur, hiir
- USB helikaart (vähemalt kaks eraldi valjususe reguleerimisega sisendit)
- Mikrofon(id)
- Helifailide taaesitamise seade (arvuti, nutifon)

Korraks on vaja ka ligipääsu Linux, macOS või Windows arvutile, et vormindada microSD kaart ning laadida sellele Raspbian operatsioonisüsteem. Luba arvutisse tarkvara paigaldada teeb protsessi lihtsamaks, aga see pole ilmtingimata vajalik.

MicroSD kaardi mahu valikul peaks võtma arvesse kui palju on omaloodud saateid salvestada. 

## Kas kindlasti just need seadmed?
Katsetamiseks sobib ka Raspberry Pi komplektiga kaasa tulnud 8GB NOOBS kaart, kuid sellel saab ruum kohe otsa. Helikaardi asendamiseks sobib ka mikserpult (koolis ilmselt olemas, kogub tõenäoliselt ürituse vahelisel ajal tolmu). Pult annab rohkem võimalusi, kuid pole soovitatavate seadmete nimekirjas peamiselt hinna tõttu. Tegelikult võib raadio isegi paigaldada mõnda (vanemasse) arvutisse. Virtuaalmasinasse on samuti võimalik paigaldada, kuid sel juhul on mikrofonide ühendamine keerulisem. Tavaarvutis on soovitatav Raspbiani asemel kasutada operatsioonisüsteemi Debian.

# Riistvara paigaldusjuhend
- Komplekteeri Raspberry Pi
- Ühenda kuvar, klaviatuur, hiir
- Pane microSD kaart lugejasse ning ühenda see arvutiga

## Kui sul on luba tarkvara paigaldada
- Paigalda programmid [Etcher](https://www.balena.io/etcher/) ja [QuickHash GUI](https://quickhash-gui.org/downloads/)
- Tõmba alla [Raspbian with Desktop](https://www.raspberrypi.org/downloads/raspbian/)
- Ava QuickHash GUI veendumaks, et tõmmatud Raspbian on terviklik 
  - Vali alamenüü *File*
  - Kleebi välja *Excpected Hash Value* Raspbiani allalaadimiste lehelt saadud SHA-256 räsi
  - Vali *Select File* abil Raspbiani fail
  - Kui saad teate, et räsid klappisid, oled veendunud tõmmatud faili tervikluses
- Ava Etcher, et vormindada microSD kaart
  - Vali tõmmatud Raspbiani fail
  - Vali sisestatud SD kaart
  - Vajuta *Flash!*
- Kui kõik valmis, eemalda microSD kaart lugejast ja sisesta Pi'sse.

## Kui sul pole luba tarkvara paigaldada
- Tõmba alla [NOOBS](https://www.raspberrypi.org/downloads/noobs/)
- jne

# Tarkvara paigaldusjuhised
Raspberry Pi puhul trüki terminali:
```bash
sudo -i
git clone https://github.com/hpaves/veebiringhaaling.git
cd veebiringhaaling
bash paigalda_raadio.sh pi
```

Debiani juhend, kui tavakasutaja nimi on dj:
```bash
su
cd
apt update && apt install git -y
git clone https://github.com/hpaves/veebiringhaaling.git
cd veebiringhaaling
bash paigalda_raadio.sh dj
```
## Paigalduse käigus tehtavad valikud.
Paigaldusskript annab kasutajale mitmeid valikuid. Kõik tehtavad valikud on olulised, kuid siinkohal on toodud välja mõned, millele tuleks pöörata erilist tähelepanu.

Icecast2 on vaja seadistada. Siin tuleb valida "jah", sest muidu läheb paigaldusega tõenäoliselt kauem kui lubatud veerand tundi.

![Icecast2 on vaja seadistada.](pildid/icecast_config_1.png)

Vaikimisi pakutud nimi `localhost` sobib.

![Vaikimisi pakutud `localhost` nimi sobib.](pildid/icecast_config_2.png)

Vaikimisi pakutud paroolid tuleb kindlasti muuta!

![Vaikimisi pakutud paroolid tuleb kindlasti muuta!](pildid/icecast_config_3.png)

Järgi ekraanile tekkivaid edasisi juhiseid.

### Olen erinimevajadusega
Trüki terminali:
```bash
sudo -i
gedit /var/www/html/index.php
```
Raadio nimi on kahel eraldi real. Seda pole raske leida ja muuta.
Ära üleliigset kustuta. Siis võib taas minna kauem kui veerand tundi.

# Raadio võrgutamine
Olles arvuti taaskäivitanud, on see nüüd kohalikus võrgus (näiteks koolimaja wifis) kuulatav.



## Kasutatud materjalid
### [HackerThemes theme-machine](https://github.com/HackerThemes/theme-machine)
Kasutajate veebiliidese kujundus.

### [henry7720 Verification-Page](https://github.com/henry7720/Verification-Page)
Turvab vajadusel kasutajate veebiliidest parooliga.
