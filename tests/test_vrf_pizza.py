import pytest
from brownie import VRF_Pizza, accounts, network, VRF_Pizza_RNG
import brownie

STATIC_SEED = 123


@pytest.fixture
def deploy_vrf_pizza_contract(get_account, get_pizza_jobid, chainlink_fee,
                              get_link_token, get_matic_usd_price_feed_address,
                              get_pizza_oracle, get_keyhash, get_vrf_coordinator):
    # Arrange / Act
    vrf_pizza = VRF_Pizza.deploy(get_link_token.address,
                                 get_matic_usd_price_feed_address,
                                 get_pizza_oracle,
                                 get_pizza_jobid,
                                 {'from': get_account})
    vrf_pizza_rng = VRF_Pizza_RNG.deploy(get_keyhash,
                                         get_vrf_coordinator,
                                         get_link_token,
                                         {'from': get_account})

    # Act
    vrf_pizza.set_pizza_rng_address(vrf_pizza_rng.address)
    vrf_pizza_rng.set_vrf_pizza_contract(vrf_pizza.address)

    # Assert
    assert vrf_pizza_rng is not None
    assert vrf_pizza is not None
    assert vrf_pizza.pizza_rng_address() == vrf_pizza_rng.address
    assert vrf_pizza_rng.vrf_pizza_contract() == vrf_pizza.address
    return vrf_pizza, vrf_pizza_rng


def test_vrf_pizza(deploy_vrf_pizza_contract):
    vrf_pizza, vrf_pizza_rng = deploy_vrf_pizza_contract
    # def test_create_pizza_reverts_on_not_enough_value():


def test_validate_order_low_money_with_link(deploy_vrf_pizza_contract, get_account, get_link_token, chainlink_fee):
    vrf_pizza, vrf_pizza_rng = deploy_vrf_pizza_contract
    get_link_token.transfer(vrf_pizza_rng.address,
                            chainlink_fee * 2, {'from': get_account})
    with brownie.reverts():
        vrf_pizza.order_pizza(STATIC_SEED, {'from': get_account})
    with brownie.reverts():
        vrf_pizza.order_pizza(
            STATIC_SEED, {'from': get_account, 'value': 49000000000000000000})


def test_validate_order_with_money_and_link(deploy_vrf_pizza_contract, get_account, get_link_token, chainlink_fee):
    vrf_pizza, vrf_pizza_rng = deploy_vrf_pizza_contract
    get_link_token.transfer(vrf_pizza_rng.address,
                            chainlink_fee * 2, {'from': get_account})
    vrf_pizza.order_pizza(
        STATIC_SEED, {'from': get_account, 'value': 51000000000000000000})


def test_getLatestPizzaPriceInMATIC(deploy_vrf_pizza_contract):
    vrf_pizza, vrf_pizza_rng = deploy_vrf_pizza_contract
    price = vrf_pizza.getLatestPizzaPriceInMATIC.call()
    assert price == 100000000
    pizza_price = vrf_pizza.view_matic_pizza_price.call()
    assert pizza_price == 50000000000000000000
