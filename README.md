# CircleCI-Runner-Autodeploy

Since this script is for my personal use, I only added support for Ubuntu/Debian.
if you want CentOS/RHEL, lmk and I'll add it. (or you can add it yourself and make a PR)

## What is this for?

This is a simple script to automatically deploy a CircleCI runner on a server.
It will install the runner, configure it, and start it.

## Why did you make this?

I'm lazy and I don't want to do it manually.
and it's fun to build automated stuff.

## But, why?

Becuz on my repository i have three sub node projects, and I need to deploy three of them on the same server but with one runner it takes forever to checkout, build, and deploy all of them one by one. So I made this script to deploy three runners on the same server.
I don't want to do it manually cuz it's going to take forever to replace all `circleci` to my runner name
So yeah thats basically it.

## Why should I use this?

It's automated and easy to use. You can just run the script answer questions and it will do everything for you.

## What's the catch?

There is no catch. It's free and open source.

actually there is, I didn't add option to change work directory and cleanup working directory after job finished (because I didn't need that for my use case)
if you want to enable (YOU MUST INSTALL THE RUNNER FIRST), read [this](#ive-finished-installing-what-now)

## How do I use it?

So basically if you want to do the same thing as me [deploying three runners on the same server](#but-why) you will need to do this:

1. Create resource class on CircleCI (You need to create new resource class for every runner you create because on the workflow comfig.yml you can only specify the self-hosted resource class to use, you can't specify the runner name)
2. Save the token!! (you will need it later)
3. Download the script (circleci-runner-autodeploy.sh obviously) into /root folder
4. chmod +x circleci-runner-autodeploy.sh (u have to run as root!!!!!)
5. ./circleci-runner-autodeploy.sh (run as root too!!)

Then just follow the instructions and you're done!

## What if I want to use this on a server that already has a runner?

I tweaked the circleci script a bit so that you can create a new runner under different user, which means you can create infinite runners on one server. (if you have enough resources)

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner?

This script is for creating runner, not for managing them. If you want to manage your runners, i'll make a cli tool for that later.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners?

Then this script is not for you. Idk why you're even here.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script?

💀

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script, and I don't want to use CircleCI?

use GitHub Actions

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script, and I don't want to use CircleCI, and I don't want to use GitHub Actions?

Stop.

## What if I want to use this on a server that already has a runner, but I don't want to create a new runner, and I don't want to manage my runners, and I don't want to use this script, and I don't want to use CircleCI, and I don't want to use GitHub Actions, and I don't want to stop?

omg fr

## Ok sorry, no more questions

Thank god

## but... I've finished installing, what now?

Replace YOUR_RUNNER_USERNAME with the runner username u chose when installing
(RUNNER USERNAME AND RUNNER NAME IS DIFFERENT, DON'T GET CONFUSED)

The config file is at
`/etc/opt/YOUR_RUNNER_USERNAME/launch-agent-config.yaml`

to disable/enable cleanup working directory after job finished
or change work directory, you need to edit the config file

NOTE: you need to restart the runner after you edit the config file

read below for restart instructions

You can check the status of your runner by running

```bash
sudo systemctl status YOUR_RUNNER_USERNAME.service
```

it should be online.

By default it's enabled on boot, to disable it

```bash
sudo systemctl disable YOUR_RUNNER_USERNAME.service
```

To enable it back again

```bash
sudo systemctl enable YOUR_RUNNER_USERNAME.service
```

To start it

```bash
sudo systemctl start YOUR_RUNNER_USERNAME.service
```

To stop it

```bash
sudo systemctl stop YOUR_RUNNER_USERNAME.service
```

To restart it

```bash
sudo systemctl restart YOUR_RUNNER_USERNAME.service
```

## I've installed it, but it's not working

Idk lol you prob did something wrong

## Wait, how do i uninstall runners or remove resource class?

TO remove resource class, read this
https://circleci.com/docs/runner-faqs/#can-i-delete-self-hosted-runner-resource-classes

To remove runners from your server

```bash
sudo systemctl stop YOUR_RUNNER_USERNAME.service
sudo systemctl disable YOUR_RUNNER_USERNAME.service
sudo rm -rf /var/opt/YOUR_RUNNER_USERNAME /opt/YOUR_RUNNER_USERNAME /etc/opt/YOUR_RUNNER_USERNAME /usr/lib/systemd/system/YOUR_RUNNER_USERNAME.service
sudo userdel -r YOUR_RUNNER_USERNAME
```

To remove it from circleci

its in the docs i linked above, just read it
here if you're lazy

Runner are removed automatically if it's been inactive for 12 hours. (from what i remember) you can't manually remove it just wait for it to be removed automatically.
