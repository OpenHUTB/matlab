function out=update_hyd_cartridge_valve_act_four_port(hBlock)








    port_names={'A','B','X','Y','S'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);





    param_list={...
    'ar_ratio','area_A_X_ratio';...
    'spr_rate','stiff_coeff';...
    'poppet_str','stroke';...
    'time_constant','tau'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));






    params_for_derivation=HtoIL_collect_params(hBlock,{'act_orientation';'frc_preload';'area_Y'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Cartridge Valve Actuator (IL)')


    set_param(hBlock,'num_ports','4');


    set_param(hBlock,'smoothing_factor','0');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,3,4,5]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'actuator_dynamics','1');





    params=HtoIL_cellToStruct(params_for_derivation);


    if strcmp(params.act_orientation.base,'1')
        set_param(hBlock,'mech_orientation','1');
    else
        set_param(hBlock,'mech_orientation','-1');
    end


    params.P_atm.base='0.101325';
    params.P_atm.unit='MPa';
    params.P_atm.conf='runtime';

    name='preload_force';
    math_expression='frc_preload - P_atm*area_Y';
    dialog_unit_expression='frc_preload';
    evaluate=0;
    preload_force=HtoIL_derive_params(name,math_expression,params,dialog_unit_expression,evaluate);
    HtoIL_apply_params(hBlock,{'preload_force'},preload_force);



    warnings.messages={'The area at port B is now calculated as the sum or areas at ports X and Y minus the area at port A. Formerly, it was the difference in areas at port X and port A. Adjustment of port A poppet area, Port A poppet to port X pilot area ratio, and port Y pilot area may be required.';
    'Spring preload force adjusted to account for absolute pressure at the ports. Behavior change not expected.';
    'Poppet-seat initial gap removed. Adjustment of model initial conditions may be required.'};
    warnings.subsystem=getfullname(hBlock);


    out.warnings=warnings;
    out.connections=connections;

end



