function out=update_hyd_valve_act_sa(hBlock)







    param_list={...
    'area','area_X';
    'frc_preload','preload_force';
    'piston_str','stroke'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));






    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'frc_max';'frc_preload';'piston_str';'act_orientation'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Pilot Valve Actuator (IL)')


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    evaluate=0;
    params=HtoIL_cellToStruct(params_for_derivation);


    name='stiff_coeff';

    math_expression='frc_max/piston_str -frc_preload/piston_str';
    dialog_unit_expression='frc_max/piston_str';
    stiff_coeff=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'stiff_coeff'},stiff_coeff);


    if strcmp(params.act_orientation.base,'1')
        set_param(hBlock,'mech_orientation','1');
    else
        set_param(hBlock,'mech_orientation','-1');
    end

    out=struct;

end



