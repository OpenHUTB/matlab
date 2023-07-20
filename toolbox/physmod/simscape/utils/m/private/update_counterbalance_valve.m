function out=update_counterbalance_valve(hBlock)








    port_names={'B','P','L'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list={'mdl_type','opening_spec';
    'pres_set','p_set_diff';
    'or_area_max','area_max';
    'A_leak','area_leak';
    'area_tab','valve_area_TLU';
    'p_ratio','pilot_ratio';
    'or_C_d','Cd';
    'or_Re_cr','Re_c';
    'time_const','tau';
    'check_pres_crack','check_p_crack';
    'check_pres_max','check_p_max'};





    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'spring_cp';'or_opening_max';'pres_set';'opening_tab'});


    mdl_type=get_param(hBlock,'mdl_type');
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    or_lam_spec=get_param(hBlock,'or_lam_spec');
    or_Re_cr=get_param(hBlock,'or_Re_cr');
    or_B_lam=get_param(hBlock,'or_B_lam');
    check_lam_spec=get_param(hBlock,'check_lam_spec');
    check_Re_cr=get_param(hBlock,'check_Re_cr');
    check_B_lam=get_param(hBlock,'check_B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Pressure Control Valves/Counterbalance Valve (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[3,2,1]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'opening_dynamics','1');
    set_param(hBlock,'smoothing_factor','0');




    params=HtoIL_cellToStruct(params_for_derivation);
    evaluate=0;


    name='p_max_diff';
    math_expression='spring_cp*or_opening_max + pres_set';
    dialog_unit_expression='pres_set';
    p_max_diff=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},p_max_diff);


    name='p_diff_TLU';
    math_expression='spring_cp*opening_tab + pres_set';
    dialog_unit_expression='pres_set';
    p_diff_TLU=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},p_diff_TLU);



    warnings.messages={};

    warnings.messages{end+1,1}=['Opening time constant applied to control pressure instead of variable orifice control member displacement. '...
    ,'Adjustment of Opening time constant may be required.'];

    if strcmp(mdl_type,'2')
        if extrap_method~=2
            warnings.messages{end+1,1}=['Extrapolation method changed to Nearest. '...
            ,'Extension of Pressure differential vector and Opening area vector may be required.'];
        end
        if interp_method==2
            warnings.messages{end+1,1}=['Interpolation method changed to Linear. '...
            ,'Additional elements in the Pressure differential vector and Opening area vector may be required.'];
        end
    end

    if strcmp(or_lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(or_B_lam,'0.999')&&strcmp(check_lam_spec,'1')&&strcmp(check_B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds numbers set to 150. Behavior change not expected';
        else
            warnings.messages{end+1,1}='Critical Reynolds numbers set to 150.';
        end
    elseif strcmp(or_lam_spec,'2')&&(strcmp(check_lam_spec,'1')||~strcmp(or_Re_cr,check_Re_cr))

        warnings.messages{end+1,1}=['Critical Reynolds numbers set to ',or_Re_cr,'.'];
    end

    warnings.subsystem=getfullname(hBlock);

    if~isempty(warnings.messages)
        out.warnings=warnings;
    end

    out.connections=connections;
end