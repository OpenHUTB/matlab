function out=update_accumulator_gas(hBlock)







    param_list={'capacity','capacity';...
    'dead_volume','dead_volume';...
    'k_sh','k_sh';...
    'stiff_coeff','stiff_coeff'};



    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));



    liquid_pressure=HtoIL_collect_vars(hBlock,{'liquid_pressure'},'sh_lib/Accumulators/Gas-Charged Accumulator');
    pr_preload=HtoIL_collect_params(hBlock,{'pr_preload'});


    collected_reference_block=getSimulinkBlockHandle(get_param(hBlock,'ReferenceBlock'));


    beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate'},'sh_lib/Accumulators/Gas-Charged Accumulator');
    beginning_variable_names={'Accumulator flow rate'};






    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Tanks & Accumulators/Gas-Charged Accumulator (IL)')



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'dynamic_compressibility','simscape.enum.onoff.off');





    p_precharge=HtoIL_gauge_to_abs('p_precharge',pr_preload);
    HtoIL_apply_params(hBlock,{'p_precharge'},p_precharge);









    p_I=liquid_pressure;

    if strcmp(liquid_pressure.specify,'off')


        default_p_I.base=get_param(collected_reference_block,'liquid_pressure');
        default_p_I.unit=get_param(collected_reference_block,'liquid_pressure_unit');


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



