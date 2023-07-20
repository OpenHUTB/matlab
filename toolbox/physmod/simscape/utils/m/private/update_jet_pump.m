function out=update_jet_pump(hBlock)







    param_list={...
    'A_n','nozzle_area';...
    'a','area_ratio_diffuser';...
    'K_n','loss_coeff_nozzle';...
    'K_en','loss_coeff_secondary';...
    'K_th','loss_coeff_throat';...
    'K_di','loss_coeff_diffuser';...
    };


    params_derivation=HtoIL_cellToStruct(HtoIL_collect_params(hBlock,{'A_th','A_n'}));


    p_nzl_min.name='p_nzl_min';
    p_nzl_min.base='10';
    p_nzl_min.unit='Pa';
    p_nzl_min.conf='compiletime';

    p_nozzle_min=p_nzl_min;


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Jet Pump (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    HtoIL_apply_params(hBlock,{'p_nozzle_min'},p_nozzle_min);


    name='area_ratio_nozzle_throat';
    math_expression='A_n/A_th';
    dialog_unit_expression='1';
    evaluate=1;
    ratio_A_n_A_th=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


    HtoIL_apply_params(hBlock,{'area_ratio_nozzle_throat'},ratio_A_n_A_th);


    warnings.messages={['New parameter Minimum nozzle pressure set to ',p_nozzle_min.base,' ',p_nozzle_min.unit,'. Behavior change not expected.']};


    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
end



