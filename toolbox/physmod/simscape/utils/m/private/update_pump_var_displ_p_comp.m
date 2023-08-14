function out=update_pump_var_displ_p_comp(hBlock)










    port_names={'S','P','T'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'D_max','displacement_nominal';
    'w_nominal','omega_nominal';
    'pr_nominal','p_nominal';
    'efficiency_vol','vol_eff_nominal';
    'D_max','displacement_max';
    'pr_set','p_set_differential';
    'pr_reg','p_range'};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_for_derivation=HtoIL_collect_params(hBlock,...
    {'efficiency_tot';'efficiency_vol';'D_max';'torque_pressure_coeff';...
    'pr_nominal'});



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Pressure-Compensated Pump (IL)')


    set_param(hBlock,'displacement_max','0.01');






    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'no_load_torque','0');
    set_param(hBlock,'smoothing_factor','0');



    params=HtoIL_cellToStruct(params_for_derivation);


    params.no_load_torque.name='no_load_torque';
    params.no_load_torque.base='0';
    params.no_load_torque.unit='N*m';
    params.no_load_torque.conf='runtime';


    math_expression='efficiency_vol/efficiency_tot*D_max - D_max';
    dialog_unit_expression='D_max';
    params.torque_pressure_coeff=HtoIL_derive_params('torque_pressure_coeff',...
    math_expression,params,dialog_unit_expression,1);

    mech_eff_nominal=HtoIL_compute_mech_eff_nominal(params,'variable_pump');
    HtoIL_apply_params(hBlock,{'mech_eff_nominal'},mech_eff_nominal);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    pump_ports=get_param(hBlock,'PortHandles');
    pump_C_port=pump_ports.RConn(2);
    add_line(connections.subsystem,pump_C_port,rotational_reference_port);





    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[4,3,6]);


    pump_X_port=get_param(hBlock,'PortHandles').LConn(1);
    pump_Y_port=get_param(hBlock,'PortHandles').LConn(2);
    pump_A_port=get_param(hBlock,'PortHandles').RConn(3);
    pump_B_port=get_param(hBlock,'PortHandles').LConn(3);
    add_line(connections.subsystem,pump_X_port,pump_B_port);
    add_line(connections.subsystem,pump_Y_port,pump_A_port);





    warnings.messages{1}='Nominal fluid density and kinematic viscosity removed. Pump uses network fluid properties. Adjustment of Volumetric efficiency at nominal conditions may be required.';


    warning_param=HtoIL_collect_params(hBlock,{'displacement_min'});
    warnings.messages{2}=['New parameter Minimum displacement set to ',warning_param(1).base,' ',warning_param(1).unit,'. Adjustment of Minimum displacement may be required.'];

    warnings.subsystem=getfullname(hBlock);
    out.warnings=warnings;

    out.connections=connections;

end

