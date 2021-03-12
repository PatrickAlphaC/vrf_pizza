#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config, interface


def fund_contracts():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    # Get the most recent PriceFeed Object
    vrf_pizza_rng = VRF_Pizza_RNG[len(VRF_Pizza_RNG) - 1]
    vrf_pizza = VRF_Pizza[len(VRF_Pizza) - 1]
    interface.LinkTokenInterface(config['networks'][network.show_active()]['link_token']).transfer(
        vrf_pizza_rng, config['networks'][network.show_active()]['fee'], {'from': dev})
    interface.LinkTokenInterface(config['networks'][network.show_active()]['link_token']).transfer(
        vrf_pizza, config['networks'][network.show_active()]['fee'], {'from': dev})


def deploy_pizza_contracts():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    vrf_pizza = VRF_Pizza.deploy(
        config['networks'][network.show_active()]['link_token'],
        config['networks'][network.show_active()]['matic_usd_price_feed'],
        config['networks'][network.show_active()]['oracle'],
        config['networks'][network.show_active()]['pizza_jobId'],
        config['networks'][network.show_active()]['usd_pizza_price'],
        config['networks'][network.show_active()]['fee'],
        {'from': dev})
    vrf_pizza_rng = VRF_Pizza_RNG.deploy(
        config['networks'][network.show_active()]['keyhash'],
        config['networks'][network.show_active()]['vrf_coordinator'],
        config['networks'][network.show_active()]['link_token'],
        config['networks'][network.show_active()]['fee'],
        {'from': dev})
    vrf_pizza.set_pizza_rng_address(vrf_pizza_rng.address, {'from': dev})
    vrf_pizza_rng.set_vrf_pizza_contract(vrf_pizza.address, {'from': dev})
    fund_contracts()
    return vrf_pizza, vrf_pizza_rng


def main():
    deploy_pizza_contracts()
