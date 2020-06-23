#! /usr/bin/env python3
"""UART qualification tests

The tester is a UART to Serial converter such as FTDI.

Pinout:
PHiLIP      USB to Serial Converter
DUT_RX ------------ TX
DUT_TX ------------ RX
DUT_CTS ----------- RTS
DUT_RTS ----------- CTS
"""

import pytest


def test_echo(record_property):
    """Tests basic echo in different modes"""
    pass

def main():
    """Main program"""
    print(__doc__)


if __name__ == '__main__':
    main()
