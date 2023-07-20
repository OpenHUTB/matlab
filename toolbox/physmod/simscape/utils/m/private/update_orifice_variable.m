function out=update_orifice_variable(hBlock)








    port_names={'S','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'mdl_type','variable_orifice_spec';
    'A_leak','area_leak';
    'C_d','Cd';
    'Re_cr','Re_c';
    'area_tab','orifice_area_TLU';
    'pressure_tab','p_diff_TLU';
    'flow_rate_tab','vol_flow_TLU'};







    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'or';'x_0';'opening_max';'area_max';'A_leak';'opening_tab'});
    beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate';'pressure_drop'},'sh_lib/Orifices/Variable Orifice');
    beginning_variable_names={'Volumetric flow rate';'Pressure drop'};

    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    mdl_type=eval(get_param(hBlock,'mdl_type'));
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    pressure_tab=HtoIL_collect_params(hBlock,{'pressure_tab'});
    area_tab=HtoIL_collect_params(hBlock,{'area_tab'});
    vol_flow_tab=HtoIL_collect_params(hBlock,{'flow_rate_tab'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);




    params=HtoIL_cellToStruct(params_for_derivation);


    params.open_sign=params.or;
    params.open_sign.name='open_sign';
    if strcmp(params.or.base,'1')

        set_param(hBlock,'open_orientation','1');
        open_sign=1;
    else
        params.open_sign.base='-1';
        set_param(hBlock,'open_orientation','-1');
        open_sign=-1;
    end

    evaluate=1;


    name='S_min';


    if open_sign==1
        math_expression='opening_max/area_max*A_leak - x_0';
    else
        math_expression='-opening_max/area_max*A_leak + x_0';
    end
    dialog_unit_expression='opening_max/area_max*A_leak';
    S_min=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'S_min'},S_min);
    params.S_min=S_min;








    name='S_max';


    if open_sign==1
        math_expression='-x_0 + opening_max';
    else
        math_expression='x_0 - opening_max';
    end
    dialog_unit_expression='opening_max';
    S_max=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    params.S_max=S_max;


    name='del_S';


    if open_sign==1
        math_expression='S_max - S_min';
    else
        math_expression='-S_max + S_min';
    end
    dialog_unit_expression='S_min';
    del_S=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'del_S'},del_S);



    name='x0_in_opening_tab_units';
    math_expression='x_0';
    dialog_unit_expression='opening_tab';
    x0_in_opening_tab_units=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,0);

    S_TLU=params.opening_tab;
    if open_sign==1
        S_TLU.base=[params.opening_tab.base,' - ',x0_in_opening_tab_units.base];
    else
        S_TLU.base=['-(',params.opening_tab.base,') + ',x0_in_opening_tab_units.base];
    end
    if strcmp('runtime',{params.opening_tab.conf,params.x_0.conf})
        S_TLU.conf='runtime';
    else
        S_TLU.conf='compiletime';
    end
    HtoIL_apply_params(hBlock,{'S_TLU'},S_TLU);


    HtoIL_apply_params(hBlock,{'S_vol_flow_TLU'},S_TLU);



    warnings.messages={};



    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);


    if mdl_type~=3&&strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end



    increase_decrease_str='ascending or descending';
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    mdl_type,interp_method,extrap_method,...
    pressure_tab,area_tab,vol_flow_tab,increase_decrease_str,...
    'Control member position vector','Orifice area vector',...
    'Pressure drop vector','Volumetric flow rate table');

    if~isempty(warnings.messages)
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end

    out.connections=connections;

end