# CircleCI-Runner-Autodeploy

# NOTES: I'm no longer maintaining this as i've moved to Jenkins instead coz theres an issue with circleci if you're building multiple projects at the same time (/tmp permission error)

This script is for my personal use, therefore I've only added support for Ubuntu/Debian. If you want CentOS/RHEL, let me know and I'll add it. Alternatively, you can add it yourself and make a PR.

## What is this for?

This is a simple script to automatically deploy a CircleCI runner on a server. It installs the runner, configures it, and starts it.

## Why did you make this?

I made this because I'm somewhat lazy and I don't want to do it manually. Moreover, it's fun to build automated stuff.

## But, why?

In my repository, I have three sub-node projects, and I need to deploy all three of them on the same server. With one runner, it takes a significant amount of time to checkout, build, and deploy all of them one by one. Hence, I made this script to deploy three runners on the same server. I don't want to manually replace all default `circleci` with my custom runner name because it would take forever. So that's essentially it.

## Why should I use this?

It's automated and easy to use. You can just run the script, answer some questions, and it will take care of everything else.

## What's the catch?

There is no catch. It's free and open source.

However, I didn't add the option to change the working directory and clean up the working directory after a job finishes, mainly because I didn't need that for my use case. If you want to enable this feature (you must install the runner first), refer to [this](#ive-finished-installing-what-now)

## How do I use it?

If you want to do the same thing as me ([deploying three runners on the same server](#but-why)), you need to do the following:

1. Create a resource class on CircleCI. You need to create a new resource class for every runner you create because you can only
   specify the self-hosted resource class to use in the workflow config.yml file; you can't specify the runner name to use directly.
2. Save the token (you will need it later).
3. Download the script (circleci-runner-autodeploy.sh) into the /root folder.
4. Run chmod +x circleci-runner-autodeploy.sh (you have to run this as root!).
5. Execute ./circleci-runner-autodeploy.sh (also run this as root!).

Then, just follow the instructions, and you're done!

## What if I want to use this on a server that already has a runner?

I've modified the CircleCI script a bit so that you can create a new runner under a different user. This means you can create infinite runners on one server, given you have sufficient resources.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner?

This script is for creating runners, not for managing them. If you want to manage your runners, I'll develop a CLI tool for that later.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners?

In that case, this script is not for you. I'm not sure why you're here.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script?

💀

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script, and I don't want to use CircleCI?

Use GitHub Actions instead.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script, and I don't want to use CircleCI, and I don't want to use GitHub Actions?

Just stop.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script, and I don't want to use CircleCI, and I don't want to use GitHub Actions, and I don't want to stop?

Fr

## Ok sorry, no more questions

Thank you

## but... I've finished installing, what now?

Replace YOUR_RUNNER_USERNAME with the runner username you chose during installation. Please note that the runner username and runner name are different. Don't get confused!

The config file is located at `/etc/opt/YOUR_RUNNER_USERNAME/launch-agent-config.yaml`

To disable/enable cleanup of the working directory after the job is finished, or to change the working directory, you need to edit the config file.

Note: You need to restart the runner after you edit the config file. Instructions for restarting can be found below.

You can check the status of your runner by running

```bash
sudo systemctl status YOUR_RUNNER_USERNAME.service
```

it should be online.

By default, it's enabled on boot. To disable it, use

```bash
sudo systemctl disable YOUR_RUNNER_USERNAME.service
```

To enable it again, use

```bash
sudo systemctl enable YOUR_RUNNER_USERNAME.service
```

To start it, use

```bash
sudo systemctl start YOUR_RUNNER_USERNAME.service
```

To stop it, use

```bash
sudo systemctl stop YOUR_RUNNER_USERNAME.service
```

To restart it, use

```bash
sudo systemctl restart YOUR_RUNNER_USERNAME.service
```

## I've installed it, but it's not working

I don't know. You probably did something wrong.

## Wait, how do i uninstall runners or remove resource class?

To remove a resource class, read this: https://circleci.com/docs/runner-faqs/#can-i-delete-self-hosted-runner-resource-classes

To remove runners from your server, run the following commands:

```bash
sudo systemctl stop YOUR_RUNNER_USERNAME.service
sudo systemctl disable YOUR_RUNNER_USERNAME.service
rm -rf /usr/lib/systemd/system/YOUR_RUNNER_USERNAME.service
sudo rm -rf /var/opt/YOUR_RUNNER_USERNAME /opt/YOUR_RUNNER_USERNAME /etc/opt/YOUR_RUNNER_USERNAME /usr/lib/systemd/system/YOUR_RUNNER_USERNAME.service
sudo userdel -r YOUR_RUNNER_USERNAME
```

To remove it from CircleCI, refer to the documentation I linked above. Just to reiterate, runners are removed automatically if they've been inactive for 12 hours (as far as I remember). You can't manually remove it; just wait for it to be removed automatically.
