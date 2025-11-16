# 🤖 Integracja iRobot z Home Assistant

Aby uzyskać hasło i BLID do iRobot użyj tego komendu 🚀:

```bash
docker run -it --rm node:22-alpine sh -c "
  npm install -g dorita980 && \
  get-roomba-password-cloud 'TWOJ_EMAIL_DO_IROBOT' 'TWOJE_HASLO_DO_IROBOT'"
```

Uzyskasz BLID i hasło do iRobot w formacie: 📱

```
Found 1 robot(s)!
Robot "j7+" (sku: ... SoftwareVer: ...):
BLID=> 37F4B1B9C55F4A89908383816D26492E
Password=> :1:1681234567:AbCdEfGhIjKlMnOp <= całe to jest hasło
```

**⚠️ UWAGA:** Cała linia po `Password=>` to hasło!

I użyj integracji irobot w Home Assistant 🏠

<p><a href="https://my.home-assistant.io/redirect/config_flow_start?domain=roomba" class="my badge" target="_blank"><img src="https://my.home-assistant.io/badges/config_flow_start.svg"></a></p>
