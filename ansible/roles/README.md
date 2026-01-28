# Custom Roles

Place your custom Ansible roles here.

## Creating a New Role

```bash
cd ansible/roles
ansible-galaxy role init my_role_name
```

This creates the standard structure:

```
my_role_name/
├── defaults/
│   └── main.yml      # Default variables (lowest priority)
├── files/            # Static files to copy
├── handlers/
│   └── main.yml      # Handlers (e.g., restart services)
├── meta/
│   └── main.yml      # Role metadata and dependencies
├── tasks/
│   └── main.yml      # Main task list
├── templates/        # Jinja2 templates
├── tests/
│   ├── inventory
│   └── test.yml
└── vars/
    └── main.yml      # Role variables (higher priority)
```

## Example Role Usage

In a playbook:

```yaml
- hosts: webservers
  roles:
    - my_role_name
    - role: another_role
      vars:
        some_var: value
```
