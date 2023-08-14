function out=update_check_valve_po(hBlock)








    param_list={'pres_crack','p_crack_differential';...
    'pres_max','press_max_differential';...
    'p_ratio','pilot_ratio';...
    'A_leak','area_leak';
    'C_d','Cd'
    'Re_cr','Re_c';
    'dynamic','opening_dynamics'};










    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    pressure_spec=eval(get_param(hBlock,'pressure_spec'));


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    dynamic=get_param(hBlock,'dynamic');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Directional Control Valves/Pilot-Operated Check Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    if pressure_spec==1

        set_param(hBlock,'pressure_spec','2')
    else

        set_param(hBlock,'pressure_spec','1')
    end


    warnings.messages={};

    if strcmp(dynamic,'1')
        warnings.messages={'Initial area removed. Adjustment of model initial conditions may be required.';
        'Opening time constant applied to control pressure instead of valve area. Adjustment of Opening time constant may be required.'};
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