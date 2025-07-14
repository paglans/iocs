#!/bin/bash
medm -x -macro "P=6013ANDOR1:, R=cam1:" Andor.adl &
../../bin/linux-x86_64/ikonL936 st.cmd
pause

