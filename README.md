# Levelized Cost of Energy (LCOE) Analysis

## Overview
This repository contains MATLAB scripts and data for analyzing the **Levelized Cost of Energy (LCOE)** across different energy sources, including offshore wind and hydropower. The analysis includes sensitivity studies on **CAPEX, OPEX, inflation rate**, and **Monte Carlo simulations** for uncertainty quantification.

## Contents
- `documentation.mlx` – MATLAB Live Script explaining the LCOE methodology with examples.
- `calculateLCOE_switch.m` – Function to compute LCOE for different energy systems.
- `violin.m`, `violinplot.m` – Violin plot functions for visualizing LCOE distributions [1].
- `hydropower_lcoe.csv` – Data file containing hydropower cost parameters.

## Features
- Calculates **LCOE** using both simplified and year-by-year approaches.
- Analyzes the **impact of CAPEX, OPEX, and inflation** over time.
- Performs **Monte Carlo simulations** to evaluate LCOE uncertainties.
- Uses **violin plots** for graphical representation of results.

## Dependencies
This analysis requires:
- MATLAB (tested on R2023b)
- The **Violinplot-Matlab** package [1]
