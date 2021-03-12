#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config, interface

STATIC_SEED = 123


def main():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    # Get the most recent PriceFeed Object
    vrf_pizza = VRF_Pizza[len(VRF_Pizza) - 1]
    interface.LinkTokenInterface(config['networks'][network.show_active()]['link_token']).transfer(
        vrf_pizza, config['networks'][network.show_active()]['fee'], {'from': dev})
    vrf_pizza.execute_solo('0xaa1dc356dc4b18f30c347798fd5379f3d77abc5b',
                           '6592206f9ffe45cdbe900f2e79d90b09',
                           100000000000000000, {'from': dev})
