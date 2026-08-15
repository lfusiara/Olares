# Olares toolbox

Niewielkie narzędzia administracyjne dla Olares OS i sklepowej aplikacji
Codex CLI. Skrypty nie zawierają sekretów ani ustawień konkretnego domu.

## Instalacja na hoście Olares

```bash
git clone https://github.com/lfusiara/Olares.git ~/Olares
cd ~/Olares
./install.sh
export PATH="$HOME/.local/bin:$PATH"
```

Polecenia wymagają `kubectl` skonfigurowanego do lokalnego klastra Olares.
Uruchamiaj je na hoście Olares/Control Hub, nie wewnątrz aplikacji Codex CLI.

## Wybór instancji Codex CLI

```bash
olares-codex-list
```

Każde polecenie przy jednym wyniku wybiera go automatycznie. Przy kilku
instancjach pokazuje menu. W skryptach i automatyzacji użyj jawnie:

```bash
--namespace NAMESPACE --deployment DEPLOYMENT
```

## Home Assistant: port-forward w tle

Interaktywny wybór instancji:

```bash
olares-ha-port-forward start
```

Jawny cel i porty:

```bash
olares-ha-port-forward start \
  --namespace NAMESPACE \
  --deployment DEPLOYMENT \
  8123:8123 1883:1883 8100:8100
```

Obsługa:

```bash
olares-ha-port-forward status
olares-ha-port-forward logs
olares-ha-port-forward stop
```

Worker działa przez `nohup`, nie blokuje konsoli i ponawia połączenie po
błędzie. Wiąże porty do `0.0.0.0`; ogranicz je firewallem do zaufanego LAN lub
VPN. `kubectl port-forward` obsługuje tylko TCP.

## USB hosta w Docker-in-Docker Codex CLI

Najpierw podłącz urządzenie do hosta Olares i sprawdź je:

```bash
ls -l /dev/ttyACM* /dev/ttyUSB* 2>/dev/null
ls -l /dev/serial/by-id/
```

Sprawdź bieżącą konfigurację wybranej instancji:

```bash
olares-codex-usb status
```

Zastosuj montowanie urządzenia i stabilnych nazw do `docker-dind`:

```bash
olares-codex-usb apply \
  --namespace NAMESPACE \
  --deployment DEPLOYMENT \
  --device /dev/ttyACM0
```

Operacja pokazuje plan, wymaga potwierdzenia i odtwarza pod Codex CLI. Do
świadomie zatwierdzonej automatyzacji można dodać `--yes`.

W terminalu Codex CLI sprawdź następnie:

```bash
docker run --rm \
  --mount type=bind,src=/dev/serial/by-id,dst=/dev/serial/by-id,readonly \
  alpine:3.22 ls -l /dev/serial/by-id
```

Repozytorium [HA-Wall-Panel](https://github.com/lfusiara/HA-Wall-Panel)
zawiera `flash-olares.sh`, który po tej konfiguracji rozróżnia panele po
numerze seryjnym i wymaga osobnej zgody przed wgraniem firmware.

## Uwagi

- Aktualizacja/reinstalacja aplikacji Codex CLI może przywrócić jej oryginalny
  Deployment; wtedy konfigurację USB trzeba zastosować ponownie.
- Skrypt USB nie wykonuje flashowania, erase ani zmian eFuse.
- Przed `apply` skrypt wymaga istniejącego urządzenia znakowego oraz katalogu
  `/dev/serial/by-id`.
- `--yes` nie zastępuje świadomej decyzji o modyfikacji deploymentu.
