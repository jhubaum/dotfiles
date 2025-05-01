# Directory structure
- dotfiles: Files that are linked as hidden files to home directory
- configs: Folders that are symlinked to `~/.config` directory
- bin: Scripts to work with this repo
- scripts: Scripts available on the entire shell after this repo is installed

# Tools and docs to setup the system after a fresh installation
## Checklist to recreate the setup
- Install the base system
- Configure internet connection (see section below)
- Remove the repository referencing the dvd from `/etc/apt/sources.list`
- Run `apt update ; apt upgrade`
- Install tools to execute the installation script: `apt install git sudo`
- Add myself to sudoers group (`usermod -aG sudo johannes`)
- Log out from root user and log in as normal user
- Clone this repo  (ssh). TODO: Do I need to set up ssh keys for github?
- Run `bin/install`
- Run `bin/symlink`
- Log out and in again to update shell config
- Concratulations, you have a fully functional system now.  
  There are, however, a few steps you currently need to perform manually

### Manual steps after installation
- Install spotify: https://www.spotify.com/us/download/linux/
- Install neovim. Current version in Debian repository is old, visit Github release page instead
- Setup thunderbird and firefox (details below)  
  - TODO: I can probably upload the config files directly to this repo. Figure out how
- Install Obsidian (https://obsidian.md/download)

## Setup the internet connection
### On a tower (i.e only using Lan)
Find out the interface name for your ether connection using `ip addr`. Let's say it's called `enp3s0`.
Configure the network interface by adding the following to `/etc/networks/interfaces`:
```
# The primary network interface
allow-hotplot enp3s0
iface enp3s0 inet dhcp
```
Run `ifdown enp3s0 ; ifup enp3s0` to restart the network interface. Ping Google (or any other page)
to make sure everything works.

### On my notebook
- Setup ethernet connection as above
- For Thinkpad X220: Install Wifi driver  
  - Make sure apt repositories include `contrib non-free`
  - `sudo apt-get install firmware-iwlwifi`
  - Restart notebook. `sudo iwconfig` should now show a network device with a wifi interface
- Install networkmanager  
  - `sudo apt-get install wireless-tools net-tools network-manager network-manager-gnome`
  - `sudo systemctl enable NetworkManager.service`
  - TODO: There might be a more lightweight way to handle wifi. Also, moving these commands to a script would be nice.

### Configure firefox with optimal privacy settings
1. In preferences / Pricacy & Security
   a. Set tracking Protection to strict
   b. Use custom settings of history and always use private browsing mode
   c. If you've already used the installation for something clear history and stored cookies
   d. Remove suggestions for browsing history, bookmarks and open tabs from address bar
   e. Permissions
      For location, camera, microphone, notifications
      go into settings and tick "Block new requestt asking to access your location"
   f. Security: Untick "Block dangerous and deceptive content"
   g. Enable HTTPS everywhere
2. Search
   a. Select DuckDuckGo as default search engine
   b. Untick "Provide search suggestions"
3. Home
   a. Select "Blank Page" for Homepage and new tabs
   b. Untick everything from Firefox Home Content

These were all visible settings. Edit config stuff:
- Go to about:config and change the following settings
  (privacytools.io has compiled a list of settings to change)
  https://privacytools.io/

  (still need TODO this)

Install these plugins:
- ublock Origin
- DF YouTube
- uMatrix

TODO Go through settings for installed addons
