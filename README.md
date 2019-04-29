# veebiringhaaling
Vabavaraline ringhääling veebis. Hetkel saab skriptidega paigaldada veebiraadiot. Kasutajal palutakse sisestada vaid hädavajalik info. Muu protsess on automatiseeritud.

## Veidi labane juhend
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
## Detailsemad juhised

Icecast2 on vaja seadistada.

![Icecast2 on vaja seadistada.](pildid/icecast_config_1.png)

Vaikimisi pakutud nimi `localhost` sobib.

![Vaikimisi pakutud `localhost` nimi sobib.](pildid/icecast_config_2.png)

Vaikimisi pakutud paroolid tuleb kindlasti muuta!

![Vaikimisi pakutud paroolid tuleb kindlasti muuta!](pildid/icecast_config_3.png)

Järgi ekraanile tekkivaid edasisi juhiseid.