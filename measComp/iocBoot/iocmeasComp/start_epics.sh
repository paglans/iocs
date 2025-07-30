#!/bin/bash
medm -x -macro "P=E1608:, R=E1608_1:" measCompTop.adl & # E1608_module.adl &
../../bin/linux-x86_64/measComp st.cmd

