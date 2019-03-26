#!/bin/bash
#get the token
curl -viN \
    -X POST \
    -H "Content-Type': 'application/x-www-form-urlencoded;charset:utf-8" \
    --data "cmd=login&autocommit=true&token=AAABaUfw4dYAEnUAB0gAAmejLMsKFfwDHFY27fcbi5euiXjWZlgJD9Z0NCAyXGVaADJBSFNTAAAAAkWJ3E41uwGPDfWmnbfo7MC02CLI7a2c4P0vbggRcimT%2FZqKaVapqOB%2Buu%2FzHXo2d183dmYjtQ0zglKFCkBDbDWM0uy99RgIL6XjKuFzdr63XWPgDeke4bf4V8MGVzDlAgjhc3o0am1skxOf8WzN691GEdg%2BLwiSqzk9ic9PF5WgnIZ4Kq%2BocFd18wwc3iXL7Rx7YLarXMszdZtF0gb6xa0az5B%2Brzqp30c%2FJA8vPAtdSdhoLUelwvb7je4hAACMnXJ0g%2BTn7VtUn1cEgXPSCZY1OfDmGWpIqk1XjADvrq0IKS%2FIctgKbwuQHca%2FD%2BRN%2Bd9QyoTOj4VtqKNRkkOgcYbuCJKSMbmMrRS%2FljXaM2R4&isp=WBX&username=jason.wu%40nokia-sbell.com" \
    -k "https://x03swapi.webexconnect.com/wbxconnect/op.do"


