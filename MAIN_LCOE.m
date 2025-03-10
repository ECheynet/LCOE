clearvars;close all;clc;

%% Test of an offshore wind farm
% Data source: https://guidetoanoffshorewindfarm.com/wind-farm-costs
% Given constants
CAPEX = 2.37e6; % in €/MW
OPEX = 76000; % in €/MW/year
r_nominal = 0.06; % nominal discount rate (not corrected for inflation) 
N= 27; % lifespan
Fuel = 0; % no fuel for a wind farm
E = 4471; % MWh/year/MW
ir= 0; % inflation rate

lcoe = calculateLCOE_switch(CAPEX, OPEX, Fuel, E, r_nominal, ir, N);
fprintf('LCOE without inflation is %2.0f €/MWh \n',lcoe);

%% Influence of CAPEX and OPEX on LCOE
year = 2010:1:2050;
r_nominal = 0.06; % nominal discount rate (not corrected for inflation) 
clear CAPEX
% we assume that the CAPEX decreases by 2.5% per year
for ii=1:numel(year)
    CAPEX(ii) = 5000*(1-0.025)^(ii-1); % $/kW
end
% we assume OPEX is 3% of CAPEX (per year)
OPEX = 0.03*CAPEX; % $/kW
Fuel = 0; % no fuel for a wind farm
CF = linspace(0.4,0.55,numel(year)); % we assume that the CF increase progressively every year
E = 8760*CF; % CF of 51%
N= 27; % lifespan
clear lcoe

ir = linspace(0,0.05,5); % inflation rate
lcoe = zeros(numel(year),numel(ir));

clear leg
for jj=1:numel(ir)
    leg{jj} = sprintf('inflation rate = %0.2f %% ',100*ir(jj));
    for ii=1:numel(year)
        lcoe(ii,jj) = calculateLCOE_switch(CAPEX(ii), OPEX(ii), Fuel, E(ii), r_nominal, ir(jj), N);
    end
end

figure
plot(year,lcoe*1000)
xlabel('year')
ylabel('LCOE (€/MWh)')
grid minor
legend(leg{:})
set(gcf,'color','w')
set(findall(gcf,'-property','FontSize'),'FontSize',14,'FontName','Times')

%% Influence of the inflation on the LCOE

clear lcoe
for ii=1:numel(ir),
    lcoe(ii) = calculateLCOE_switch(CAPEX, OPEX, Fuel, E, r_nominal, ir(ii), N);
end

figure
plot(ir*100,lcoe)
xlabel('Inflation rate (%)')
ylabel('LCOE (€/MWh)')
grid minor
set(gcf,'color','w')
set(findall(gcf,'-property','FontSize'),'FontSize',14,'FontName','Times')
%% Test of a hydropower plant
% Source: https://tbccapital.ge/static/file/202306214500-bag-tbc-capital-levelized-cost-of-electricity-report-jun-2023.pdf

% Simplified equation
CAPEX = 500*1e6/140; % in €/MW
OPEX = 120*1e6/30/140; % in €/MW/year
r_nominal = 0.12; % nominal discount rate (not corrected for inflation) 
ir = 0.00; % inflation rate
N= 33; % lifespan
Fuel = 0; % no fuel for a wind farm
E = 16.5*1e6/N/140; % MWh/year/MW
lcoe = calculateLCOE_switch(CAPEX, OPEX, Fuel, E, r_nominal, ir, N);
fprintf('LCOE of hydroPower plant is %2.0f $/MWh \n',lcoe);

% Full equation
T = readtable('hydropower_lcoe.csv','VariableNamingRule','modify');
N = numel(T.Year);
lcoe = calculateLCOE_switch(T.CAPEX_millionUSD*1e6/140, T.OPEX_millionUSD*1e6/140,zeros(N,1), T.Output_Twh*1e6/140, T.discountRate, zeros(N,1), N);
fprintf('LCOE of hydroPower plant is %2.0f $/MWh \n',lcoe);
set(findall(gcf,'-property','FontSize'),'FontSize',14,'FontName','Times')
%% Monte Carlo Simulation
% Data source: https://www.lazard.com/media/xemfey0k/lazards-lcoeplus-june-2024-_vf.pdf
% This file defines the INPUT structure with data for a Monte Carlo simulation
% to account for uncertainties in CAPEX, OPEX, and Capacity Factor.
% All CAPEX and OPEX values are converted to $/MW and $/MW/year respectively.

clear INPUT

% Number of Monte Carlo iterations per technology
N_iter = 2000;

% Common discount rate and inflation
r_nominal = 0.07; % Nominal discount rate (e.g., 6%)
ir = 0.00;        % Inflation rate

% Define INPUT structure (parameters are in $/MW, $/MW/year, etc.)


% Geothermal
INPUT.Geothermal.CAPEX = [4860000,6280000]; % $/MW (converted from $1,300–$1,900 per kW)
INPUT.Geothermal.OPEX  = [24500,40000];      % $/MW/year (converted from $24.50–$40.00 per kW/year)
INPUT.Geothermal.CF    = [0.80,0.90];         % Capacity Factor (decimal)
INPUT.Geothermal.N     = 25;                   % Lifespan in years
INPUT.Geothermal.Fuel  = 0;                    % $/MMBTU


% Wind Onshore
INPUT.windOnshore.CAPEX = [1300000, 1900000]; % $/MW (converted from $1,300–$1,900 per kW)
INPUT.windOnshore.OPEX  = [24500, 40000];      % $/MW/year (converted from $24.50–$40.00 per kW/year)
INPUT.windOnshore.CF    = [0.30, 0.55];         % Capacity Factor (decimal)
INPUT.windOnshore.N     = 30;                   % Lifespan in years
INPUT.windOnshore.Fuel  = 0;                    % $/MMBTU

% Wind Offshore
INPUT.windOffshore.CAPEX = [3750000, 5750000];   % $/MW (converted from $3,750–$5,750 per kW)
INPUT.windOffshore.OPEX  = [60000, 91500];        % $/MW/year (converted from $60.00–$91.50 per kW/year)
INPUT.windOffshore.CF    = [0.45, 0.55];           % Capacity Factor (decimal)
INPUT.windOffshore.N     = 30;                   % Lifespan in years
INPUT.windOffshore.Fuel  = 0;                    % $/MMBTU

% Solar PV
INPUT.solarPV.CAPEX = [850000, 1400000];          % $/MW (converted from $850–$1,400 per kW)
INPUT.solarPV.OPEX  = [11000, 14000];             % $/MW/year (converted from $11.00–$14.00 per kW/year)
INPUT.solarPV.CF    = [0.15, 0.30];               % Capacity Factor (decimal)
INPUT.solarPV.N     = 35;                         % Lifespan in years
INPUT.solarPV.Fuel  = 0;                          % $/MMBTU

% Nuclear
INPUT.Nuclear.CAPEX = [8765000, 14400000];        % $/MW (converted from $8,765–$14,400 per kW)
INPUT.Nuclear.OPEX  = [140000, 163000];           % $/MW/year (converted from $140.00–$163.00 per kW/year)
INPUT.Nuclear.CF    = [0.89, 0.92];               % Capacity Factor (decimal)
INPUT.Nuclear.N     = 40;                         % Lifespan in years
INPUT.Nuclear.Fuel  = 8.88;                       % $/MWh

% List of technologies to simulate
techList = {'Geothermal','windOnshore','windOffshore','solarPV','Nuclear'};
nTech = numel(techList);

% Preallocate matrix to store simulation LCOE values
LCOE_sim = zeros(N_iter, nTech);

%% Monte Carlo Simulation Loop
for t = 1:nTech
    tech = techList{t};
    
    % Extract parameters for the current technology
    capex_range = INPUT.(tech).CAPEX;
    opex_range = INPUT.(tech).OPEX;
    cf_range   = INPUT.(tech).CF;
    lifespan   = INPUT.(tech).N;
    fuel_cost  = INPUT.(tech).Fuel;
    
    for ii = 1:N_iter
        % Sample uniformly for CAPEX, OPEX, and Capacity Factor
        CAPEX_sample = unifrnd(capex_range(1), capex_range(2));
        OPEX_sample  = unifrnd(opex_range(1), opex_range(2));
        CF_sample    = unifrnd(cf_range(1), cf_range(2));
        
        % Compute annual energy production (MWh/year per MW)
        % Assuming 8760 hours per year.
        E_sample = 8760 * CF_sample; % MWh/MW
        FUEL = fuel_cost*E_sample; % to convert into $/MW only

        % Calculate LCOE using the provided function (discounting costs over lifespan)
        lcoe_val = calculateLCOE_switch(CAPEX_sample, OPEX_sample, FUEL, E_sample, r_nominal, ir, lifespan);
        
        % Store the LCOE value (units: €/MWh)
        LCOE_sim(ii, t) = lcoe_val;
    end
end
%% Plot the LCOE with Error Bars (IQR)
figure('position',[500 500 800 400]);
violinplot(LCOE_sim, techList,'MarkerSize',5);
ylabel('LCOE ($/MWh)');
grid on;
ylim([0 200]);
set(gcf, 'color', 'w');
grid minor
set(findall(gcf,'-property','FontSize'),'FontSize',14,'FontName','Times')