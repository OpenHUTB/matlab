function out=update_hyd_valve_act_da(hBlock)








    port_names={'X','Y','S'};
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list={...
    'area_X','area_X';
    'area_Y','area_Y';
    'frc_preload_x','preload_force_X';
    'frc_preload_y','preload_force_Y';
    'piston_str_x','stroke_X';
    'piston_str_y','stroke_Y'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));





    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'frc_max_x';'frc_preload_x';'piston_str_x';
    'frc_max_y';'frc_preload_y';'piston_str_y';
    'act_orientation'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Pilot Valve Actuator (IL)')


    set_param(hBlock,'actuator_type','2');
    set_param(hBlock,'smoothing_factor','0');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,3]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    evaluate=0;
    params=HtoIL_cellToStruct(params_for_derivation);


    name='stiff_coeff_X';

    math_expression='frc_max_x/piston_str_x -frc_preload_x/piston_str_x';
    dialog_unit_expression='frc_max_x/piston_str_x';
    stiff_coeff_X=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'stiff_coeff_X'},stiff_coeff_X);


    name='stiff_coeff_Y';

    math_expression='frc_max_y/piston_str_y -frc_preload_y/piston_str_y';
    dialog_unit_expression='frc_max_y/piston_str_y';
    stiff_coeff_Y=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'stiff_coeff_Y'},stiff_coeff_Y);


    if strcmp(params.act_orientation.base,'1')
        set_param(hBlock,'mech_orientation','1');
    else
        set_param(hBlock,'mech_orientation','-1');
    end

    out.connections=connections;

end



