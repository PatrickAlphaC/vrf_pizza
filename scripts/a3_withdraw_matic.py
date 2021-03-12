#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config, interface

STATIC_SEED = 123


def main():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    # Get the most recent PriceFeed Object
    vrf_pizza = VRF_Pizza[len(VRF_Pizza) - 1]
    vrf_pizza.withdraw(4000000000000000000, {'from': dev})
