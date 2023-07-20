function out=update_pressure_red_3_way(hBlock)








    param_list={'valve_area_spec','opening_spec';
    'p_diff_reduce_TLU','p_diff_reducing_TLU';
    'area_reduce_TLU','valve_area_reducing_TLU';
    'p_diff_relief_TLU','p_diff_relief_TLU';
    'area_relief_TLU','valve_area_relief_TLU';
    'max_area','area_max';
    'pressure_setting','p_set_differential'
    'reg_range','p_range';
    'transition_pressure','p_tran';
    'C_d','Cd';
    'leak_area','area_leak';
    'Re_cr','Re_c';
    'dynamic','opening_dynamics'};











    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    dynamic=get_param(hBlock,'dynamic');
    valve_area_spec=get_param(hBlock,'valve_area_spec');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Pressure Control Valves/Pressure-Reducing 3-Way Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    warnings.messages={};

    if strcmp(dynamic,'1')
        warnings.messages={'Initial reducing valve area and Initial relief valve area removed. Adjustment of model initial conditions may be required.';
        'Opening time constant applied to control pressure instead of valve areas. Adjustment of the time constant may be required.'};
    end

    if strcmp(valve_area_spec,'1')
        warnings.messages{end+1,1}=['Valve opening adjustment coefficient for smoothing removed. Adjustment of Opening dynamics time constant '...
        ,'or additional elements in the vectors used in the Tabulated data Opening parameterization may be required for numerical smoothing.'];
    end

    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end

    if~isempty(warnings.messages)
        warnings.subsystem=getfullname(hBlock);
    else
        warnings={};
    end

    out.warnings=warnings;

end