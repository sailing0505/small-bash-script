#!/usr/bin/env bash

deploy_template="\
{
    \"apiVersion\": \"apps/v1beta1\",
    \"kind\": \"Deployment\",
    \"metadata\": {
        \"name\": \"${appName}\"
    },
    \"spec\": {
        \"replicas\": 3,
        \"selector\": {
            \"matchLabels\": {
                \"app\": \"nginx\"
            }
        },
        \"template\": {
            \"metadata\": {
                \"labels\": {
                    \"app\": \"nginx\"
                }
            },
            \"spec\": {
                \"containers\": [
                    {
                        \"name\": \"nginx\",
                        \"image\": \"nginx:1.12\",
                        \"ports\": [
                            {
                                \"containerPort\": 80
                            }
                        ]
                    }
                ]
            }
        }
    }
}
"
