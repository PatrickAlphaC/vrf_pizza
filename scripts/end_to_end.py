#!/usr/bin/python3
import os
from brownie import VRF_Pizza, VRF_Pizza_RNG, accounts, network, config, interface
from .a1_deploy import deploy_pizza_contracts
from .a2_order_random_pizza import order_pizza


def main():
    end_to_end()


def end_to_end():
    vrf_pizza, vrf_pizza_rng = deploy_pizza_contracts()
    order_pizza()
