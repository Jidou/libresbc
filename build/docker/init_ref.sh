#!/bin/bash

#base setup for testing
curl --location --request PUT 'https://172.25.104.162:8443/libreapi/cluster' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
    "name": "defaults",
    "members": [
        "libresbc"
    ],
    "rtp_start_port": 16384,
    "rtp_end_port": 32767,
    "max_calls_per_second": 60,
    "max_concurrent_calls": 4000
}'

curl --location 'https://172.25.104.162:8443/libreapi/base/netalias' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "CcsNetwork",
  "addresses": [
    {
      "member": "libresbc",
      "listen": "172.25.104.162",
      "advertise": "172.25.104.162"
    }
  ],
  "desc": "CCS Network"
}'

curl --location 'https://172.25.104.162:8443/libreapi/base/acl' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "testacl",
  "rules": [
    {
      "value": "dc.peer.test.loc",
      "action": "allow",
      "key": "domain",
      "force": "true"
    }
  ],
  "desc": "Allow DC",
  "action": "allow"
}'

curl --location 'https://172.25.104.162:8443/libreapi/base/gateway' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "CcsCluster",
  "proxy": "172.25.104.164",
  "desc": "CCS Cluster",
  "username": "none",
  "password": "none",
  "port": 5060,
  "transport": "udp",
  "do_register": false,
  "caller_id_in_from": true,
  "cid_type": "none",
  "ping": "600"
}'

curl --location 'https://172.25.104.162:8443/libreapi/base/gateway' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "DcCUBE",
  "proxy": "dc.peer.ccint.loc",
  "desc": "DC CUBE",
  "username": "none",
  "password": "none",
  "port": 5060,
  "transport": "udp",
  "do_register": false,
  "caller_id_in_from": true,
  "cid_type": "none",
  "ping": "600"
}'

curl --location 'https://172.25.104.162:8443/libreapi/sipprofile' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "ccs_inbound",
  "desc": "SIP Public Profile",
  "user_agent": "LibreSBC",
  "sdp_user": "LibreSBC",
  "local_network_acl": "testacl",
  "addrdetect": "autonat",
  "enable_100rel": true,
  "ignore_183nosdp": true,
  "sip_options_respond_503_on_busy": false,
  "disable_transfer": true,
  "manual_redirect": true,
  "enable_3pcc": false,
  "enable_compact_headers": false,
  "dtmf_type": "rfc2833",
  "media_timeout": 0,
  "rtp_rewrite_timestamps": true,
  "context": "carrier",
  "sip_port": 5060,
  "realm": "libresbc.test.loc",
  "sip_address": "CcsNetwork",
  "rtp_address": "CcsNetwork",
  "tls": false,
  "tls_only": false,
  "sips_port": 5061,
  "tls_version": "tlsv1.2"
}'

curl --location 'https://172.25.104.162:8443/libreapi/class/media' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "Ccs",
  "codecs": [
    "PCMA"
  ],
  "desc": "CCS Outside Media Classes",
  "codec_negotiation": "generous",
  "media_mode": "transcode",
  "dtmf_mode": "rfc2833",
  "cng": false,
  "vad": false
}'

curl --location 'https://172.25.104.162:8443/libreapi/class/capacity' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "CcsLimit",
  "desc": "Limit for CCS",
  "cps": 10,
  "concurentcalls": 1000
}'

curl --location 'https://172.25.104.162:8443/libreapi/class/manipulation' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "XHeader",
  "actions": [
    {
      "action": "set",
      "values": [
        "DC_CCS"
      ],
      "refervar": "X-WD-Source-System",
      "pattern": "DC_CCS",
      "targetvar": "sip_h_X-WD-Source-System"
    }
  ],
  "desc": "X Header Test",
  "conditions": {
    "rules": [
      {
        "refervar": "X-LIBRE-INTCONNAME",
        "pattern": "CCS"
      }
    ],
    "logic": "AND"
  },
  "antiactions": [
    {
      "action": "hangup",
      "values": [
        "FUCK_THIS",
        "16"
      ],
      "pattern": "AAAAA"
    }
  ]
}'

curl --location 'https://172.25.104.162:8443/libreapi/class/manipulation' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "PAICopy",
    "actions": [
        {
            "action": "set",
            "refervar": null,
            "pattern": null,
            "targetvar": "sip_h_P-Asserted-Identity",
            "values": [
                "sip:",
                "caller_id_number",
                "@hcs.siptrunk.a1.net"
            ]
        }
    ],
  "desc": "Copy PAI Header",
  "conditions": {
    "rules": [
      {
        "refervar": "X-LIBRE-INTCONNAME",
        "pattern": "CCS"
      }
    ],
    "logic": "AND"
  },
  "antiactions": [
    {
      "action": "hangup",
      "values": [
        "FUCK_THIS",
        "16"
      ],
      "pattern": "AAAAA"
    }
  ]
}'

curl --location 'https://172.25.104.162:8443/libreapi/interconnection/outbound' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
    "name": "CCS",
    "desc": "Outbound to CCS",
    "sipprofile": "ccs_inbound",
    "distribution": "round_robin",
    "rtpaddrs": [
        "172.25.104.162/32"
    ],
    "media_class": "Ccs",
    "capacity_class": "CcsLimit",
    "translation_classes": [],
    "manipulation_classes": [ "XHeader" ],
    "privacy": [
        "none"
    ],
    "cid_type": "none",
    "nodes": [
        "_ALL_"
    ],
    "enable": true,
    "gateways": [
        {
            "name": "CcsCluster",
            "weight": 1
        }
    ]
}'

curl --location 'https://172.25.104.162:8443/libreapi/interconnection/outbound' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
    "name": "DC",
    "desc": "Outbound to DC",
    "sipprofile": "ccs_inbound",
    "distribution": "round_robin",
    "rtpaddrs": [
        "172.25.111.166/32"
    ],
    "media_class": "Ccs",
    "capacity_class": "CcsLimit",
    "translation_classes": [],
    "manipulation_classes": [ "PAICopy" ],
    "privacy": [
        "none"
    ],
    "cid_type": "rpid",
    "nodes": [
        "_ALL_"
    ],
    "enable": true,
    "gateways": [
        {
            "name": "DcCUBE",
            "weight": 1
        }
    ]
}'

curl --location 'https://172.25.104.162:8443/libreapi/routing/table' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "ToCcs",
  "desc": "Routing to CCS",
  "action": "route",
  "routes": {
    "primary": "CCS",
    "secondary": "CCS",
    "load": "100"
  }
}'

curl --location 'https://172.25.104.162:8443/libreapi/routing/table' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
  "name": "ToDc",
  "desc": "Routing to DC",
  "action": "route",
  "routes": {
    "primary": "DC",
    "secondary": "DC",
    "load": "100"
  }
}'

curl --location 'https://172.25.104.162:8443/libreapi/interconnection/inbound' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
    "name": "CCSIN",
    "desc": "",
    "sipprofile": "ccs_inbound",
    "routing": "ToCcs",
    "sipaddrs": [
        "172.25.111.166/32"
    ],
    "rtpaddrs": [
        "10.189.1.0/24",
        "172.25.111.0/24"
    ],
    "ringready": false,
    "media_class": "Ccs",
    "capacity_class": "CcsLimit",
    "translation_classes": [],
    "manipulation_classes": [],
    "authscheme": "IP",
    "nodes": [
        "_ALL_"
    ],
    "enable": true
}'

curl --location 'https://172.25.104.162:8443/libreapi/interconnection/inbound' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--insecure \
--data '{
    "name": "CCSOUT",
    "desc": "Outbound to DC from CCS",
    "sipprofile": "ccs_inbound",
    "routing": "ToDc",
    "sipaddrs": [
        "172.25.104.164/32",
        "172.25.91.166/32"
    ],
    "rtpaddrs": [
        "172.25.104.162/32"
    ],
    "ringready": false,
    "media_class": "Ccs",
    "capacity_class": "CcsLimit",
    "translation_classes": [],
    "manipulation_classes": [],
    "authscheme": "IP",
    "nodes": [
        "_ALL_"
    ],
    "enable": true
}'