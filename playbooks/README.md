# Playbooks

These playbooks are meant to be launched from the `cfn-init` section of your stack.

### Create the `stack.yaml` file

In your stack create the file that will contain all the variable required by the playbook

```
    '/root/playbooks/group_vars/stack.yaml':
        content: !Sub |
            Region: '${AWS::Region}'
            StackName: '${AWS::StackName}'
            LogGroup: '${AWS::StackName}'
        mode: '000600'
        owner: root
        group: root
```

Then update the `/etc/ansible/hosts` 

```
echo $(uname -n) ansible_connection=local > /etc/ansible/hosts
```

Then launch the playbook 

```
ansible-playbook /root/playbooks/playbook.yaml --extra-vars=@/root/playbooks/group_vars/stack.yaml
```

