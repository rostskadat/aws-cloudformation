#!/bin/bash
#
# FILE: patching_config.sh
#
# DESCRIPTION: This script will 
#
echo "Patching config.rb..."
patch /opt/gitlab/embedded/service/gitlab-rails/ee/lib/ee/gitlab/auth/ldap/config.rb /root/gitlab/config.rb.patch
