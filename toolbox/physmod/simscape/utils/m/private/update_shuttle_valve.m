function out=update_shuttle_valve(hBlock)








    param_list={'pres_crack','p_open_A1B';
    'C_d','Cd';
    'A_leak','area_leak';
    'Re_cr','Re_c';
    'dynamic','opening_dynamics'};










    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'pres_crack';'pres_op'});


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    dynamic=get_param(hBlock,'dynamic');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Directional Control Valves/Shuttle Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    params=HtoIL_cellToStruct(params_for_derivation);
    math_expression='pres_crack + pres_op';
    dialog_unit_expression='pres_crack';
    evaluate=1;
    p_open_AB=HtoIL_derive_params('p_open_AB',math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'p_open_AB'},p_open_AB);



    warnings.messages={};

    if strcmp(dynamic,'1')
        warnings.messages={'Initial area at port A removed. Adjustment of model initial conditions may be required.';
        'Opening time constant is applied to control pressure instead of valve area. Adjustment of Opening time constant may be required.'};
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