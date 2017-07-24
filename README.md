# python-api-environtment
Dockerized environment for 'python-api' repo

## Install
1. Clone repo.

    ```bash
    git clone https://github.com/JaviSabalete/python-api-environtment.git
    ```

2. Generate key in order to use ansible.

    ```bash
    ssh-keygen -f ansible -q -P ""
    ```

3. Generate git deploy key.

    ```bash
    ssh-keygen -f git -q -P ""
    ```

4. Fork [python-api](https://github.com/JaviSabalete/python-api) repo.

5. Edit `init-api` replacing repo by your forked repo. You should only replace GitHub username

6. Add `git.pub` as [github read-only deploy key](https://github.com/blog/2024-read-only-deploy-keys)

## Usage

1. Start containers in the background. This command creates containers if don't exist or recreates them if `docker-compose.yml` has been modified.

    ```bash
    docker-compose up -d
    ```

2. Access your app via [http://localhost/](http://localhost/).

## How it works via ansible (examples)

1. Try to ping

    ```bash
    ansible -i hosts/all -m ping python-api
    ```

2. Try to deploy

    ```bash
    ansible-playbook -i hosts/all playbook/git.yml --tag=pull
    ```
    
3. Try to stop nginx

    ```bash
    ansible-playbook -i hosts/all playbook/nginx.yml --tag=stop
    ```
