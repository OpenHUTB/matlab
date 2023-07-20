function out=update_constant_volume_chamber(hBlock)







    param_list={...
    'ch_sp','';...
    'wall_type','';...
    'ch_volume','volume';...
    'd_in','';...
    'length','';...
    'pr_r_coef','';...
    'time_const','';...
    'k_sh',''};
    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));



    pressure=HtoIL_collect_vars(hBlock,{'pressure'},['fl_lib/Hydraulic/Hydraulic Elements/Constant Volume',newline,'Hydraulic Chamber']);

    params_for_derivation=HtoIL_collect_params(hBlock,{'d_in';'length'});
    ch_sp=get_param(hBlock,'ch_sp');
    wall_type=get_param(hBlock,'wall_type');
    k_sh=get_param(hBlock,'k_sh');


    if strcmp(ch_sp,'1')||strcmp(wall_type,'1')
        beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate'},'fl_lib/Hydraulic/Hydraulic Elements/Constant Volume Hydraulic Chamber');
        beginning_variable_names={'Flow rate'};
    else
        beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate';'diameter_incr'},'fl_lib/Hydraulic/Hydraulic Elements/Constant Volume Hydraulic Chamber');
        beginning_variable_names={'Flow rate';'Diameter increase'};
    end


    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Constant Volume Chamber (IL)')



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    p_I=HtoIL_gauge_to_abs('p_I',pressure);
    HtoIL_apply_vars(hBlock,{'p_I'},p_I);


    if strcmp(ch_sp,'2')
        name='volume';
        params=HtoIL_cellToStruct(params_for_derivation);

        math_expression='pi * d_in * d_in / 4 * length';
        dialog_unit_expression=math_expression;
        evaluate=1;
        volume=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(hBlock,{'volume'},volume);
    end



    warnings.messages={};


    if(strcmp(ch_sp,'2')&&strcmp(wall_type,'2'))

        warnings.messages{end+1,1}='Chamber specification set to rigid. To model flexible volume, consider using the Simscape™ Fluids™ Pipe (IL) block.';


    end


    k_sh_value=str2num(k_sh);%#ok<ST2NM>
    if isempty(k_sh_value)
        k_sh=['''''',k_sh,''''''];
    end
    il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
    warnings.messages{end+1,1}=['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,'.'];


    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;

end



