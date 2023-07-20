function out=update_resistive_tube(hBlock)






    param_list={'cs_type','';
    'd_in','';
    'area','area';
    'D_h','Dh';
    's_factor','shape_factor';
    'length','length';
    'length_ad','length_add';
    'roughness','roughness';
    'Re_lam','Re_lam';
    'Re_turb','Re_tur'};
    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    beginning_variables=HtoIL_collect_vars(hBlock,{'q';'p'},'fl_lib/Hydraulic/Hydraulic Elements/Hydraulic Resistive Tube');
    beginning_variable_names={'Flow rate';'Pressure differential'};


    cs_type=get_param(hBlock,'cs_type');
    d_in=HtoIL_collect_params(hBlock,{'d_in'});


    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Pipe (IL)')


    set_param(hBlock,'dynamic_compressibility','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    if strcmp(cs_type,'1')


        name='area';
        params.d_in=d_in;

        math_expression='pi * d_in * d_in / 4';
        dialog_unit_expression=math_expression;
        evaluate=1;
        area=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
        HtoIL_apply_params(hBlock,{'area'},area);

        HtoIL_apply_params(hBlock,{'Dh'},params.d_in);
    end



    warnings.subsystem=getfullname(hBlock);
    warnings.messages={};


    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);

    if isempty(warnings.messages)
        out=struct;
    else
        out.warnings=warnings;
    end

end

