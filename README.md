# Avalon

Helper scripts for Bitcoin and Avalon miners management...

## Usage

Scripts:

$ bin/monitor [last_ip]

- Monitors all miners from 151 to last_ip (default 182)

$ mtgox_tx

- Transcodes raw transaction from base64 (mtgox) to hex (blockchain) format

## Configuration

Sample monitor config file for production environment below. Modify it, add your own nodes to be monitored.

------- config/monitor.yml --------
# Prod configuration
prod:
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
