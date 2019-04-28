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

Järgi ekraanile tekkivaid juhiseid.

Debiani juhend, kui tavakasutaja nimi on dj:
```bash
su
cd
apt update && apt install git -y
git clone https://github.com/hpaves/veebiringhaaling.git             
cd veebiringhaaling
bash paigalda_raadio.sh dj
```
