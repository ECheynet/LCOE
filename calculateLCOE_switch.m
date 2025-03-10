function lcoe = calculateLCOE_switch(I, M, Fuel, E, r_nominal, ir, n)
    % calculateLCOE_switch computes the Levelized Cost of Energy (LCOE) using two methods:
    %  (1) "Simplified" approach if all inputs (I, M, Fuel, E) are scalars.
    %  (2) "Year-by-year" approach if any of these inputs are 1xN vectors.
    %
    % Inputs:
    %   I       - CAPEX (initial cost or annualized capital cost). Either a scalar or a 1xN vector (EUR, $, etc.).
    %   M       - Maintenance cost (or variable OPEX). Either a scalar or a 1xN vector.
    %   Fuel    - Fuel expenditure. Either a scalar or a 1xN vector.
    %   E       - Annual energy production (AEP). Either a scalar or a 1xN vector.
    %   r_nominal - Nominal discount rate (e.g., 0.05 = 5%).
    %   ir      - Inflation rate (e.g., 0.02 = 2%).
    %   n       - Number of years (project lifetime).
    %
    % Output:
    %   lcoe - Levelized Cost of Energy (same currency unit as I, M, and Fuel per unit of E, e.g., $/MWh, €/MWh).
    %
    % Assumptions:
    %   - If I is a vector, it represents annual capital expenditures rather than a one-time CAPEX.
    %   - The discount rate is adjusted for inflation using the Fisher equation.
    %   - Yearly costs and energy production are discounted using the real discount rate.

    % Compute real discount rate (r_real) using the Fisher equation:
    % This corrects the nominal discount rate for inflation.
    r_real = (1 + r_nominal) ./ (1 + ir) - 1;

    % ---- Determine if we use the simplified or detailed approach ----
    % If all inputs (I, M, Fuel, E) are scalars, use the simplified LCOE formula.
    allScalar = isscalar(I) && isscalar(M) && isscalar(Fuel) && isscalar(E);

    if allScalar
        % Capital Recovery Factor (CRF) for spreading CAPEX over n years:
        CRF = (r_real * (1 + r_real)^n) / ((1 + r_real)^n - 1);

        % Simplified LCOE calculation:
        lcoe = (I * CRF + (M + Fuel)) / E;
    else
        %% --------------------------------------------------
        %  (2) Detailed LCOE formula (year-by-year)
        %
        %     LCOE = sum( Costs(t) / (1 + r)^t ) / sum( Energy(t) / (1 + r)^t )
        %
        %     If I, M, Fuel, and E are 1xN arrays, they represent annual values.

        % Define time indices from year 1 to n
        t = 1:n;

        % Compute discount factors for each year
        % (ensuring column vector format for element-wise division)
        discountFactor = (1 + r_real(:)) .^ t(:);

        % Compute the total discounted costs
        totalCosts = sum((I + M + Fuel) ./ discountFactor);

        % Compute the total discounted energy production
        totalElectricity = sum(E ./ discountFactor);

        % Compute final LCOE
        lcoe = totalCosts / totalElectricity;
    end
end
