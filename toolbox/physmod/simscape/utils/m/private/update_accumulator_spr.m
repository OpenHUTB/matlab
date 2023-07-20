function out=update_accumulator_spr(hBlock)







    param_list={...
    'capacity','capacity';...
    'pr_max','p_max';...
    'stiff_coeff','stiff_coeff'};



    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));



    collected_fluid_volume=HtoIL_collect_vars(hBlock,{'fluid_volume'},'sh_lib/Accumulators/Spring-Loaded Accumulator');



    fluid_pressure=HtoIL_collect_vars(hBlock,{'fluid_pressure'},'sh_lib/Accumulators/Spring-Loaded Accumulator');
    pr_preload=HtoIL_collect_params(hBlock,{'pr_preload'});
    pr_max=HtoIL_collect_params(hBlock,{'pr_max'});


    collected_reference_block=getSimulinkBlockHandle(get_param(hBlock,'ReferenceBlock'));


    beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate'},'sh_lib/Accumulators/Spring-Loaded Accumulator');
    beginning_variable_names={'Accumulator flow rate'};



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Tanks & Accumulators/Spring-Loaded Accumulator (IL)')



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);
    HtoIL_apply_vars(hBlock,{'liquid_volume'},collected_fluid_volume);


    set_param(hBlock,'dynamic_compressibility','simscape.enum.onoff.off');





    p_preload=HtoIL_gauge_to_abs('p_precharge',pr_preload);
    HtoIL_apply_params(hBlock,{'p_preload'},p_preload);

    p_max=HtoIL_gauge_to_abs('p_max',pr_max);
    HtoIL_apply_params(hBlock,{'p_max'},p_max);









    p_I=fluid_pressure;

    if strcmp(fluid_pressure.specify,'off')


        default_p_I.base=get_param(collected_reference_block,'fluid_pressure');
        default_p_I.unit=get_param(collected_reference_block,'fluid_pressure_unit');


        p_I.base=default_p_I.base;
        p_I.unit=default_p_I.unit;
    end


    p_I=HtoIL_gauge_to_abs('p_I',p_I);

    HtoIL_apply_vars(hBlock,{'p_I'},p_I);
    set_param(hBlock,'p_I_specify','on');



    warnings.messages={};


    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);


    if~isempty(warnings.messages)
        warnings.subsystem=getfullname(hBlock);
        out.warnings=warnings;
    else
        out={};
    end

end



