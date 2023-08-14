function out=update_spool_orifice_hydr_force(hBlock)









    param_list={'or_type','orifice_spec';
    'w','width';
    'rad_clear','clearance';
    'or_diam','diameter_hole';
    'or_numb','num_hole'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    or_type=get_param(hBlock,'or_type');
    or=get_param(hBlock,'or');
    params_for_derivation=HtoIL_collect_params(hBlock,{'x_0';'rad_clear';'or_diam';'or_num';'w'});



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Spool Orifice Flow Force (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    params=HtoIL_cellToStruct(params_for_derivation);


    if strcmp(or_type,'1')
        set_param(hBlock,'orifice_spec','2');
    else
        set_param(hBlock,'orifice_spec','1');
    end


    if strcmp(or,'1')
        set_param(hBlock,'open_orientation','1');
    else
        set_param(hBlock,'open_orientation','-1');
    end


    S_min=params.x_0;
    if strcmp(or,'1')
        S_min.base=['-(',S_min.base,')'];
    end
    HtoIL_apply_params(hBlock,{'S_min'},S_min);


    name='area_leak';
    evaluate=0;
    if strcmp(or_type,'1')
        math_expression='w*rad_clear';
        dialog_unit_expression=math_expression;
    else
        math_expression='rad_clear*or_diam*or_numb';
        dialog_unit_expression=math_expression;
    end
    area_leak=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'area_leak'},area_leak);


    set_param(hBlock,'del_S_max','1');




    warnings.subsystem=getfullname(hBlock);
    warnings.messages={'New parameter Spool travel between closed and open orifice set to 1 m. Larger parameter value may be required to avoid unintended orifice area saturation.'};
    out.warnings=warnings;

end