# arvicco-avalon

Helper scripts for Bitcoin mining units management...

## Description

Congrats, you've got a few Bitcoin miners. It's all nice and dandy, but now you need to keep an eye on them to make sure they are always online and their valuable hashes are not wasted. This set of scripts is written to do just that. You run a monitor script non-stop and it keeps an eye on your mining units, your (private) pool and your Internet connection, and alerts you in case of any problems. The scripts should work on OSX and Linux. Windows users, just spend $30 on Raspberry Pi, it's so much fun.

Initially, the scripts were used to manage an installation of Avalon miners, but they work just as well with any cgminer (or bfgminer) based device with known IP address and cgminer API enabled. It's been proven to work on such exotic devices as RPi attached to Block Eruptor Blades as well as normal computers with FPGA or GPU attached. So, you can easily monitor your mining zoo from one central location.

## Usage

Scripts:

    $ monitor [environment]

Monitors all the nodes (miners, pools, Internet connections) that are listed in config/monitor.yml file. Sounds alarm is anything is wrong with the monitored nodes. TODO: takes action to correct errors found (like restarting the failing miners etc).

    $ reset 145 146 192.168.0.150

Reboots your Avalon miners. Miners are indicated either by their full IP address or just by the last digits of this address (num). A quick and dirty way to reset misbehaving miners. In some cases of hungup units, soft reset is not enough and a hard powerdown/powerup is required.

    $ mtgox_tx

Transcodes raw transaction from base64 (mtgox) to hex (blockchain) format

## Script Installation

You need Ruby 1.9 to install the scripts. Once the Ruby is installed, it's just:

    $ gem install arvicco-avalon

You also need to enable cgminer API in your miners and create ~/.avalon/monitor.yml config file, see below.

## Monitor Configuration

Monitor script is periodically polling the mining units and other types of objects to be monitored (called Nodes). If any Node does not respond or returns an error, the monitor prints error message and sounds alert. You need to tell the monitor about your Miners and other Nodes to be polled via config file. Please note sample monitor config file for production environment below. Modify it, add your own Nodes to be monitored (for miners, you have to indicate their IP address and min hashrate in Gh/s):

    ------- ~/.avalon/monitor.yml --------
    # Prod configuration (default)
    prod:
      :alert_after: 2      # missed pings or status reports from a miner
      :alert_temp:  52     # degrees C and above
      :alert_sounds:
        :failure:       Glass.aiff                        # [] for no sound
        :restart:       Frog.aiff                         # [] for no sound
        :temp_high:     Ping.aiff                         # [] for no sound
        :block_found:   [Dog.aiff, Purr.aiff, Dog.aiff]   # [] for no sound
        :block_updated: [Purr.aiff, Purr.aiff, Purr.aiff] # [] for no alert sound
      :bitcoind:
        :ip: 192.168.1.13
        :rpcuser: jbond
        :rpcpassword: youcannotguessitdonteventry
      :monitor:
        :verbose: true
        :timeout: 30
        :nodes:
          - [miner, 192.168.1.151, 70] # type, ip, gh/s
          - [miner, 192.168.1.152, 70]
          - [internet, www.google.com, www.speedtest.net]
          - [eloipool, 192.168.1.13, 4] # frequency of old block updates (once per X polls)

## Miner/Node Configuration

The Mining units need to be configured so that monitor is able to poll them. Specifically you need to make cgminer API accessible from the IP address your Monitor script runs on. Normally, it is done by running cgminer with an option like: "--api-allow W:192.168.1.13" where 192.168.1.13 is IP address of your Monitor. For Avalon Miners, this can be configured via WebGui->CGminer Configuration->API Allow field.

Detailed description of cgminer API and relevant startup options can be found here:
https://github.com/ckolivas/cgminer/blob/master/API-README

For any Pool or Bitcoind nodes you'd like to monitor, you need to be able to ssh with public keys (that is, no password required) into this Node, otherwise the Monitor won't be able to poll it. How to make it work is beyond the scope of this Readme, just google 'ssh without password'.

## License

Copyright (c) 2013 Arvicco

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
