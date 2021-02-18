#!/bin/sh

# Download and install V2Ray
mkdir /tmp/v2ray
curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/$VER/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl
install -m 755 /tmp/v2ray/geoip.dat /usr/local/bin/geoip.dat
install -m 755 /tmp/v2ray/geosite.dat /usr/local/bin/geosite.dat

# Remove temporary directory
rm -rf /tmp/v2ray

# V2Ray new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
	"log": {
		"loglevel": "warning"
	},
	"levels":{
		"1":{
			"handshake": 5,
			"connIdle": 300,
			"uplinkOnly": 3,
			"downlinkOnly": 3,
			"bufferSize": $BUFFERSIZE
		}
	},
	"inbounds": [{
		"port": $PORT,
		"protocol": "vless",
		"settings": {
			"clients": [{
				"id": "$UUID",
				"level": 1,
				"email": ""
				
			}],
			"decryption": "none"
		},
		"streamSettings": {
			"network": "ws"
		}
	}],
	"outbounds": [{
		"protocol": "freedom",
		"settings": {}
	},{
		"protocol": "blackhole",
		"settings": {},
		"tag": "blocked"
	}],
	"routing": {
		"rules": [{
			"type": "field",
			"ip": ["geoip:private"],
			"outboundTag": "blocked"
		}]
	},
	"v2raygcon": {
		"env": {
			"V2RAY_BUF_READV": "auto"
		}
	}
}
EOF

# Run V2Ray
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
