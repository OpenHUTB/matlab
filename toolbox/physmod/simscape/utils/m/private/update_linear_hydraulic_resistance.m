function out=update_linear_hydraulic_resistance(hBlock)




    collected_params=HtoIL_collect_params(hBlock,{'resistance'});


    beginning_variables=HtoIL_collect_vars(hBlock,{'q';'p'},'fl_lib/Hydraulic/Hydraulic Elements/Linear Hydraulic Resistance');
    beginning_variable_names={'Flow rate';'Pressure differential'};

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Laminar Leakage (IL)')
    set_param(hBlock,'cross_section_geometry','6');


    HtoIL_apply_params(hBlock,{'resistance'},collected_params);



    warnings.messages={};


    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);

    if isempty(warnings.messages)
        out=struct;
    else
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    end


end

