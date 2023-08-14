function out=update_flow_cntr_vlv_pc(hBlock)







    param_list={'mdl_type','orifice_spec';
    'area_max','area_max';
    'area_tab','orifice_area_TLU';
    'pr_dif','p_diff_orifice';
    'reg_range','p_range';
    'C_d','Cd';
    'A_leak','area_leak';
    'Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'opening_max';'area_max';'x_0';'opening_tab';'area_tab';'A_leak'});


    mdl_type=eval(get_param(hBlock,'mdl_type'));
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    area_tab=HtoIL_collect_params(hBlock,{'area_tab'});
    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Flow Control Valves/Pressure-Compensated Flow Control Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    params=HtoIL_cellToStruct(params_for_derivation);
    evaluate=0;


    name='S_min';
    math_expression='opening_max/area_max* A_leak - x_0';
    dialog_unit_expression='x_0';
    S_min=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},S_min);


    name='del_S';
    math_expression='opening_max - opening_max/area_max*A_leak';
    dialog_unit_expression='opening_max';
    del_S=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},del_S);


    name='S_TLU';
    math_expression='opening_tab - x_0';
    dialog_unit_expression='opening_tab';
    p_diff_TLU=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},p_diff_TLU);


    if mdl_type==1
        area_max_compensator=params.area_max;
        area_max_compensator.base=['1.5*(',params.area_max.base,')'];
    else
        area_max_compensator=HtoIL_get_vector_element(params.area_tab,'last');
        area_max_compensator.base=['1.5*(',area_max_compensator.base,')'];
    end
    HtoIL_apply_params(hBlock,{'area_max_compensator'},area_max_compensator);



    warnings.messages={};

    if strcmp(lam_spec,'1')

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
    [],area_tab,[],increase_decrease_str,...
    'Control member position vector','Orifice area vector',...
    '','');

    if isempty(warnings.messages)
        out=struct;
    else
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end


end