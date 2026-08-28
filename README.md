# VPS VPN Run

VPN **bajo demanda** de ProtonVPN que se aplica **solo a los procesos de `vpn.slice`**
(Freebuff, OpenCode) mientras que **todo el resto del VPS — tus webs, APIs, MySQL, SSH —
sale SIEMPRE por tu IP física, sin tocarlo nunca.**

Nada se instala ni se activa automáticamente: controlas la VPN tú cuando quieras.

---

## ✨ Características

- **Routing selectivo por cgroup**: únicamente los procesos de `vpn.slice` salen por el túnel.
- **Nunca rompe tus servicios**: Apache/MySQL/SSH y todo lo que se inicia en el VPS queda por tu IP física.
- **Portátil**: detecta la interfaz de red (`ens3`, `eth0`, `enp0s3`…) y el gateway automáticamente.
- **Sin auto-arranque**: el túnel solo se levanta cuando tú lo pides (`vpn-on` o el menú).
- **Varios países e IPs**: Países Bajos, EE.UU., Japón (ampliable) o IP manual.
- **Seguridad**: marca el tráfico por política + rp_filter en modo *loose* para que el túnel responda bien.

---

## 📦 Contenido

```
install-protonvpn.sh          ← Instalador TODO-en-uno (idempotente)
scripts/
  vpn-menu                    ← Menú interactivo
  vpn-on                      ← Encender VPN (acepta país: nl|us|jp|custom)
  vpn-off                     ← Apagar VPN
  vpn-run                     ← Ejecutar un comando saliendo por la VPN
etc/systemd/system/vpn.slice          ← Grupo cgroup de los procesos que usan VPN
etc/sysctl.d/99-vpn-policy-routing.conf ← rp_filter loose (necesario para el túnel)
```

---

## 🚀 Instalación

El instalador se encarga de **todo**: instala OpenVPN si no existe, escribe las configs
NL/US/JP, las **credenciales y certificados ProtonVPN embebidos**, los 4 scripts,
el slice y el sysctl. **No toca tus apps/webs/SSH** y **no activa la VPN**.

```bash
# 1) Copiar el instalador al VPS (desde tu PC)
scp install-protonvpn.sh usuario@IP-DEL-VPS:~/

# 2) Ejecutar como root (instala OpenVPN si falta)
sudo bash install-protonvpn.sh
```

> El script es **idempotente**: puedes ejecutarlo varias veces y no falla ni duplica nada.

### Lo que hace el instalador, paso a paso
1. **Instala OpenVPN** vía `apt-get` si no está presente (y solo informa si ya lo está).
2. Crea `/etc/openvpn/client/` y escribe `protonvpn-nl.conf`, `protonvpn-us.conf`, `protonvpn-jp.conf`
   (con las credenciales / certificados embebidos y `auth.txt` con permisos `600`).
3. Instala los scripts `vpn-menu`, `vpn-on`, `vpn-off`, `vpn-run` en `/usr/local/sbin/`.
4. Instala el slice `vpn.slice` y el sysctl `99-vpn-policy-routing.conf`.
5. **Deshabilita el auto-arranque** de OpenVPN (bajo demanda).

---

## 🖥️ Uso

### Menú interactivo (recomendado)
```bash
sudo vpn-menu
```

| Opción | Qué hace |
|---|---|
| **1** | Verificar / instalar OpenVPN |
| **2** | Configuración de ProtonVPN (ver/editar credenciales, ruta del certificado, copiar un `.ovpn`) |
| **3** | Encender VPN — elige país e IP (o IP manual) |
| **4** | Apagar VPN |
| **5** | Ejecutar un comando por la VPN |
| **6** | Salir |

### Comandos directos
```bash
sudo vpn-on          # Encender (Países Bajos por defecto)
sudo vpn-on us       # Encender EE.UU.
sudo vpn-on jp       # Encender Japón
sudo vpn-on ca       # Otro país (si creas su config: protonvpn-ca.conf)
sudo vpn-off         # Apagar y restaurar IP física

sudo vpn-run <cmd>        # Un comando saliendo por la VPN
sudo vpn-run opencode     # Abrir OpenCode por la VPN
sudo vpn-run curl -s https://api.ipify.org   # Comprobar salida (IP de la VPN)
```

### Comprobar que funciona
```bash
# IP de salida de los procesos en vpn.slice (debe ser la IP de la VPN, p.ej. EE.UU.)
sudo vpn-run curl -s https://api.ipify.org

# IP física del resto del sistema (debe seguir siendo la IP real del VPS)
curl -s https://api.ipify.org
```

---

## 🧠 Cómo funciona (resumen técnico)

1. `vpn-on <pais>` levanta el túnel OpenVPN contra el servidor Proton elegido
   (config en `/etc/openvpn/client/protonvpn-<pais>.conf`).
2. Se crea una **tabla de enrutamiento 200** con la ruta por defecto hacia `tun0`.
3. Se añade una regla de policy-routing que envía a esa tabla **solo los paquetes
   marcados** (`fwmark 0x1`) provenientes de procesos en `vpn.slice`.
4. `vpn-run` ejecuta el comando tras mover el proceso a `vpn.slice` → su tráfico
   sale por la VPN.
5. Un **SNAT** en POSTROUTING reescribe la IP de origen a la IP del túnel para que
   Proton no descarte los paquetes (anti-spoofing).
6. El resto del sistema (sin marca) sale por la tabla principal → IP física siempre.

`vpn-off` limpia marcas, reglas, la regla de policy-routing, el SNAT y detiene el túnel.

---

## 📌 Notas importantes

- **Si en el VPS no hay Freebuff/OpenCode corriendo**, `vpn-on` levanta el túnel igual
  pero sin procesos en `vpn.slice` **no sale nada por la VPN** (todo por IP física).
  Para enrutar una app concreta: `sudo vpn-run <app>` o muévela al slice.

- **Añadir un país nuevo**: copia una config base y ponle `remote <IP> <puerto>`
  con un servidor Proton; luego `sudo vpn-on <pais>`.
  El menú (opción 3) también permite elegir una **IP manual**.

- **Después de reiniciar el VPS**, el túnel estará caído (bajo demanda). Vuelve a
  encenderlo cuando quieras: `sudo vpn-on <pais>`.

- **Seguridad**: el instalador lleva tus credenciales y certificados de ProtonVPN
  embebidos. Mantén este repositorio **privado** y no lo compartas.

---

## 🐛 Solución de problemas

| Síntoma | Causa | Solución |
|---|---|---|
| `vpn-run curl` devuelve vacío o `?` | El `curl` de verificación puede haber caído en rate-limit (campo de país) | Espera unos segundos y reintenta; la IP es lo que importa |
| El túnel no levanta al cambiar de país | `tun0` huérfano de una sesión anterior | Ya se limpia automáticamente; si persiste: `sudo vpn-off` y luego `vpn-on <pais>` |
| Una app no sale por la VPN | El proceso no está en `vpn.slice` | `sudo vpn-run <app>` o muévela al slice |
| `No se pudo conectar` para un país | El servidor elegido cambió de IP | Elige otra IP en el menú (opción 3) o edita el `remote` de la config |

---

## 🤝 Contribuciones

Si quieres añadir más países, configs o banderas (p. ej. `--mssfix`, DNS propio), el
punto más simple es editar `vpn-on` y las configs que escribe el instalador.
¡PRs bienvenidos!