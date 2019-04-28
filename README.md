# veebiringhaaling
Vabavaraline ringhääling veebis. Hetkel saab skriptidega paigaldada veebiraadiot. Kasutajal palutakse sisestada vaid hädavajalik info. Muu protsess on automatiseeritud.

## Veidi labane juhend
```bash
sudo -i
git clone https://github.com/hpaves/veebiringhaaling.git             
cd veebiringhaaling
bash paigalda_raadio.sh
```

Järgi ekraanile tekkivaid juhiseid.

sudo puudumisel kasutad ilmselt Debiani. Selle asendamiseks:
```bash
su
apt update && apt install git -y
```
