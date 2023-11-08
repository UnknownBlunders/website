+++
author = "Ethan Norlander"
title = "How I access my cluster on a new PC"
date = "2023-11-08"
description = ""
tags = [
    "kubernetes", "Linux"
]
+++

# How I access my cluster on a new PC

I recently built a new PC so now I have to set everything up again. Here's what I do to get from new PC to working on my K8s cluster.

I run a Ubuntu based system because I like it.

Whenever I can, I try to get my packages from a package manager, so I can update them easily.

## Install tools:

### Using Homebrew:

I use homebrew on Linux because I tend to find that it's easier and gets package updates faster. 

#### What makes it easier? 

On the big linux package managers, like apt and dnf, I ususally have to download the vendor's signing key, dearmor it, and add their package repo to my sources list. This takes time. For example, here's [the process of installing kubectl using apt or dnf](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management). And here it is using homebrew: `brew install kubernetes-cli` 

It also sometimes breaks. This past spring I ran into an issue where google's kubectl repo changed their signing key. This broke apt updates until I went through the setup proccess again.

#### What makes get updates faster?

Homebrew is the most popular package manager for Macs. Macs have a much larger install base than linux. A lot of devs expect to get up to date packages through Homebrew. In my experience, homebrew can get updates a bit faster than other package managers. This is especially true for packages that aren't from their vender's repo. At the time of this writing, I can install age from Ubuntu's default apt repo by running `apt install age`. I didn't have to download any signing key or configure my sources. However, the version installed this way is currently v1.0.0. When I install it through homebrew, (`brew install age`) I get the lastest version, v1.1.1.

#### Packages I install with Homebrew:

- kubectl
- talosctl
- age
- sops
- kustomize
- talhelper
- ksops

### Setup 1Password
I install 1Password from their apt repo. Here's a [link](https://support.1password.com/install-linux/#debian-or-ubuntu) on how to do that. 

I keep all of my ssh keys in 1Password, so I need to setup my ssh agent to use 1Password. For that I go to 1Password Settings > Developer and chck the "Use the SSH Agent" box. I then paste the following into ~/.ssh/config:

```
Host *
	IdentityAgent ~/.1password/agent.sock
```

Now whenever I try to ssh into anything, my ssh agent will check to see if I have a key for it in 1Password.

#### A note on Ubuntu, Firefox, the 1Password broswer extension, and AppArmor

This isn't really in this scope of this post, but I wanted to write it down.

Normally, the 1Password browser extension uses the 1Password app for authentication. The preinstalled version of Firefox in Ubuntu has some issues with this out of the box. Ubuntu loves Snap, so they use it to install Firefox by default. Snap puts Firefox in a sandbox, so it's not able to find the 1Password app. First, I have to uninstall the snap version of Firefox and install it from apt. Here's [a link](https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04) on how to do that. Once that's done, the 1Password extension still won't be able to find the 1Password app because AppArmor blocks it. I have to add the following lines to `/etc/apparmor.d/usr.bin.firefox`. From [this link](https://1password.community/discussion/134432/when-i-login-to-1password-on-ubuntu-linux-the-firefox-extension-does-not-unlock)

```
# Native Messaging
owner @{HOME}/.mozilla/**/native-messaging-hosts/** ixr,

# 1Password extension
/opt/1Password/1Password-BrowserSupport ixr,
/run/user/1000/1Password-BrowserSupport.sock ixr,
/run/user/1000/1Password-BrowserSupport.sock wr,
```

Then I restart apparmor `sudo systemctl restart apparmor` and 1Password's extension works! I've only run into this issue on Ubuntu, but honestly I haven't tried that many distros.

