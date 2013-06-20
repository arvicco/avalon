# Avalon

Helper scripts for Bitcoin and Avalon miners management...

## Description

Congrats, you've got a few Avalon miners. It's all nice and dandy, but now you need to keep an eye on them to make sure they are always online and their valuable hashes are not wasted. This set of scripts is written to do just that. You run a monitor scipt non-stop and it keeps an eye on your Avalons, your (private) pool and your Internet connection, and alerts you as soon as there are any problems. The scripts should work on OSX and Linux (Windows users, move on).

## Usage

Scripts:

    $ monitor [environment]

- Monitors all the nodes (miners, pools, Internet connections) that are listed in config/monitor.yml file. Sounds alarm is anything is wrong with the monitored nodes. TODO: takes action to correct errors found (like restarting the failing miners etc).

    $ mtgox_tx

- Transcodes raw transaction from base64 (mtgox) to hex (blockchain) format

## Installation

You need Ruby 1.9 to install the scripts. Once the Ruby is installed, it's just:

    $ gem install arvicco-avalon

You need to be able to ssh with public keys (that is no password required) into any Pool or Bitcoind node for monitor to work. How to do it is beyound the scope of this Readme, just google it. You also need to create ~/.avalon/monitor.yml config file, see below.

## Configuration

Sample monitor config file for production environment below. Modify it, add your own nodes to be monitored (for Avalon miners, you have to indicate their IP address and min hashrate in Gh/s):

    ------- ~/.avalon/monitor.yml --------
    # Prod configuration (default)
    prod:
      :alert_after: 2      # missed pings or status reports from a miner
      :alert_sound: :aiff  # :none for silent alerts
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
          - [eloipool, 192.168.1.13, 4] # frequency of old block updates (once per X polls)
          - [internet, www.google.com, www.speedtest.net]

## License

Copyright (c) 2013 Arvicco

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
