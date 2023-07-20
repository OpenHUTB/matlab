function out=update_valve_dir_3_way(hBlock)







    port_names={'A','S','P','T'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);





    param_list={'area_max_P_A','area_max_PA';
    'area_max_A_T','area_max_AT';
    'A_leak','area_leak';
    'area_tab','valve_area_TLU';
    'area_tab_P_A','valve_area_TLU_PA';
    'area_tab_A_T','valve_area_TLU_AT';
    'flow_rate_tab','vol_flow_TLU';
    'flow_rate_tab_P_A','vol_flow_TLU_PA';
    'flow_rate_tab_A_T','vol_flow_TLU_AT';
    'pressure_tab','p_diff_TLU';
    'pressure_tab_P_A','p_diff_TLU_PA';
    'pressure_tab_A_T','p_diff_TLU_AT';
    'C_d','Cd';
    'Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));



























    param_list_for_derivation=...
    {'mdl_type_identical'
'mdl_type_different'
'opening_max'
'opening_max_P_A'
'opening_max_A_T'
'area_max'
'area_max_P_A'
'area_max_A_T'
'A_leak'
'x_0_P'
'x_0_T'
'opening_area_tab'
'opening_area_tab_P_A'
'opening_area_tab_A_T'
'opening_flow_rate_tab'
'opening_flow_rate_tab_P_A'
'opening_flow_rate_tab_A_T'
'pressure_tab'
'pressure_tab_P_A'
'pressure_tab_A_T'
'area_tab'
    'flow_rate_tab'};

    params_for_derivation=HtoIL_collect_params(hBlock,param_list_for_derivation);



    lam_spec=eval(get_param(hBlock,'lam_spec'));
    B_lam=get_param(hBlock,'B_lam');
    area_spec=eval(get_param(hBlock,'area_spec'));
    if area_spec==1
        interp_method=eval(get_param(hBlock,'interp_method_identical'));
        extrap_method=eval(get_param(hBlock,'extrap_method_identical'));
    else
        interp_method=eval(get_param(hBlock,'interp_method_different'));
        extrap_method=eval(get_param(hBlock,'extrap_method_different'));
    end




    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Directional Control Valves/3-Way Directional Valve (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3,4]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    evaluate=1;


    params=HtoIL_cellToStruct(params_for_derivation);


    if area_spec==1
        valve_spec=params.mdl_type_identical;
    else
        valve_spec=params.mdl_type_different;
    end
    HtoIL_apply_params(hBlock,{'valve_spec'},valve_spec);
    valve_spec=eval(valve_spec.base);




    if valve_spec==2
        if area_spec==1
            params.opening_area_tab_end=HtoIL_get_vector_element(params.opening_area_tab,'last');
        else
            params.opening_area_tab_P_A_end=HtoIL_get_vector_element(params.opening_area_tab_P_A,'last');
            params.opening_area_tab_A_T_end=HtoIL_get_vector_element(params.opening_area_tab_A_T,'last');
        end
    elseif valve_spec==3
        if area_spec==1
            params.opening_flow_rate_tab_end=HtoIL_get_vector_element(params.opening_flow_rate_tab,'last');
        else
            params.opening_flow_rate_tab_P_A_end=HtoIL_get_vector_element(params.opening_flow_rate_tab_P_A,'last');
            params.opening_flow_rate_tab_A_T_end=HtoIL_get_vector_element(params.opening_flow_rate_tab_A_T,'last');
        end
    end



    name='S_max_PA';
    if valve_spec==1
        if area_spec==1
            math_expression='-x_0_P + opening_max';
        else
            math_expression='-x_0_P + opening_max_P_A';
        end
    elseif valve_spec==2
        if area_spec==1
            math_expression='-x_0_P + opening_area_tab_end';
        else
            math_expression='-x_0_P + opening_area_tab_P_A_end';
        end
    else
        if area_spec==1
            math_expression='-x_0_P + opening_flow_rate_tab_end';
        else
            math_expression='-x_0_P + opening_flow_rate_tab_P_A_end';
        end
    end
    dialog_unit_expression='x_0_P';
    S_max_PA=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'S_max_PA'},S_max_PA);
    params.S_max_PA=S_max_PA;



    name='S_max_AT';
    if valve_spec==1
        if area_spec==1
            math_expression='x_0_T - opening_max';
        else
            math_expression='x_0_T - opening_max_A_T';
        end
    elseif valve_spec==2
        if area_spec==1
            math_expression='x_0_T - opening_area_tab_end';
        else
            math_expression='x_0_T - opening_area_tab_A_T_end';
        end
    else
        if area_spec==1
            math_expression='x_0_T - opening_flow_rate_tab_end';
        else
            math_expression='x_0_T - opening_flow_rate_tab_A_T_end';
        end
    end
    dialog_unit_expression='x_0_T';
    S_max_AT=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'S_max_AT'},S_max_AT);
    params.S_max_AT=S_max_AT;










    name='del_S_max';
    math_expression='opening_max - opening_max/area_max*A_leak';
    dialog_unit_expression='opening_max';
    del_S_max=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'del_S_max'},del_S_max);


    name='del_S_max_PA';
    math_expression='opening_max_P_A - opening_max_P_A/area_max_P_A*A_leak';
    dialog_unit_expression='opening_max_P_A';
    del_S_max_PA=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'del_S_max_PA'},del_S_max_PA);


    name='del_S_max_AT';
    math_expression='opening_max_A_T - opening_max_A_T/area_max_A_T*A_leak';
    dialog_unit_expression='opening_max_A_T';
    del_S_max_AT=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'del_S_max_AT'},del_S_max_AT);



    del_S_TLU=params.opening_area_tab;
    del_S_TLU_first=HtoIL_get_vector_element(params.opening_area_tab,'first');
    del_S_TLU.base=['(',del_S_TLU.base,') - (',del_S_TLU_first.base,')'];
    HtoIL_apply_params(hBlock,{'del_S_TLU'},del_S_TLU);


    del_S_TLU_PA=params.opening_area_tab_P_A;
    del_S_TLU_P_first=HtoIL_get_vector_element(params.opening_area_tab_P_A,'first');
    del_S_TLU_PA.base=['(',del_S_TLU_PA.base,') - (',del_S_TLU_P_first.base,')'];
    HtoIL_apply_params(hBlock,{'del_S_TLU_PA'},del_S_TLU_PA);


    del_S_TLU_AT=params.opening_area_tab_A_T;
    del_S_TLU_T_first=HtoIL_get_vector_element(params.opening_area_tab_A_T,'first');
    del_S_TLU_AT.base=['(',del_S_TLU_AT.base,') - (',del_S_TLU_T_first.base,')'];
    HtoIL_apply_params(hBlock,{'del_S_TLU_AT'},del_S_TLU_AT);



    del_S_vol_flow_TLU=params.opening_flow_rate_tab;
    del_S_vol_flow_TLU_first=HtoIL_get_vector_element(params.opening_flow_rate_tab,'first');
    del_S_vol_flow_TLU.base=['(',del_S_vol_flow_TLU.base,') - (',del_S_vol_flow_TLU_first.base,')'];
    HtoIL_apply_params(hBlock,{'del_S_vol_flow_TLU'},del_S_vol_flow_TLU);


    del_S_vol_flow_TLU_PA=params.opening_flow_rate_tab_P_A;
    del_S_vol_flow_TLU_P_first=HtoIL_get_vector_element(params.opening_flow_rate_tab_P_A,'first');
    del_S_vol_flow_TLU_PA.base=['(',del_S_vol_flow_TLU_PA.base,') - (',del_S_vol_flow_TLU_P_first.base,')'];
    HtoIL_apply_params(hBlock,{'del_S_vol_flow_TLU_PA'},del_S_vol_flow_TLU_PA);


    del_S_vol_flow_TLU_AT=params.opening_flow_rate_tab_A_T;
    del_S_vol_flow_TLU_T_first=HtoIL_get_vector_element(params.opening_flow_rate_tab_A_T,'first');
    del_S_vol_flow_TLU_AT.base=['(',del_S_vol_flow_TLU_AT.base,') - (',del_S_vol_flow_TLU_T_first.base,')'];
    HtoIL_apply_params(hBlock,{'del_S_vol_flow_TLU_AT'},del_S_vol_flow_TLU_AT);



    warnings.messages={};

    if lam_spec==1&&valve_spec~=3

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end


    if area_spec==2


        params.pressure_tab.base='pressure_tab';
        params.area_tab.base='area_tab';
        params.flow_rate_tab.base='flow_rate_tab';
    end
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    valve_spec,interp_method,extrap_method,...
    params.pressure_tab,params.area_tab,params.flow_rate_tab,'ascending',...
    'Spool travel vector','Orifice area vector',...
    'Pressure drop vector','Volumetric flow rate table');

    if isempty(warnings.messages)
        warnings={};
    else
        warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;
    out.warnings=warnings;

end

