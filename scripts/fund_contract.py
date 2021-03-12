#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config, interface

STATIC_SEED = 123


def main():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    # Get the most recent PriceFeed Object
    vrf_pizza_rng_contract = VRF_Pizza_RNG[len(VRF_Pizza_RNG) - 1]
    vrf_pizza = VRF_Pizza[len(VRF_Pizza) - 1]

    interface.LinkTokenInterface(config['networks'][network.show_active()]['link_token']).transfer(
        vrf_pizza_rng_contract, config['networks'][network.show_active()]['fee'], {'from': dev})
    interface.LinkTokenInterface(config['networks'][network.show_active()]['link_token']).transfer(
        vrf_pizza, config['networks'][network.show_active()]['fee'], {'from': dev})
