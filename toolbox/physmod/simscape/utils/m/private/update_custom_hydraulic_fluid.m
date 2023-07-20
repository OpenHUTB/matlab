function out=update_custom_hydraulic_fluid(hBlock)





    param_list={'density','rho_L_atm';
    'bulk','beta_L_atm';
    'viscosity_kin','nu_atm';
    'alpha','air_fraction'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)')


    port_location=get_param(hBlock,'orientation');
    if strcmp(port_location,'left')
        set_param(hBlock,'BlockRotation',0)
        set_param(hBlock,'BlockMirror','on')
    elseif strcmp(port_location,'right')
        set_param(hBlock,'BlockRotation',0)
        set_param(hBlock,'BlockMirror','off')
    end


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);

    out=struct;

end

