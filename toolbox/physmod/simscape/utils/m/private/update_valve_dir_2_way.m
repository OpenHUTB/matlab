function out=update_valve_dir_2_way(hBlock)










    param_list={'mdl_type','valve_spec';
    'opening_max','del_S_max';
    'A_leak','area_leak';
    'C_d','Cd';
    'Re_cr','Re_c';
    'area_tab','orifice_area_TLU';
    'opening_tab','del_S_TLU';
    'opening_tab','del_S_vol_flow_TLU';
    'pressure_tab','p_diff_TLU';
    'flow_rate_tab','vol_flow_TLU'};







    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,{'x_0';'opening_max';'area_max';'A_leak';'opening_tab'});

    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');
    mdl_type=eval(get_param(hBlock,'mdl_type'));
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    pressure_tab=HtoIL_collect_params(hBlock,{'pressure_tab'});
    area_tab=HtoIL_collect_params(hBlock,{'area_tab'});
    vol_flow_tab=HtoIL_collect_params(hBlock,{'flow_rate_tab'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Directional Control Valves/2-Way Directional Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);




    evaluate=1;


    params=HtoIL_cellToStruct(params_for_derivation);



    if mdl_type==1
        name='S_min';

        math_expression='opening_max/area_max*A_leak - x_0';
        dialog_unit_expression='opening_max/area_max*A_leak';
        S_min=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        params.S_min=S_min;
    end





    if mdl_type~=1
        opening_tab_end=params.opening_tab;

        opening_tab_end.name='opening_tab_max';
        opening_tab_value=str2num(params.opening_tab.base);%#ok<ST2NM> for vector
        if~isempty(opening_tab_value)
            opening_tab_end.base=num2str(opening_tab_value(end));
        elseif isvarname(params.opening_tab.base)
            opening_tab_end.base=[params.opening_tab.base,'(end)'];
        else
            opening_tab_end.base=['getfield(',params.opening_tab.base,',{ numel(',params.opening_tab.base,') }) '];
        end
        params.opening_tab_end=opening_tab_end;
    end




    name='S_max';

    if mdl_type==1
        math_expression='-x_0 + opening_max';
        dialog_unit_expression='opening_max';
    else
        math_expression='-x_0 + opening_tab_end';
        dialog_unit_expression='opening_tab_end';
    end
    S_max=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'S_max'},S_max);
    params.S_max=S_max;




    if mdl_type==1
        name='del_S_max';
        math_expression='S_max - S_min';
        dialog_unit_expression='S_min';
        del_S=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(hBlock,{'del_S_max'},del_S);
    end



    del_S_TLU=HtoIL_subtract_first_vector_element(params.opening_tab);
    HtoIL_apply_params(hBlock,{'del_S_TLU'},del_S_TLU);


    HtoIL_apply_params(hBlock,{'del_S_vol_flow_TLU'},del_S_TLU);


    warnings.messages={};

    if strcmp(lam_spec,'1')&&mdl_type~=3

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{end+1,1}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds number set to 150.';
        end
    end


    increase_decrease_str='ascending';
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    mdl_type,interp_method,extrap_method,...
    pressure_tab,area_tab,vol_flow_tab,increase_decrease_str,...
    'Spool travel vector','Orifice area vector',...
    'Pressure drop vector','Volumetric flow rate table');

    if isempty(warnings.messages)
        warnings={};
    else
        warnings.subsystem=getfullname(hBlock);
    end

    out.warnings=warnings;

end