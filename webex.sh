#!/bin/bash
#get the token
curl -viN \
    -X POST \
    -H "Content-Type': 'application/x-www-form-urlencoded;charset:utf-8" \
    --data "cmd=login&autocommit=true&token=AAABaUnSOq4AEnUAB0gAAtyiwRki3A5pHKQC6e0VkpoiyXk4x%2BnJs6hmxklTDAM4ADJBSFNTAAAAAoe9jDnet0B2sG%2FWc%2Fhx1XCJe5hjjBSYEI8o1Knw%2B3oXNy7PHStHproP6ohLi%2FaPnbs31KCMn6En2tQoaQ7L%2Bit%2FR2yhRi4jSLaSx%2FyBFx8FKSSVeq5uyZSo5gxKkOT1gsJJCwx6KatHTEyLm7R4SHqz1Cs7otAx5UG%2BYTzBCjebmPUahYWN3dNbnt0rQoRmFGsQoKJeNP%2BfVHq1WO7POQR3%2BllLhbc4URN91tGKIrbToHwBIZv4odSCoiE4nullbOUATxy94j%2Fj1onhvZ%2FDfxo9WG%2FhKuHF0pYqWo9QBpTjHEOkbvTurkir9woyJ7TDTaVC%2B9WqISwQcR8jUWgXCP0xVmx5HyjC8jEmdjhaJWNQ&isp=WBX&username=jason.wu%40nokia-sbell.com" \
    -k "https://x03swapi.webexconnect.com/wbxconnect/op.do"


