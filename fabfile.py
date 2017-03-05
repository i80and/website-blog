from fabric.api import run, task, put

@task
def deploy():
    put('public', '/home/andrew/')
    run('doas /usr/local/bin/deploy.sh')
