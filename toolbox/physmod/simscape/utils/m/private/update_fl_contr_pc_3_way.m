function out=update_fl_contr_pc_3_way(hBlock)







    param_list={'mdl_type','orifice_spec';
    'or_max_op','del_S';
    'or_max_area','area_max';
    'area_tab','orifice_area_TLU';
    'pr_diff_set','p_diff_orifice';
    'reg_range','p_range';
    'pr_comp_max_area','area_max_compensator';
    'or_leak_area','area_leak';
    'or_C_d','Cd';
    'or_Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'or_max_op';'or_max_area';'or_leak_area';'init_op';'opening_tab'});


    mdl_type=eval(get_param(hBlock,'mdl_type'));
    interp_method=eval(get_param(hBlock,'interp_method'));
    extrap_method=eval(get_param(hBlock,'extrap_method'));
    area_tab=HtoIL_collect_params(hBlock,{'area_tab'});
    or_leak_area=get_param(hBlock,'or_leak_area');
    or_leak_area_unit=get_param(hBlock,'or_leak_area_unit');
    pr_comp_leak_area=get_param(hBlock,'pr_comp_leak_area');
    or_C_d=get_param(hBlock,'or_C_d');
    pr_comp_C_d=get_param(hBlock,'pr_comp_C_d');
    or_lam_spec=get_param(hBlock,'or_lam_spec');
    or_Re_cr=get_param(hBlock,'or_Re_cr');
    or_B_lam=get_param(hBlock,'or_B_lam');
    pr_comp_lam_spec=get_param(hBlock,'pr_comp_lam_spec');
    pr_comp_Re_cr=get_param(hBlock,'pr_comp_Re_cr');
    pr_comp_B_lam=get_param(hBlock,'pr_comp_B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Flow Control Valves/Pressure-Compensated 3-Way Flow Control Valve (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    params=HtoIL_cellToStruct(params_for_derivation);
    evaluate=0;


    name='S_min';
    math_expression='or_max_op/or_max_area* or_leak_area - init_op';
    dialog_unit_expression='init_op';
    S_min=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},S_min);


    name='S_TLU';
    math_expression='opening_tab - init_op';
    dialog_unit_expression='opening_tab';
    p_diff_TLU=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{name},p_diff_TLU);



    warnings.messages={};

    if~strcmp(or_C_d,pr_comp_C_d)
        warnings.messages{end+1,1}=['Discharge coefficient set to ',or_C_d,'. Adjustment of Discharge coefficient may be required.'];
    end
    if~strcmp(or_leak_area,pr_comp_leak_area)
        warnings.messages{end+1,1}=['Leakage area set to ',or_leak_area,' ',or_leak_area_unit,'. Adjustment of Leakage area may be required.'];
    end
    if strcmp(or_lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(or_B_lam,'0.999')&&((strcmp(pr_comp_lam_spec,'1')&&strcmp(pr_comp_B_lam,'0.999'))||(strcmp(pr_comp_lam_spec,'2')&&strcmp(pr_comp_Re_cr,'150')))
            warnings.messages{end+1,1}='Critical Reynolds numbers set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Critical Reynolds numbers set to 150.';
        end
    elseif strcmp(or_lam_spec,'2')&&(strcmp(pr_comp_lam_spec,'1')||~strcmp(or_Re_cr,pr_comp_Re_cr))

        warnings.messages{end+1,1}=['Critical Reynolds number set to ',or_Re_cr,'.'];
    end



    increase_decrease_str='ascending or descending';
    warnings.messages=HtoIL_add_tabulated_orifice_warnings(warnings.messages,...
    mdl_type,interp_method,extrap_method,...
    [],area_tab,[],increase_decrease_str,...
    'Control member position vector','Orifice area vector',...
    '','');

    warnings.subsystem=getfullname(hBlock);

    if isempty(warnings.messages)
        out=struct;
    else
        out.warnings=warnings;
    end

end