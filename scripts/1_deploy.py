#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config


def main():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    vrf_pizza = VRF_Pizza.deploy(
        config['networks'][network.show_active()]['link_token'],
        config['networks'][network.show_active()]['matic_usd_price_feed'],
        config['networks'][network.show_active()]['oracle'],
        config['networks'][network.show_active()]['pizza_jobId'],
        {'from': dev})
    vrf_pizza_rng = VRF_Pizza_RNG.deploy(
        config['networks'][network.show_active()]['keyhash'],
        config['networks'][network.show_active()]['matic_usd_price_feed'],
        config['networks'][network.show_active()]['oracle'],
        config['networks'][network.show_active()]['pizza_jobId'],


    vrf_pizza_rng=VRF_Pizza_RNG.deploy(get_keyhash,
                                         get_vrf_coordinator,
                                         get_link_token,
                                         {'from': get_account})
