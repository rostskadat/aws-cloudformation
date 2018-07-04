#!/bin/bash
#
# FILE: apply_settings.sh
#
# DESCRIPTION: This script will 
#
password=$1
[ -z "$password" ] && echo "Invalid password" && exit 1

# Obtain a token (https://github.com/doorkeeper-gem/doorkeeper/wiki/API-endpoint-descriptions-and-examples#curl-command-password-grant)
echo "Obtaining token..."
token=$(curl --silent --request POST --form grant_type=password --form "username=root" --form "password=$password" http://localhost:80/oauth/token | jq -r '.access_token')
[ "$token" == "null" ] && echo "Failed to retrieve token" && exit 1 
url="http://localhost:80/api/v4/application/settings"
echo "Changing settings (token=$token)..."

change_settings()
{
    local key="$1"
    local value="$2"
    echo $key=$(curl --silent --request PUT --header "Authorization: Bearer $token" "$url?$key=$value" | jq ".$key")
}

change_settings signup_enabled                    false
change_settings default_project_visibility        public
change_settings email_author_in_body              true
change_settings gravatar_enabled                  false
change_settings help_page_hide_commercial_content true
change_settings html_emails_enabled               true

curl --silent --request POST -H "Authorization: Bearer $token" -F token=$token http://localhost:80/oauth/revoke > /dev/null
