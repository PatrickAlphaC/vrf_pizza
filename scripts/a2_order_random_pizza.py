#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config, interface
import time

STATIC_SEED = 123


def order_pizza():
    dev = accounts.add(os.getenv(config['wallets']['from_key']))
    # Get the most recent PriceFeed Object
    vrf_pizza = VRF_Pizza[len(VRF_Pizza) - 1]
    vrf_pizza_rng_contract = VRF_Pizza_RNG[len(VRF_Pizza_RNG) - 1]
    print("VRF_PIZZA deployed to {}".format(vrf_pizza.address))
    print("VRF_PIZZA_RNG deployed to {}".format(vrf_pizza_rng_contract.address))
    price = vrf_pizza.view_matic_pizza_price()
    print("Current price is {}".format(price))
    # 0.999389532800000000
    vrf_pizza.order_pizza(
        STATIC_SEED, {'from': dev, 'value': price + 1000000000})
    # 'gas': 1000000000000000000
    # time.sleep(30)
    # vrf_pizza.execute_order_queue({'from': dev})
    # time.sleep(30)
    # print(vrf_pizza.pizza_response())
    # vrf_pizza.execute_solo({'from': dev})


def main():
    order_pizza()
