---
layout: post
title: General notes on HackTheBox
---

## Beginning Notes

[HackTheBox](https://hackthebox.eu/) (HTB) is a great tool to learn penetration testing (pentesting).  However, some other useful ones exist, such as [TryHackMe](https://tryhackme.com) (which also has a nice [beginner guide](https://tryhackme.com/path/outline/beginner), as well as [INE](pathway for free (https://checkout.ine.com/starter-pass)), and (JuiceShop)[https://owasp.org/www-project-juice-shop/].  Also, CTF (capture the flag) games exist (e.g., [here](https://ctf.hacker101.com/)), as well as [VulnHub](https://www.vulnhub.com/), if you are not ready for HTB.  You will also need a good amount of knowledge of `bash` and `powershell`.  This has come from experience with me, using Linux and doing general sysadmin stuff.  Familiarity and comfortablilty with the command line is almost essential, but you will become familiar soon enough if you don't have that yet.

For getting started with HTB, first, get some helpful tools:
  - `python-python3`
  - `python-pip3`
  - `nmap`
  - `arpscan`
  - `netcap` (or `nc`)
  - `saclist`
  - [`searchsploit`](https://1gbits.com/blog/install-searchsploit-on-kali-linux/)
  - Burp Suite
  - [`mssqlclient.py`](https://github.com/SecureAuthCorp/impacket)
  - [`ffuf`](https://github.com/ffuf/ffuf) or [`gobuster`](https://github.com/OJ/gobuster) or [`dirsearch.py`](https://github.com/maurosoria/dirsearch.git)
  - WireShark or `tcpdump`
  - `ss` (or `netstat` for macOS)
  - Hydra (for brute force)

You will also need a virtual machine (See [VirtualBox](https://www.virtualbox.org/)), preferably running Linux (do not use Windows; use [Kali](https://www.offensive-security.com/kali-linux-vm-vmware-virtualbox-image-download/#1572305786534-030ce714-cc3b) if possible), and [HTB's VPN](https://www.hackthebox.eu/home/start) given to you to use.  *Ensure you run `openvpn` on the VM, **not** your base computer, as running it on your computer and then running the VM will not allow any `tun` connection.*  (This took me a hot minute to figure out...).  These steps will give you good tools to hack, as well as protect your network and your computer.

It looks like you can also set this up [inside Docker instead](https://amar-laksh.github.io/2019/08/24/Setting-up-Kali-docker-for-HackTheBox.html) (just make sure to run `brew install --cask docker` first):
```bash
$ brew install --cask docker
$ open /Applications/Docker.app
$ docker pull kalilinux/kali-rolling
$ docker run -t -i kalilinux/kali-rolling /bin/bash
root💀2cf5de3321a6:/# apt-get update && apt-get install metasploit-framework
```

To set Burp Suite up with a browser (say, Firefox), go into FF and go to Preferences > Network Settings > Settings.  Now select Manual proxy configuration, and put in the HTTP Proxy box `127.0.0.1`, with port `8080`.  Now your browser will be configured to Burp Suite, and you don't have to use their even laggier embedded Chromium browser.

Burp sits between your browser and the website, so now if you try to go onto a website, it will intercept the traffic in Burp Suite, under the Proxy tab.

## Where to Start

First, I have noticed three main steps in HTB:
  1. Gain a foothold&mdash;: you will fumble around in the dark for a while until you have a foothold on the system.  This may look like a reverse shell, or something similar.
  2. Gain user access&mdash;: you gain access to a user of the system from said foothold.  You're nearly there!
  3. Gain root access&mdash;: this is the final goal, and you are in!

One great way to start your pentesting journey is to have a look at some walkthroughs for HTB.  Whether they are blogs or videos, this will give you a good understanding of the kind of workflow used to approach this task

First, if you have an IP address of the machine you want to try to hack, start by pinging the machine.

```bash
ping 10.10.xx.xx
```

If it is responding to pings, you can try some `nmap` commands.  See the Quick Reference section for more `nmap` functionality.

```bash
nmap -sV -sC 10.10.xx.xx
```

(An alternative to this on linux is `ss -tulnp` (or `ss --tcp --udp --listening --numeric --processes`); or [equivalently for macOS](https://superuser.com/questions/724712/what-is-the-equivalent-of-ss-for-mac), `netstat -tuln --program` (or `netstat --tcp --udp --listening --numeric --program`; or [`sudo lsof -iTCP -sTCP:LISTEN -P`](https://apple.stackexchange.com/questions/157893/what-is-the-equivalent-of-netstat-tln-on-os-x)).

This will take a minute to load, and then looks through the top 1000 ports for this machine, and shows us if any of them are open for use.

A lot will come up on the screen.  Maybe one of the first things you will notice is one of the open ports is FTP, and maybe HTTP.

Consider editing `/etc/hosts` to add the IP address of the machine:
```
10.10.xx.xx		some_name
```

Now you can go to `http://some_name:<port>`, if one of the ports from the `nmap` commands are open.

This now might show something!  For example, it might allow you to upload "images".  See if you can upload a PHP file instead...  However, it is always good to "View Page Source" to see if you can find anything interesting off the bat.

One of the simplest ways to get information is to look up `<something> exploit` to see if you know anything about exploiting the webpage.  For example, if the webpage uses a converter, see if there is a converter exploit.  If there is, append your search with `git`, as you then might find something on GitHub.

Look to get a reverse shell.

## Quick reference

### Enumeration

Take some time to understand how `nmap` works and why it was written.  That being said, here are some helpful quick tools using `nmap`.

#### `nmap` short, quick SYN scan

```bash
nmap -sC -sV -O -p- -oA nmap/full <IP> # full scan
nmap -sV -sC -oA nmap <ip> # top 1000 ports
nmap -sC -sV -v -oN nmap.txt <IP>
masscan -e tun0 -p1-65535 --rate=1000 <IP>
sudo nmap -sU -sV -A -T4 -v -oN udp.txt <IP>
nmap -T4 -p- -A <IP>
```

## Metasploit

There are various key words used when using metasploit.  (See [here](https://www.youtube.com/watch?v=8lR27r8Y_ik) for reference.)
  - exploits: A module that will take advantage of a system's vulnerability;
  - payloads: Exploits will install a payload on a system (usually a reverse shell or an interpretter), giving one access to the computer being exploited;
  - auxiliary;
  - nops;
  - post;
  - encoders.

Here are some basic commands for `msfconsole`:
  - `help`: Self evident; displays help;
  - `use`: Allows you to load a module;
    - e.g., `use exploit/windows/browser/adobe_flash_avm2`;
    - Once using the module;
      - You can use the `show` command to give information about the module;
      - You can use the `show options` command to display what options you can change about this explot;
        - After running `show options`, you can use the `set` command to set the options;
      - `show payloads` will give you the different ways of approaching the attack;
      - `show targets` will display the possible targets; you can even specify many targets;
      - `show info` will give you information about the exploit you are using;
  - `search`: finding the right module is probably the most important part of using metasploit, so this is very important; it has some important keywords that it comes with:
    - `platform` is used to target platform specifically;
    - `type` will allow you to specify the type of module (for example, exploits, payloads, etc.);
    - `name` allows you to specify what you are searching for, by name;
    - e.g., `search type:exploit platform:windows microsoft sql`;

## Misc Notes

  - [Payload of all things](https://github.com/swisskyrepo/PayloadsAllTheThings);
  - [This is cool](https://github.com/7h3rAm/writeups).  As is [this](https://github.com/Purp1eW0lf/HackTheBoxWriteups/).
  - ```bash
    netcap -lvnp 5353
    ```
  - See also [here](https://medium.com/bug-bounty-hunting/beginner-tips-to-own-boxes-at-hackthebox-9ae3fec92a96).
  - Burp Suite is a great GUI for intercepting and altering `HTTP` requests, but be warned: complex GUI applications run in a VM on 1 GM RAM are lagging at best.  Be prepared for 2 FPS.  Same can be said for the browser, I suppose.  I would like to save up for a machine with more RAM to allocate to my VM... 
  - FTB traffic is generally not encrypted.
  - [This](https://drt.sh/) is such a nice website.