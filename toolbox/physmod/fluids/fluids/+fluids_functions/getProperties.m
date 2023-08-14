function[T_TLU,p_TLU,pT_valid_TLU,rho_TLU,alpha_TLU,beta_TLU,u_TLU,...
    cp_TLU,k_TLU,nu_TLU,mu_TLU,Pr_TLU,T_min,T_max,p_min,p_max,k_cv]=...
    getProperties(fluid_list,concentration_param_EG,concentration_param_PG,...
    c_mass_SW,c_mass_EG,c_mass_PG,c_mass_GL,c_vol_EG,...
    c_vol_PG,beta_const_EG,beta_const_PG,beta_const_GL,...
    p_min_EG,p_min_PG,p_min_GL,p_max_EG,p_max_PG,p_max_GL,...
    p_atm)


















































    switch fluid_list

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.water
        properties=fluids_functions.WaterProperties;

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.mitsw
        properties=fluids_functions.MITSWProperties(c_mass_SW);

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.ethylene_glycol
        properties=fluids_functions.EthyleneGlycolProperties(concentration_param_EG,c_mass_EG,c_vol_EG,beta_const_EG,p_min_EG,p_max_EG,p_atm);

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.propylene_glycol
        properties=fluids_functions.PropyleneGlycolProperties(concentration_param_PG,c_mass_PG,c_vol_PG,beta_const_PG,p_min_PG,p_max_PG,p_atm);

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.glycerol
        properties=fluids_functions.GlycerolProperties(c_mass_GL,beta_const_GL,p_min_GL,p_max_GL,p_atm);

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.jet_A
        properties=fluids_functions.JetAProperties;

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.diesel
        properties=fluids_functions.DieselProperties;

    case fluids.thermal_liquid.utilities.enum.thermal_liquid_fluid_list.sae5w30
        properties=fluids_functions.SAE5W30Properties;

    otherwise
    end

    T_TLU=properties.T_TLU;
    p_TLU=properties.p_TLU.*1e-6;
    pT_valid_TLU=properties.pT_validity_TLU;
    rho_TLU=properties.rho_TLU;
    alpha_TLU=properties.alpha_TLU;
    beta_TLU=properties.beta_TLU.*1e-9;
    u_TLU=properties.u_TLU.*1e-3;
    cp_TLU=properties.cp_TLU.*1e-3;
    k_TLU=properties.k_TLU.*1e3;
    nu_TLU=properties.nu_TLU.*1e6;
    mu_TLU=properties.mu_TLU.*1e3;
    Pr_TLU=properties.Pr_TLU;
    T_min=properties.T_min;
    T_max=properties.T_max;
    p_min=properties.p_min.*1e-6;
    p_max=properties.p_max.*1e-6;



    p_typical=p_atm*1e-6;
    T_typical=min(max(293.15,T_min),T_max);
    [T_grid,p_grid]=meshgrid(T_TLU,p_TLU);
    k_typical=interp2(T_grid,p_grid,k_TLU',T_typical,p_typical,'linear');
    cp_typical=interp2(T_grid,p_grid,cp_TLU',T_typical,p_typical,'linear');
    k_cv=k_typical/cp_typical*1e-6;

end