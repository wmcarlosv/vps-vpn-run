#!/bin/bash
# =====================================================================
# Instalador ProtonVPN (VPS VPN Run) — Freebuff/OpenCode por la VPN
#
# Instala TODO: OpenVPN (si falta), configs NL/US/JP, credenciales y
# certificados, los 4 scripts (vpn-on/off/run/menu), vpn.slice y sysctl.
# - Portatil: detecta interfaz de red y gateway automaticamente.
# - Idempotente: se puede ejecutar varias veces sin romper nada.
# - No activa la VPN ni la auto-arranca (bajo demanda).
# - No toca tus apps/webs/SSH (la VPN es exclusiva para vpn.slice).
# - vpn-run ejecuta en el directorio actual del llamador (recupera chats).
# - vpn-on fuerza IPv4 en el slice (OpenCode/Freebuff por el túnel IPv4).
# =====================================================================
set -e

echo "== VPS VPN Run — instalador =="
echo

# ---------------------------------------------------------------------
# 1) Instalar OpenVPN si no existe
# ---------------------------------------------------------------------
if ! command -v openvpn >/dev/null 2>&1; then
  echo "  Instalando openvpn..."
  apt-get update -qq && apt-get install -y openvpn
else
  echo "  openvpn ya instalado ($(openvpn --version 2>/dev/null | head -1))"
fi

# ---------------------------------------------------------------------
# 2) Configs de protonvpn (NL / US / JP) + credenciales
# ---------------------------------------------------------------------
mkdir -p /etc/openvpn/client

cat > /etc/openvpn/client/protonvpn-nl.conf <<'VPN_CONF_NL'
# ==============================================================================
# Copyright (c) 2023 Proton AG (Switzerland)
# Email: contact@protonvpn.com
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR # OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ==============================================================================

# The server you are connecting to is using a circuit in order to separate entry IP from exit IP
# The same entry IP allows to connect to multiple exit IPs in the same data center.

# If you want to explicitly select the exit IP corresponding to server NL-FREE#254 you need to
# append a special suffix to your OpenVPN username.
# Please use "EHwataJjAhXVtMi3+b:0" in order to enforce exiting through NL-FREE#254.

# If you are a paying user you can also enable the ProtonVPN ad blocker (NetShield) or Moderate NAT:
# Use: "EHwataJjAhXVtMi3+b:0+f1" to enable anti-malware filtering
# Use: "EHwataJjAhXVtMi3+b:0+f2" to additionally enable ad-blocking filtering
# Use: "EHwataJjAhXVtMi3+b:0+nr" to enable Moderate NAT
# Note that you can combine the "+nr" suffix with other suffixes.

client
dev tun
proto udp
remote 185.100.235.117 1194
remote 185.100.235.117 1194
remote 185.100.235.117 1194
remote-random


resolv-retry infinite
nobind
pull-filter ignore "redirect-gateway"
pull-filter ignore "dhcp-option DNS"
route-nopull

cipher AES-256-GCM

setenv CLIENT_CERT 0
tun-mtu 1500
mssfix 0
persist-key
persist-tun

reneg-sec 0

remote-cert-tls server
auth-user-pass /etc/openvpn/auth.txt

script-security 2

<ca>
-----BEGIN CERTIFICATE-----
MIIFnTCCA4WgAwIBAgIUCI574SM3Lyh47GyNl0WAOYrqb5QwDQYJKoZIhvcNAQEL
BQAwXjELMAkGA1UEBhMCQ0gxHzAdBgNVBAoMFlByb3RvbiBUZWNobm9sb2dpZXMg
QUcxEjAQBgNVBAsMCVByb3RvblZQTjEaMBgGA1UEAwwRUHJvdG9uVlBOIFJvb3Qg
Q0EwHhcNMTkxMDE3MDgwNjQxWhcNMzkxMDEyMDgwNjQxWjBeMQswCQYDVQQGEwJD
SDEfMB0GA1UECgwWUHJvdG9uIFRlY2hub2xvZ2llcyBBRzESMBAGA1UECwwJUHJv
dG9uVlBOMRowGAYDVQQDDBFQcm90b25WUE4gUm9vdCBDQTCCAiIwDQYJKoZIhvcN
AQEBBQADggIPADCCAgoCggIBAMkUT7zMUS5C+NjQ7YoGpVFlfbN9HFgG4JiKfHB8
QxnPPRgyTi0zVOAj1ImsRilauY8Ddm5dQtd8qcApoz6oCx5cFiiSQG2uyhS/59Zl
5wqIkw1o+CgwZgeWkq04lcrxhhfPgJZRFjrYVezy/Z2Ssd18s3/FFNQ+2iV1KC2K
z8eSPr50u+l9vEKsKiNGkJTdlWjoDKZM2C15i/h8Smi+PdJlx7WMTtYoVC1Fzq0r
aCPDQl18kspu11b6d8ECPWghKcDIIKuA0r0nGqF1GvH1AmbC/xUaNrKgz9AfioZL
MP/l22tVG3KKM1ku0eYHX7NzNHgkM2JKnBBannImQQBGTAcvvUlnfF3AHx4vzx7H
ahpBz8ebThx2uv+vzu8lCVEcKjQObGwLbAONJN2enug8hwSSZQv7tz7onDQWlYh0
El5fnkrEQGbukNnSyOqTwfobvBllIPzBqdO38eZFA0YTlH9plYjIjPjGl931lFAA
3G9t0x7nxAauLXN5QVp1yoF1tzXc5kN0SFAasM9VtVEOSMaGHLKhF+IMyVX8h5Iu
IRC8u5O672r7cHS+Dtx87LjxypqNhmbf1TWyLJSoh0qYhMr+BbO7+N6zKRIZPI5b
MXc8Be2pQwbSA4ZrDvSjFC9yDXmSuZTyVo6Bqi/KCUZeaXKof68oNxVYeGowNeQd
g/znAgMBAAGjUzBRMB0GA1UdDgQWBBR44WtTuEKCaPPUltYEHZoyhJo+4TAfBgNV
HSMEGDAWgBR44WtTuEKCaPPUltYEHZoyhJo+4TAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBCwUAA4ICAQBBmzCQlHxOJ6izys3TVpaze+rUkA9GejgsB2DZXIcm
4Lj/SNzQsPlZRu4S0IZV253dbE1DoWlHanw5lnXwx8iU82X7jdm/5uZOwj2NqSqT
bTn0WLAC6khEKKe5bPTf18UOcwN82Le3AnkwcNAaBO5/TzFQVgnVedXr2g6rmpp9
gdedeEl9acB7xqfYfkrmijqYMm+xeG2rXaanch3HjweMDuZdT/Ub5G6oir0Kowft
lA1ytjXRg+X+yWymTpF/zGLYfSodWWjMKhpzZtRJZ+9B0pWXUyY7SuCj5T5SMIAu
x3NQQ46wSbHRolIlwh7zD7kBgkyLe7ByLvGFKa2Vw4PuWjqYwrRbFjb2+EKAwPu6
VTWz/QQTU8oJewGFipw94Bi61zuaPvF1qZCHgYhVojRy6KcqncX2Hx9hjfVxspBZ
DrVH6uofCmd99GmVu+qizybWQTrPaubfc/a2jJIbXc2bRQjYj/qmjE3hTlmO3k7V
EP6i8CLhEl+dX75aZw9StkqjdpIApYwX6XNDqVuGzfeTXXclk4N4aDPwPFM/Yo/e
KnvlNlKbljWdMYkfx8r37aOHpchH34cv0Jb5Im+1H07ywnshXNfUhRazOpubJRHn
bjDuBwWS1/Vwp5AJ+QHsPXhJdl3qHc1szJZVJb3VyAWvG/bWApKfFuZX18tiI4N0
EA==
-----END CERTIFICATE-----
</ca>

<tls-crypt>
-----BEGIN OpenVPN Static key V1-----
6acef03f62675b4b1bbd03e53b187727
423cea742242106cb2916a8a4c829756
3d22c7e5cef430b1103c6f66eb1fc5b3
75a672f158e2e2e936c3faa48b035a6d
e17beaac23b5f03b10b868d53d03521d
8ba115059da777a60cbfd7b2c9c57472
78a15b8f6e68a3ef7fd583ec9f398c8b
d4735dab40cbd1e3c62a822e97489186
c30a0b48c7c38ea32ceb056d3fa5a710
e10ccc7a0ddb363b08c3d2777a3395e1
0c0b6080f56309192ab5aacd4b45f55d
a61fc77af39bd81a19218a79762c3386
2df55785075f37d8c71dc8a42097ee43
344739a0dd48d03025b0450cf1fb5e8c
aeb893d9a96d1f15519bb3c4dcb40ee3
16672ea16c012664f8a9f11255518deb
-----END OpenVPN Static key V1-----
</tls-crypt>
VPN_CONF_NL

cat > /etc/openvpn/client/protonvpn-us.conf <<'VPN_CONF_US'
# ==============================================================================
# Copyright (c) 2023 Proton AG (Switzerland)
# Email: contact@protonvpn.com
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR # OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ==============================================================================

# The server you are connecting to is using a circuit in order to separate entry IP from exit IP
# The same entry IP allows to connect to multiple exit IPs in the same data center.

# If you want to explicitly select the exit IP corresponding to server NL-FREE#254 you need to
# append a special suffix to your OpenVPN username.
# Please use "EHwataJjAhXVtMi3+b:0" in order to enforce exiting through NL-FREE#254.

# If you are a paying user you can also enable the ProtonVPN ad blocker (NetShield) or Moderate NAT:
# Use: "EHwataJjAhXVtMi3+b:0+f1" to enable anti-malware filtering
# Use: "EHwataJjAhXVtMi3+b:0+f2" to additionally enable ad-blocking filtering
# Use: "EHwataJjAhXVtMi3+b:0+nr" to enable Moderate NAT
# Note that you can combine the "+nr" suffix with other suffixes.

client
dev tun
proto udp
remote 89.187.171.225 1194
remote 89.187.171.225 1194
remote 89.187.171.225 1194
remote-random


resolv-retry infinite
nobind
pull-filter ignore "redirect-gateway"
pull-filter ignore "dhcp-option DNS"
route-nopull

cipher AES-256-GCM

setenv CLIENT_CERT 0
tun-mtu 1500
mssfix 0
persist-key
persist-tun

reneg-sec 0

remote-cert-tls server
auth-user-pass /etc/openvpn/auth.txt

script-security 2

<ca>
-----BEGIN CERTIFICATE-----
MIIFnTCCA4WgAwIBAgIUCI574SM3Lyh47GyNl0WAOYrqb5QwDQYJKoZIhvcNAQEL
BQAwXjELMAkGA1UEBhMCQ0gxHzAdBgNVBAoMFlByb3RvbiBUZWNobm9sb2dpZXMg
QUcxEjAQBgNVBAsMCVByb3RvblZQTjEaMBgGA1UEAwwRUHJvdG9uVlBOIFJvb3Qg
Q0EwHhcNMTkxMDE3MDgwNjQxWhcNMzkxMDEyMDgwNjQxWjBeMQswCQYDVQQGEwJD
SDEfMB0GA1UECgwWUHJvdG9uIFRlY2hub2xvZ2llcyBBRzESMBAGA1UECwwJUHJv
dG9uVlBOMRowGAYDVQQDDBFQcm90b25WUE4gUm9vdCBDQTCCAiIwDQYJKoZIhvcN
AQEBBQADggIPADCCAgoCggIBAMkUT7zMUS5C+NjQ7YoGpVFlfbN9HFgG4JiKfHB8
QxnPPRgyTi0zVOAj1ImsRilauY8Ddm5dQtd8qcApoz6oCx5cFiiSQG2uyhS/59Zl
5wqIkw1o+CgwZgeWkq04lcrxhhfPgJZRFjrYVezy/Z2Ssd18s3/FFNQ+2iV1KC2K
z8eSPr50u+l9vEKsKiNGkJTdlWjoDKZM2C15i/h8Smi+PdJlx7WMTtYoVC1Fzq0r
aCPDQl18kspu11b6d8ECPWghKcDIIKuA0r0nGqF1GvH1AmbC/xUaNrKgz9AfioZL
MP/l22tVG3KKM1ku0eYHX7NzNHgkM2JKnBBannImQQBGTAcvvUlnfF3AHx4vzx7H
ahpBz8ebThx2uv+vzu8lCVEcKjQObGwLbAONJN2enug8hwSSZQv7tz7onDQWlYh0
El5fnkrEQGbukNnSyOqTwfobvBllIPzBqdO38eZFA0YTlH9plYjIjPjGl931lFAA
3G9t0x7nxAauLXN5QVp1yoF1tzXc5kN0SFAasM9VtVEOSMaGHLKhF+IMyVX8h5Iu
IRC8u5O672r7cHS+Dtx87LjxypqNhmbf1TWyLJSoh0qYhMr+BbO7+N6zKRIZPI5b
MXc8Be2pQwbSA4ZrDvSjFC9yDXmSuZTyVo6Bqi/KCUZeaXKof68oNxVYeGowNeQd
g/znAgMBAAGjUzBRMB0GA1UdDgQWBBR44WtTuEKCaPPUltYEHZoyhJo+4TAfBgNV
HSMEGDAWgBR44WtTuEKCaPPUltYEHZoyhJo+4TAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBCwUAA4ICAQBBmzCQlHxOJ6izys3TVpaze+rUkA9GejgsB2DZXIcm
4Lj/SNzQsPlZRu4S0IZV253dbE1DoWlHanw5lnXwx8iU82X7jdm/5uZOwj2NqSqT
bTn0WLAC6khEKKe5bPTf18UOcwN82Le3AnkwcNAaBO5/TzFQVgnVedXr2g6rmpp9
gdedeEl9acB7xqfYfkrmijqYMm+xeG2rXaanch3HjweMDuZdT/Ub5G6oir0Kowft
lA1ytjXRg+X+yWymTpF/zGLYfSodWWjMKhpzZtRJZ+9B0pWXUyY7SuCj5T5SMIAu
x3NQQ46wSbHRolIlwh7zD7kBgkyLe7ByLvGFKa2Vw4PuWjqYwrRbFjb2+EKAwPu6
VTWz/QQTU8oJewGFipw94Bi61zuaPvF1qZCHgYhVojRy6KcqncX2Hx9hjfVxspBZ
DrVH6uofCmd99GmVu+qizybWQTrPaubfc/a2jJIbXc2bRQjYj/qmjE3hTlmO3k7V
EP6i8CLhEl+dX75aZw9StkqjdpIApYwX6XNDqVuGzfeTXXclk4N4aDPwPFM/Yo/e
KnvlNlKbljWdMYkfx8r37aOHpchH34cv0Jb5Im+1H07ywnshXNfUhRazOpubJRHn
bjDuBwWS1/Vwp5AJ+QHsPXhJdl3qHc1szJZVJb3VyAWvG/bWApKfFuZX18tiI4N0
EA==
-----END CERTIFICATE-----
</ca>

<tls-crypt>
-----BEGIN OpenVPN Static key V1-----
6acef03f62675b4b1bbd03e53b187727
423cea742242106cb2916a8a4c829756
3d22c7e5cef430b1103c6f66eb1fc5b3
75a672f158e2e2e936c3faa48b035a6d
e17beaac23b5f03b10b868d53d03521d
8ba115059da777a60cbfd7b2c9c57472
78a15b8f6e68a3ef7fd583ec9f398c8b
d4735dab40cbd1e3c62a822e97489186
c30a0b48c7c38ea32ceb056d3fa5a710
e10ccc7a0ddb363b08c3d2777a3395e1
0c0b6080f56309192ab5aacd4b45f55d
a61fc77af39bd81a19218a79762c3386
2df55785075f37d8c71dc8a42097ee43
344739a0dd48d03025b0450cf1fb5e8c
aeb893d9a96d1f15519bb3c4dcb40ee3
16672ea16c012664f8a9f11255518deb
-----END OpenVPN Static key V1-----
</tls-crypt>
VPN_CONF_US

cat > /etc/openvpn/client/protonvpn-jp.conf <<'VPN_CONF_JP'
# ==============================================================================
# Copyright (c) 2023 Proton AG (Switzerland)
# Email: contact@protonvpn.com
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR # OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
# ==============================================================================

# The server you are connecting to is using a circuit in order to separate entry IP from exit IP
# The same entry IP allows to connect to multiple exit IPs in the same data center.

# If you want to explicitly select the exit IP corresponding to server NL-FREE#254 you need to
# append a special suffix to your OpenVPN username.
# Please use "EHwataJjAhXVtMi3+b:0" in order to enforce exiting through NL-FREE#254.

# If you are a paying user you can also enable the ProtonVPN ad blocker (NetShield) or Moderate NAT:
# Use: "EHwataJjAhXVtMi3+b:0+f1" to enable anti-malware filtering
# Use: "EHwataJjAhXVtMi3+b:0+f2" to additionally enable ad-blocking filtering
# Use: "EHwataJjAhXVtMi3+b:0+nr" to enable Moderate NAT
# Note that you can combine the "+nr" suffix with other suffixes.

client
dev tun
proto udp
remote 45.14.71.5 1194
remote 45.14.71.5 1194
remote 45.14.71.5 1194
remote-random


resolv-retry infinite
nobind
pull-filter ignore "redirect-gateway"
pull-filter ignore "dhcp-option DNS"
route-nopull

cipher AES-256-GCM

setenv CLIENT_CERT 0
tun-mtu 1500
mssfix 0
persist-key
persist-tun

reneg-sec 0

remote-cert-tls server
auth-user-pass /etc/openvpn/auth.txt

script-security 2

<ca>
-----BEGIN CERTIFICATE-----
MIIFnTCCA4WgAwIBAgIUCI574SM3Lyh47GyNl0WAOYrqb5QwDQYJKoZIhvcNAQEL
BQAwXjELMAkGA1UEBhMCQ0gxHzAdBgNVBAoMFlByb3RvbiBUZWNobm9sb2dpZXMg
QUcxEjAQBgNVBAsMCVByb3RvblZQTjEaMBgGA1UEAwwRUHJvdG9uVlBOIFJvb3Qg
Q0EwHhcNMTkxMDE3MDgwNjQxWhcNMzkxMDEyMDgwNjQxWjBeMQswCQYDVQQGEwJD
SDEfMB0GA1UECgwWUHJvdG9uIFRlY2hub2xvZ2llcyBBRzESMBAGA1UECwwJUHJv
dG9uVlBOMRowGAYDVQQDDBFQcm90b25WUE4gUm9vdCBDQTCCAiIwDQYJKoZIhvcN
AQEBBQADggIPADCCAgoCggIBAMkUT7zMUS5C+NjQ7YoGpVFlfbN9HFgG4JiKfHB8
QxnPPRgyTi0zVOAj1ImsRilauY8Ddm5dQtd8qcApoz6oCx5cFiiSQG2uyhS/59Zl
5wqIkw1o+CgwZgeWkq04lcrxhhfPgJZRFjrYVezy/Z2Ssd18s3/FFNQ+2iV1KC2K
z8eSPr50u+l9vEKsKiNGkJTdlWjoDKZM2C15i/h8Smi+PdJlx7WMTtYoVC1Fzq0r
aCPDQl18kspu11b6d8ECPWghKcDIIKuA0r0nGqF1GvH1AmbC/xUaNrKgz9AfioZL
MP/l22tVG3KKM1ku0eYHX7NzNHgkM2JKnBBannImQQBGTAcvvUlnfF3AHx4vzx7H
ahpBz8ebThx2uv+vzu8lCVEcKjQObGwLbAONJN2enug8hwSSZQv7tz7onDQWlYh0
El5fnkrEQGbukNnSyOqTwfobvBllIPzBqdO38eZFA0YTlH9plYjIjPjGl931lFAA
3G9t0x7nxAauLXN5QVp1yoF1tzXc5kN0SFAasM9VtVEOSMaGHLKhF+IMyVX8h5Iu
IRC8u5O672r7cHS+Dtx87LjxypqNhmbf1TWyLJSoh0qYhMr+BbO7+N6zKRIZPI5b
MXc8Be2pQwbSA4ZrDvSjFC9yDXmSuZTyVo6Bqi/KCUZeaXKof68oNxVYeGowNeQd
g/znAgMBAAGjUzBRMB0GA1UdDgQWBBR44WtTuEKCaPPUltYEHZoyhJo+4TAfBgNV
HSMEGDAWgBR44WtTuEKCaPPUltYEHZoyhJo+4TAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBCwUAA4ICAQBBmzCQlHxOJ6izys3TVpaze+rUkA9GejgsB2DZXIcm
4Lj/SNzQsPlZRu4S0IZV253dbE1DoWlHanw5lnXwx8iU82X7jdm/5uZOwj2NqSqT
bTn0WLAC6khEKKe5bPTf18UOcwN82Le3AnkwcNAaBO5/TzFQVgnVedXr2g6rmpp9
gdedeEl9acB7xqfYfkrmijqYMm+xeG2rXaanch3HjweMDuZdT/Ub5G6oir0Kowft
lA1ytjXRg+X+yWymTpF/zGLYfSodWWjMKhpzZtRJZ+9B0pWXUyY7SuCj5T5SMIAu
x3NQQ46wSbHRolIlwh7zD7kBgkyLe7ByLvGFKa2Vw4PuWjqYwrRbFjb2+EKAwPu6
VTWz/QQTU8oJewGFipw94Bi61zuaPvF1qZCHgYhVojRy6KcqncX2Hx9hjfVxspBZ
DrVH6uofCmd99GmVu+qizybWQTrPaubfc/a2jJIbXc2bRQjYj/qmjE3hTlmO3k7V
EP6i8CLhEl+dX75aZw9StkqjdpIApYwX6XNDqVuGzfeTXXclk4N4aDPwPFM/Yo/e
KnvlNlKbljWdMYkfx8r37aOHpchH34cv0Jb5Im+1H07ywnshXNfUhRazOpubJRHn
bjDuBwWS1/Vwp5AJ+QHsPXhJdl3qHc1szJZVJb3VyAWvG/bWApKfFuZX18tiI4N0
EA==
-----END CERTIFICATE-----
</ca>

<tls-crypt>
-----BEGIN OpenVPN Static key V1-----
6acef03f62675b4b1bbd03e53b187727
423cea742242106cb2916a8a4c829756
3d22c7e5cef430b1103c6f66eb1fc5b3
75a672f158e2e2e936c3faa48b035a6d
e17beaac23b5f03b10b868d53d03521d
8ba115059da777a60cbfd7b2c9c57472
78a15b8f6e68a3ef7fd583ec9f398c8b
d4735dab40cbd1e3c62a822e97489186
c30a0b48c7c38ea32ceb056d3fa5a710
e10ccc7a0ddb363b08c3d2777a3395e1
0c0b6080f56309192ab5aacd4b45f55d
a61fc77af39bd81a19218a79762c3386
2df55785075f37d8c71dc8a42097ee43
344739a0dd48d03025b0450cf1fb5e8c
aeb893d9a96d1f15519bb3c4dcb40ee3
16672ea16c012664f8a9f11255518deb
-----END OpenVPN Static key V1-----
</tls-crypt>
VPN_CONF_JP

cat > /etc/openvpn/auth.txt <<'VPN_AUTH'
EHwataJjAhXVtMi3
SmHYPf0hnS6Sq9qS2hjNobd13Vfohkjv
VPN_AUTH
chmod 600 /etc/openvpn/auth.txt

# ---------------------------------------------------------------------
# 3) Scripts de control
# ---------------------------------------------------------------------
cat > /usr/local/sbin/vpn-on <<'VPN_ON'
#!/bin/bash
# vpn-on [nl|us] - Activa la VPN ProtonVPN SOLO para Freebuff y OpenCode
# Los procesos de esas apps (en vpn.slice) salen por la VPN.
# TODO lo demas (tus webs, APIs, MySQL, SSH, etc.) queda por la IP fisica SIEMPRE.
set -e

COUNTRY="${1:-nl}"
# Validar que exista la config del país elegido (protonvpn-<pais>.conf)
CONF_FILE="/etc/openvpn/client/protonvpn-${COUNTRY}.conf"
if [ ! -f "$CONF_FILE" ]; then
  echo "✗ No existe config: $CONF_FILE"
  echo "  Crea una con 'sudo vpn-menu' (Encender VPN -> elegir país) o copia un .ovpn"
  exit 1
fi

# Nombre legible del país (se puede ampliar)
case "$COUNTRY" in
  nl) FOREIGN="Países Bajos" ;; us) FOREIGN="EE.UU." ;; jp) FOREIGN="Japón" ;;
  ca) FOREIGN="Canadá" ;; no) FOREIGN="Noruega" ;; ch) FOREIGN="Suiza" ;;
  se) FOREIGN="Suecia" ;; de) FOREIGN="Alemania" ;; gb) FOREIGN="Reino Unido" ;;
  pl) FOREIGN="Polonia" ;; ro) FOREIGN="Rumanía" ;; sg) FOREIGN="Singapur" ;;
  *) FOREIGN="${COUNTRY^^}" ;;
esac

# --- Limpieza defensiva: si el tun0 quedó huérfano (p.ej. tras stop manual) lo eliminamos
if ip a show tun0 >/dev/null 2>&1; then
  # Si el servicio del país aún corre, pararlo primero para no pelear por tun0
  sudo systemctl stop "openvpn-client@protonvpn-${COUNTRY}" 2>/dev/null || true
  sleep 1
  if ip a show tun0 >/dev/null 2>&1; then
    sudo ip link del tun0 2>/dev/null || true
    sleep 1
  fi
fi
# Limpiar SNAT residual de tun0 (IPs viejas de otras sesiones)
while :; do
  OLD_IP=$(sudo iptables -t nat -L POSTROUTING -nv 2>/dev/null | awk '/SNAT/ && /tun0/ {print $NF; exit}' | sed 's/to://')
  [ -z "$OLD_IP" ] && break
  sudo iptables -t nat -D POSTROUTING -o tun0 -j SNAT --to-source "$OLD_IP" 2>/dev/null || break
done

IFACE=$(ip -o link show up | awk -F': ' '$2!~/^lo/{gsub(/^ /,"",$2); print $2; exit}')
GW=$(ip route | awk '/^default/ {print $3; exit}')
TABLE=200
PHYS_IP=$(ip -o addr show dev "$IFACE" | awk '/inet /{print $4}' | cut -d/ -f1)

# Si ya hay una VPN activa, apagarla limpiamente primero
if ip a show tun0 >/dev/null 2>&1; then
  echo "Ya hay una VPN activa; apagándola primero..."
  /usr/local/sbin/vpn-off
fi

# 1) Levantar el túnel (aún sin marcas: nada cambia hasta que se instalen)
echo "Conectando a ProtonVPN ($FOREIGN)..."
if ! sudo systemctl start "openvpn-client@protonvpn-${COUNTRY}"; then
  echo "✗ El servicio no arrancó"
  sudo journalctl -u "openvpn-client@protonvpn-${COUNTRY}" -n 10 --no-pager 2>/dev/null | tail -10
  exit 1
fi

for i in $(seq 1 20); do
  ip a show tun0 >/dev/null 2>&1 && break
  sleep 1
done
if ! ip a show tun0 >/dev/null 2>&1; then
  echo "✗ El túnel no se levantó"
  sudo journalctl -u "openvpn-client@protonvpn-${COUNTRY}" -n 15 --no-pager 2>/dev/null | tail -15
  exit 1
fi

# 2) Tabla 200: default por el túnel CON src del túnel (crítico para que Proton acepte)
TUN_IP=$(ip -o addr show dev tun0 | awk '/inet /{print $4}' | cut -d/ -f1)
sudo ip route add unreachable default table "$TABLE" 2>/dev/null || true
sudo ip route flush table "$TABLE"
sudo ip route add default dev tun0 src "$TUN_IP" table "$TABLE"

#    Excepciones: servidores VPN (el túnel no puede pasar por sí mismo)
for srv in $(sudo grep -hE '^remote ' /etc/openvpn/client/protonvpn-*.conf 2>/dev/null | awk '{print $2}' | sort -u); do
  case "$srv" in
    *.*) sudo ip route add "$srv/32" via "$GW" dev "$IFACE" table "$TABLE" 2>/dev/null || true ;;
  esac
done

#    Excepciones: gateway y DNS físicos (resolución y red local nunca dependen del túnel)
sudo ip route add "$GW/32" via "$GW" dev "$IFACE" table "$TABLE" 2>/dev/null || true
for dns in $(resolvectl dns 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u); do
  sudo ip route add "$dns/32" via "$GW" dev "$IFACE" table "$TABLE" 2>/dev/null || true
done

# 3) Marcado por política: SOLO procesos en vpn.slice -> túnel.
#    Respuestas de conexiones entrantes y todo lo demás -> IP física.
sudo iptables -t mangle -N VPN_MARK 2>/dev/null || sudo iptables -t mangle -F VPN_MARK
sudo iptables -t mangle -A VPN_MARK -m conntrack --ctstate ESTABLISHED,RELATED -j CONNMARK --restore-mark --nfmask 0x1 --ctmask 0x1
sudo iptables -t mangle -A VPN_MARK -m cgroup --path /vpn.slice -j MARK --set-mark 0x1
sudo iptables -t mangle -A VPN_MARK -m mark --mark 0x1 -j CONNMARK --save-mark --nfmask 0x1 --ctmask 0x1
sudo iptables -t mangle -C OUTPUT -j VPN_MARK 2>/dev/null || sudo iptables -t mangle -A OUTPUT -j VPN_MARK

# 4) Regla de ruteo: lo marcado -> tabla 200 (túnel)
sudo ip rule del priority 100 fwmark 0x1 lookup "$TABLE" 2>/dev/null || true
sudo ip rule add priority 100 fwmark 0x1 lookup "$TABLE"

# 4b) SNAT: forzar origen = IP del túnel en todo lo que sale por tun0
#     (el kernel no re-selecciona el origen al re-enrutar por marca; Proton
#     descarta paquetes que no vienen de la subred del túnel)
#     IMPORTANTE: se REEMPLAZA cualquier SNAT viejo (la IP del túnel cambia
#     en cada conexión; dejar el anterior hace chocar las reglas y corta el túnel)
# Limpia reglas SNAT de tun0 existentes (por to-source, ya que -j SNAT a secas
# no empareja cuando hay --to-source explicitos de sesiones anteriores)
while :; do
  OLD_IP=$(sudo iptables -t nat -L POSTROUTING -nv 2>/dev/null | awk '/SNAT/ && /tun0/ {print $NF; exit}' | sed 's/to://')
  [ -z "$OLD_IP" ] && break
  sudo iptables -t nat -D POSTROUTING -o tun0 -j SNAT --to-source "$OLD_IP" 2>/dev/null || break
  sudo iptables -t nat -F POSTROUTING 2>/dev/null
done
sudo iptables -t nat -A POSTROUTING -o tun0 -j SNAT --to-source "$TUN_IP"

# 4c) Forzar IPv4 en el slice (IMPORTANTE: el túnel es IPv4-only).
#     OpenCode/Freebuff resuelven su backend por IPv6 y, sin esto, su tráfico
#     sale por la IPv6 física del VPS y NUNCA pasa por la VPN (se nota como
#     "no funciona el límite por IP"). Con REJECT (no DROP) el sistema cae
#     al instante a IPv4 -> túnel -> VPN.
sudo ip6tables -D OUTPUT -m cgroup --path /vpn.slice -j REJECT 2>/dev/null || true
sudo ip6tables -I OUTPUT 1 -m cgroup --path /vpn.slice -j REJECT

# 5) Mover Freebuff y OpenCode al slice VPN (sus conexiones nuevas saldrán por el túnel)
echo "Buscando Freebuff/OpenCode..."
# Mover procesos vivos a vpn.slice NO es fiable en sesiones SSH (systemd bloquea
# escribir a cgroup.procs con "Device or resource busy"). La forma correcta de que
# Freebuff/OpenCode salgan por la VPN es lanzarlos con: sudo vpn-run <app>
# (usuario ver README). Aqui solo se informa de los encontrados.
sudo python3 - <<'PY' || true
import os
found = []
for pid in os.listdir('/proc'):
    if not pid.isdigit():
        continue
    try:
        with open(f'/proc/{pid}/cmdline', 'rb') as f:
            cmd = f.read().replace(b'\x00', b' ').decode(errors='ignore').lower()
    except Exception:
        continue
    if 'freebuff' in cmd or 'opencode' in cmd:
        found.append((pid, cmd.strip()[:60]))
if found:
    print(f"  Encontrados {len(found)} proceso(s) Freebuff/OpenCode:")
    for pid, cmd in found[:10]:
        print(f"    PID {pid}: {cmd}")
    print("  Para que salgan por la VPN, relanza cada uno con:  sudo vpn-run <comando>")
else:
    print("  No hay procesos Freebuff/OpenCode corriendo.")
PY

# 6) Verificación (a través del túnel)
ip route show table "$TABLE" | grep -q '^default' || sudo ip route add default dev tun0 src "$TUN_IP" table "$TABLE"
echo "Verificando salida por el túnel..."
IPOUT=$(sudo vpn-run curl -s --max-time 10 https://api.ipify.org 2>/dev/null | tail -1)
LOC=$(sudo vpn-run curl -s --max-time 10 https://ipinfo.io/json 2>/dev/null | tail -1 | python3 -c 'import json,sys; print(json.load(sys.stdin).get("country","?"))' 2>/dev/null || echo "?")
echo "✓ VPN ACTIVA ($FOREIGN)"
echo "  Salida de Freebuff/OpenCode: $IPOUT ($LOC)"
echo "  IP física (todo lo demás):   $PHYS_IP  <- intacta"
echo
echo "Uso: sudo vpn-run <comando>  (p.ej. sudo vpn-run opencode)"


VPN_ON

cat > /usr/local/sbin/vpn-off <<'VPN_OFF'
#!/bin/bash
# vpn-off - Apaga la VPN y restaura TODO el tráfico por la IP física
echo "Desconectando VPN..."
# 1) Quitar marcas y reglas primero: nada debe depender del túnel
sudo iptables -t mangle -D OUTPUT -j VPN_MARK 2>/dev/null || true
sudo iptables -t mangle -F VPN_MARK 2>/dev/null || true
sudo iptables -t mangle -X VPN_MARK 2>/dev/null || true
sudo ip rule del priority 100 fwmark 0x1 lookup 200 2>/dev/null || true
sudo ip route flush table 200 2>/dev/null || true
# Quitar el forzado de IPv4 del slice (OpenCode/Freebuff vuelven a poder usar IPv6)
sudo ip6tables -D OUTPUT -m cgroup --path /vpn.slice -j REJECT 2>/dev/null || true
# Quitar SNAT del túnel si existe
TUN_IP=$(ip -o addr show dev tun0 2>/dev/null | awk '/inet /{print $4}' | cut -d/ -f1)
if [ -n "$TUN_IP" ]; then
  sudo iptables -t nat -D POSTROUTING -o tun0 -j SNAT --to-source "$TUN_IP" 2>/dev/null || true
fi
# 2) Detener el túnel: CUALQUIER servicio ProtonVPN activo (no solo nl/us)
for u in $(systemctl list-units --all --no-legend 'openvpn-client@protonvpn-*' 'openvpn-client@protonvpn-*.service' 2>/dev/null | awk '{print $1}'); do
  sudo systemctl stop "$u" 2>/dev/null || true
done
sleep 2
if ip a show tun0 >/dev/null 2>&1; then
  sudo ip link del tun0 2>/dev/null || true
fi
# 3) Verificar
echo "✓ VPN DESCONECTADA — IP pública: $(curl -s --max-time 8 https://api.ipify.org)"


VPN_OFF

cat > /usr/local/sbin/vpn-run <<'VPN_RUN'
#!/bin/bash
# vpn-run <comando...> - Ejecuta un comando con el tráfico saliendo por la VPN
# Uso: sudo vpn-run curl https://api.ipify.org
#      sudo vpn-run opencode
# Ejecuta en el directorio actual del llamador (cd al PWD original) para que
# opencode/freebuff levanten desde donde estás y recuperen sus chats de esa carpeta.
# Solo este comando usa el túnel; el resto del sistema queda por la IP física.
if [ $# -eq 0 ]; then
  echo "Uso: sudo vpn-run <comando> [argumentos...]"
  exit 1
fi
if ! ip a show tun0 >/dev/null 2>&1; then
  echo "✗ La VPN no está activa. Ejecuta primero: sudo vpn-on"
  exit 1
fi
RUNAS="${SUDO_USER:-$(id -un)}"
# Directorio desde el que se invoca vpn-run (sudo conserva el PWD del llamador)
WORKDIR="${PWD:-$(pwd 2>/dev/null)}"
# Se usa systemd-run (no write directo a cgroup.procs): en sesiones SSH, escribir el
# PID a vpn.slice/cgroup.procs falla con "Device or resource busy" porque systemd
# gestiona el scope de la sesión. systemd-run crea una unidad bajo vpn.slice de
# forma legitima, su tráfico se marca (match cgroup /vpn.slice) -> sale por el tunel.
# El comando arranca en $WORKDIR (cd primero) y hereda TODOS los argumentos.
exec sudo systemd-run --collect --slice=vpn.slice --pipe \
  runuser -u "$RUNAS" -- bash -c 'cd "$1" 2>/dev/null || true; shift; exec "$@"' vpn-run "$WORKDIR" "$@"
VPN_RUN

cat > /usr/local/sbin/vpn-menu <<'VPN_MENU'
#!/bin/bash
# ============================================================
# vpn-menu — Menú interactivo de la VPN ProtonVPN (bajo demanda)
# Solo afecta el tráfico de Freebuff/OpenCode (vpn.slice).
# El resto del sistema SIEMPRE va por la IP física.
# ============================================================

# ---------- Configuración ----------
IFACE=$(ip -o link show up | awk -F': ' '$2!~/^lo/{gsub(/^ /,"",$2); print $2; exit}')
TABLE=200
CONF_NL="/etc/openvpn/client/protonvpn-nl.conf"
CONF_US="/etc/openvpn/client/protonvpn-us.conf"
AUTH="/etc/openvpn/auth.txt"

# Colores
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

active_country() {
  for c in nl us; do
    if systemctl is-active openvpn-client@protonvpn-$c >/dev/null 2>&1; then echo "$c"; return; fi
  done
  echo "off"
}

pub_ip() {
  curl -s --max-time 6 https://api.ipify.org 2>/dev/null
}

show_status() {
  echo ""
  echo "═══ ESTADO ACTUAL ═══"
  AES=$(active_country)
  if [ "$AES" = "off" ]; then
    echo -e "${YELLOW}VPN: APAGADA${NC}"
    echo -e "IP pública del VPS: ${CYAN}$(pub_ip)${NC}"
  else
    PAIS="Países Bajos"; [ "$AES" = "us" ] && PAIS="EE.UU."
    TUN_IP=$(ip -o addr show tun0 2>/dev/null | awk '/inet /{print $4}' | cut -d/ -f1)
    echo -e "${GREEN}VPN: ACTIVA ($PAIS)${NC}  | túnel: $TUN_IP"
    echo -e "  IP de salida (Freebuff/OpenCode): ${CYAN}$(sudo vpn-run curl -s --max-time 6 https://api.ipify.org 2>/dev/null)${NC}"
    echo -e "  IP física (resto del sistema):    ${CYAN}$(pub_ip)${NC}"
  fi
  echo ""
}

install_openvpn() {
  echo -e "\n${CYAN}── Verificando OpenVPN ──${NC}"
  if command -v openvpn >/dev/null 2>&1; then
    echo -e "${GREEN}✓ OpenVPN ya está instalado: $(openvpn --version 2>/dev/null | head -1)${NC}"
  else
    echo -e "${YELLOW}Instalando OpenVPN...${NC}"
    sudo apt-get update -qq && sudo apt-get install -y openvpn
    echo -e "${GREEN}✓ OpenVPN instalado${NC}"
  fi
  sleep 1
}

config_proton() {
  while true; do
    clear 2>/dev/null || true
    echo -e "${CYAN}═══ CONFIGURACIÓN DE PROTONVPN ═══${NC}"
    echo ""
    echo -e "  1) ${GREEN}Ver credenciales actuales${NC}"
    echo -e "  2) ${YELLOW}Editar usuario/contraseña${NC}"
    echo -e "  3) ${YELLOW}Ver ruta del certificado (.conf)${NC}"
    echo -e "  4) ${YELLOW}Copiar nuevo certificado (.conf)${NC}"
    echo -e "  5) ${RED}Volver al menú principal${NC}"
    echo -n "  Elige: "; read -r op
    case "$op" in
      1)
        echo -e "${GREEN}Credenciales OpenVPN (${AUTH}):${NC}"
        U=$(sudo sed -n '1p' "$AUTH" 2>/dev/null); P=$(sudo sed -n '2p' "$AUTH" 2>/dev/null)
        [ -n "$U" ] && echo "  Usuario: $U" || echo "  Usuario: (vacío)"
        [ -n "$P" ] && echo "  Contraseña: ********" || echo "  Contraseña: (vacío)"
        read -rsp "  (pulsa Enter...)"; echo
        ;;
      2)
        echo -e "${YELLOW}Introduce usuario OpenVPN de Proton (deja vacío para no cambiar):${NC}"
        read -r nu
        echo -e "${YELLOW}Introduce contraseña OpenVPN de Proton (deja vacío para no cambiar):${NC}"
        read -rs np
        echo ""
        if [ -n "$nu" ] || [ -n "$np" ]; then
          OLD_U=$(sudo sed -n '1p' "$AUTH" 2>/dev/null); OLD_P=$(sudo sed -n '2p' "$AUTH" 2>/dev/null)
          sudo tee "$AUTH" > /dev/null <<EOF
${nu:-$OLD_U}
${np:-$OLD_P}
EOF
          sudo chmod 600 "$AUTH"
          echo -e "${GREEN}✓ Credenciales actualizadas${NC}"
        else
          echo -e "${YELLOW}Sin cambios${NC}"
        fi
        sleep 1
        ;;
      3)
        echo -e "${YELLOW}Certificados/archivos .ovpn/.conf instalados:${NC}"
        sudo ls -la /etc/openvpn/client/*.conf 2>/dev/null | awk '{print "  "$NF"  ("$5" bytes)"}'
        read -rsp "  (pulsa Enter...)"; echo
        ;;
      4)
        echo -e "${YELLOW}Archivos .conf/.ovpn en tu HOME actual:${NC}"
        ls "$HOME"/*.conf "$HOME"/*.ovpn 2>/dev/null || echo "  (ninguno)"
        echo -e "${CYAN}Puedes subir uno con: scp archivo.ovpn ubuntu@$HOSTNAME:~/${NC}"
        echo -n "  Nombre del archivo a copiar (o Enter para cancelar): "; read -r F
        if [ -n "$F" ] && [ -f "$HOME/$F" ]; then
          DEST="/etc/openvpn/client/${F%.*}.conf"
          sudo cp "$HOME/$F" "$DEST" && sudo chmod 600 "$DEST"
          echo -e "${GREEN}✓ Copiado a $DEST${NC}"
        else
          echo -e "${YELLOW}Cancelado o archivo no encontrado${NC}"
        fi
        sleep 1
        ;;
      5) break ;;
      *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
    esac
  done
}

select_country_ip() {
  echo -e "${CYAN}═══ SELECCIÓN DE PAÍS / IP ═══${NC}"
  echo ""
  echo "Países disponibles (plan gratuito Proton):"
  echo -e "  ${GREEN}[1]${NC} Países Bajos"
  echo -e "  ${GREEN}[2]${NC} EE.UU."
  echo -e "  ${GREEN}[3]${NC} Japón"
  echo -e "  ${GREEN}[4]${NC} Canadá"
  echo -e "  ${GREEN}[5]${NC} Noruega"
  echo -e "  ${GREEN}[6]${NC} Suiza"
  echo -e "  ${GREEN}[7]${NC} Introducir IP/servidor manualmente"
  echo ""
  echo -n "  Elige país [1-7 o Enter=Países Bajos]: "; read -r p
  CNT=""; IP=""; PORT="1194"
  case "${p:-1}" in
    1) CNT=nl; IP="185.100.235.117"; LABEL="Países Bajos" ;;
    2) CNT=us; IP="89.187.171.225";  LABEL="EE.UU." ;;
    3) CNT=jp; IP="45.14.71.5";      LABEL="Japón" ;;
    4) CNT=ca; IP="149.34.243.97";   LABEL="Canadá" ;;
    5) CNT=no; IP="89.187.160.9";    LABEL="Noruega" ;;
    6) CNT=ch; IP="185.159.157.169"; LABEL="Suiza" ;;
    7) CNT=custom; echo -n "  IP del servidor: "; read -r IP; [ -z "$IP" ] && { echo -e "${RED}IP requerida${NC}"; sleep 1; return; }; LABEL="Personalizado ($IP)" ;;
    *) echo -e "${RED}Opción inválida${NC}"; return ;;
  esac

  echo -n "  Puerto [Enter=1194]: "; read -r PRT
  [ -n "$PRT" ] && PORT="$PRT"

  # Detener conexión activa actual
  sudo systemctl stop openvpn-client@protonvpn-nl 2>/dev/null || true
  sudo systemctl stop openvpn-client@protonvpn-us 2>/dev/null || true

  # Crear/reconfigurar la config para el país elegido (basada en la US, con CA+tls-crypt)
  CCDIR="/etc/openvpn/client"
  NEWCONF="$CCDIR/protonvpn-${CNT}.conf"
  sudo cp "$CCDIR/protonvpn-us.conf" "$NEWCONF" 2>/dev/null
  sudo sed -i "/^remote /c\\remote $IP $PORT" "$NEWCONF"
  sudo chmod 600 "$NEWCONF"

  # Conectar
  echo -e "${CYAN}Conectando a $LABEL ($IP)...${NC}"
  sudo /usr/local/sbin/vpn-on "$CNT" 2>/dev/null || sudo /usr/local/sbin/vpn-on "$CNT" >/dev/null 2>&1
  sleep 2
  if ip a show tun0 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Conectado a $LABEL ($IP)${NC}"
    echo -e "  IP de salida: ${CYAN}$(sudo vpn-run curl -s --max-time 6 https://api.ipify.org 2>/dev/null)${NC}"
  else
    echo -e "${RED}✗ No se pudo conectar a $LABEL ($IP)${NC}"
  fi
  echo ""
}

turn_off() {
  echo -e "${YELLOW}═══ APAGANDO VPN ═══${NC}"
  sudo /usr/local/sbin/vpn-off
  echo -e "${GREEN}✓ VPN apagada — IP restaurada: $(pub_ip)${NC}"
  sleep 1
}

# =================== MENÚ PRINCIPAL ===================
while true; do
  clear 2>/dev/null || true
  echo "═══════════════════════════════════════════════════"
  echo "        MENÚ VPN PROTONVPN (solo Freebuff/OpenCode)"
  echo "═══════════════════════════════════════════════════"
  show_status
  echo "  1) Instalar OpenVPN"
  echo "  2) Configuración de ProtonVPN"
  echo "  3) Encender VPN (elegir país / IP)"
  echo "  4) Apagar VPN"
  echo "  5) Ejecutar comando por la VPN (vpn-run)"
  echo "  6) Salir"
  echo ""
  echo -n "  Elige una opción: "; read -r op
  case "$op" in
    1) install_openvpn ;;
    2) config_proton ;;
    3) clear 2>/dev/null || true; echo -e "${CYAN}═══ ENCENDER VPN ═══${NC}"; select_country_ip ;;
    4) turn_off ;;
    5) echo -n "  Comando a ejecutar por la VPN: "; read -r cmd; [ -n "$cmd" ] && sudo vpn-run bash -c "$cmd" && echo -e "${GREEN}✓ Hecho${NC}"; sleep 1 ;;
    6) echo -e "${GREEN}¡Hasta luego!${NC}"; break ;;
    *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
  esac
done

VPN_MENU

chmod 755 /usr/local/sbin/vpn-on /usr/local/sbin/vpn-off /usr/local/sbin/vpn-run /usr/local/sbin/vpn-menu

# ---------------------------------------------------------------------
# 4) Slice + sysctl
# ---------------------------------------------------------------------
cat > /etc/systemd/system/vpn.slice <<'VPN_SLICE'
[Unit]
Description=Slice para procesos que usan la VPN (Freebuff, OpenCode)
[Slice]


VPN_SLICE
cat > /etc/sysctl.d/99-vpn-policy-routing.conf <<'SYSCTL'
# Routing selectivo VPN: respuestas del túnel no deben descartarse por rp_filter estricto
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2


SYSCTL
systemctl start vpn.slice 2>/dev/null || true

# ---------------------------------------------------------------------
# 5) Sin auto-arranque del tunel (bajo demanda)
# ---------------------------------------------------------------------
for c in nl us jp; do
  systemctl disable "openvpn-client@protonvpn-$c" >/dev/null 2>&1 || true
done

echo "== Listo. Uso: =="
echo "  sudo vpn-menu                  -> menú interactivo"
echo "  sudo vpn-on [nl|us|jp]         -> encender (país)"
echo "  sudo vpn-run <comando>         -> ejecutar algo por la VPN (p.ej: sudo vpn-run opencode)"
echo "  sudo vpn-off                   -> apagar"
