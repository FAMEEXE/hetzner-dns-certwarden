# Certbot Hetzner DNS Scripts

Diese Scripts ermöglichen die automatische Erneuerung von Let's Encrypt SSL-Zertifikaten über die Hetzner Cloud DNS API mit der DNS-Challenge-Methode.

## 📋 Überblick

Die Scripts bestehen aus zwei Hauptkomponenten:

- **`certbot-hetzner-auth-v2.sh`** - Erstellt DNS TXT-Records für die ACME-Challenge
- **`certbot-hetzner-cleanup-v2.sh`** - Entfernt die temporären DNS-Records nach erfolgreicher Validierung

## 🚀 Funktionsweise

### Authentication Script (`certbot-hetzner-auth-v2.sh`)
1. Empfängt Domain und Validation-Token von Certbot
2. Ermittelt die entsprechende DNS-Zone über die Hetzner Cloud API
3. Erstellt einen TXT-Record für `_acme-challenge.<domain>` 
4. Wartet 30 Sekunden auf DNS-Propagation

### Cleanup Script (`certbot-hetzner-cleanup-v2.sh`)
1. Ermittelt die DNS-Zone für die Domain
2. Entfernt den temporären `_acme-challenge` TXT-Record

## 📦 Voraussetzungen

- **Bash** (Linux/macOS/WSL)
- **curl** - Für API-Aufrufe
- **Certbot** - Let's Encrypt Client
- **Hetzner Cloud Account** mit DNS-Verwaltung
- **Hetzner Cloud API Token** mit DNS-Berechtigung

## ⚙️ Installation

### 1. Scripts herunterladen
```bash
# Scripts herunterladen
wget https://raw.githubusercontent.com/FAMEEXE/hetzner-dns-certwarden/main/certbot-hetzner-auth-v2.sh
wget https://raw.githubusercontent.com/FAMEEXE/hetzner-dns-certwarden/main/certbot-hetzner-cleanup-v2.sh

# Ausführberechtigung setzen
chmod +x certbot-hetzner-auth-v2.sh
chmod +x certbot-hetzner-cleanup-v2.sh
```

### 2. API Token konfigurieren
```bash
# Hetzner Cloud API Token als Umgebungsvariable setzen
export HETZNER_TOKEN="your-hetzner-api-token-here"

# Dauerhaft in ~/.bashrc oder ~/.zshrc speichern
echo 'export HETZNER_TOKEN="your-hetzner-api-token-here"' >> ~/.bashrc
```

### 3. Scripts verschieben
```bash
# Scripts in ein Verzeichnis im PATH verschieben (optional)
sudo mv certbot-hetzner-*.sh /usr/local/bin/
```

## 🔧 Verwendung

### Manueller Zertifikatsabruf
```bash
certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --manual-auth-hook /path/to/certbot-hetzner-auth-v2.sh \
  --manual-cleanup-hook /path/to/certbot-hetzner-cleanup-v2.sh \
  -d example.com \
  -d *.example.com
```

### Automatische Erneuerung einrichten
```bash
# Cron-Job für automatische Erneuerung (täglich um 2:30 Uhr)
echo "30 2 * * * /usr/bin/certbot renew --quiet --manual-auth-hook /usr/local/bin/certbot-hetzner-auth-v2.sh --manual-cleanup-hook /usr/local/bin/certbot-hetzner-cleanup-v2.sh" | crontab -
```

### Systemd Timer (Alternative zu Cron)
```bash
# Service-Datei erstellen
sudo tee /etc/systemd/system/certbot-renewal.service > /dev/null <<EOF
[Unit]
Description=Certbot Renewal
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
Environment=HETZNER_TOKEN=your-token-here
ExecStart=/usr/bin/certbot renew --quiet --manual-auth-hook /usr/local/bin/certbot-hetzner-auth-v2.sh --manual-cleanup-hook /usr/local/bin/certbot-hetzner-cleanup-v2.sh
EOF

# Timer-Datei erstellen
sudo tee /etc/systemd/system/certbot-renewal.timer > /dev/null <<EOF
[Unit]
Description=Run certbot renewal daily
Requires=certbot-renewal.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Timer aktivieren
sudo systemctl enable --now certbot-renewal.timer
```

## 🛠️ Konfiguration

### API Token erstellen
1. Bei Hetzner Cloud einloggen: https://console.hetzner.cloud/
2. Zu "Security" → "API Tokens" navigieren
3. Neuen Token erstellen mit **DNS-Berechtigung**
4. Token sicher speichern

### DNS-Zone einrichten
- Stelle sicher, dass deine Domain in Hetzner Cloud DNS verwaltet wird
- Die Zone muss bereits existieren (wird nicht automatisch erstellt)

## 🔍 Debugging

### Verbose-Modus aktivieren
```bash
# Debug-Ausgabe aktivieren
set -x

# Scripts mit Debug-Informationen ausführen
bash -x certbot-hetzner-auth-v2.sh example.com validation_string
```

### Häufige Probleme
- **"Zone not found"**: Domain nicht in Hetzner Cloud DNS konfiguriert
- **"Unauthorized"**: API Token ungültig oder ohne DNS-Berechtigung
- **"Rate limit"**: Zu viele API-Aufrufe, kurz warten

### Log-Dateien prüfen
```bash
# Certbot Logs
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# System Logs
journalctl -u certbot-renewal.service -f
```

## 📋 Beispiel-Workflow

```bash
# 1. Domain bei Hetzner Cloud DNS hinzufügen
# 2. API Token erstellen und setzen
export HETZNER_TOKEN="your-token"

# 3. Zertifikat abrufen
certbot certonly \
  --manual \
  --preferred-challenges=dns \
  --manual-auth-hook ./certbot-hetzner-auth-v2.sh \
  --manual-cleanup-hook ./certbot-hetzner-cleanup-v2.sh \
  -d example.com

# 4. Zertifikat testen
certbot certificates

# 5. Automatische Erneuerung testen
certbot renew --dry-run \
  --manual-auth-hook ./certbot-hetzner-auth-v2.sh \
  --manual-cleanup-hook ./certbot-hetzner-cleanup-v2.sh
```

## 🔒 Sicherheitshinweise

- **API Token sicher aufbewahren** - Niemals in öffentlichen Repositories speichern
- **Minimale Berechtigungen** - Token nur mit DNS-Berechtigung erstellen
- **Token-Rotation** - Regelmäßig neue Tokens erstellen
- **Backup** - Zertifikate und Keys sichern

## 🤝 Beitragen

1. Fork des Repositories erstellen
2. Feature Branch erstellen (`git checkout -b feature/amazing-feature`)
3. Änderungen committen (`git commit -m 'Add amazing feature'`)
4. Branch pushen (`git push origin feature/amazing-feature`)
5. Pull Request erstellen

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE) für Details.

## 🆘 Support

Bei Problemen:
1. [Issues](../../issues) im Repository erstellen
2. Hetzner Cloud Dokumentation: https://docs.hetzner.cloud/
3. Let's Encrypt Dokumentation: https://letsencrypt.org/docs/

---

**⚠️ Hinweis**: Diese Scripts verwenden die Hetzner Cloud API v1. Stelle sicher, dass dein Account entsprechend konfiguriert ist.
