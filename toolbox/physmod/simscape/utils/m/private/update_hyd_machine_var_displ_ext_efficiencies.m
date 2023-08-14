function out=update_hyd_machine_var_displ_ext_efficiencies(hBlock)









    port_names={'A','EV','C','EM','B','R'};
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    displacementSpecification=get_param(hBlock,'mdl_type');


    if strcmp(displacementSpecification,'1')
        params_derivation=HtoIL_cellToStruct(HtoIL_collect_params(hBlock,{'stroke_max','D_max','power_threshold'}));
    else
        params_derivation=HtoIL_cellToStruct(HtoIL_collect_params(hBlock,{'displ_tab','cntrl_mem_tab','interp_method','extrap_method','power_threshold'}));
    end


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Variable-Displacement Motor (IL)')


    set_param(hBlock,'leakage_friction_spec','fluids.isothermal_liquid.pumps_motors.enum.pump_motor_loss_spec.input_efficiency');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[4,2,1,3,7,5]);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    motor_ports=get_param(hBlock,'PortHandles');
    motor_C_port=motor_ports.RConn(2);
    add_line(connections.subsystem,motor_C_port,rotational_reference_port,'autorouting','on');




    if strcmp(displacementSpecification,'1')

        ps_sat_block=add_block('fl_lib/Physical Signals/Nonlinear Operators/PS Saturation',[connections.subsystem,'/Maximum displacement']);
        ps_sat_port_in=get_param(ps_sat_block,'PortHandles').LConn;
        ps_sat_port_out=get_param(ps_sat_block,'PortHandles').RConn;

        HtoIL_apply_params(ps_sat_block,{'upper_limit'},params_derivation.D_max);
        lower_limit=params_derivation.D_max;
        lower_limit.base=['-(',params_derivation.D_max.base,')'];
        HtoIL_apply_params(ps_sat_block,{'lower_limit'},lower_limit);


        ps_block=add_block('fl_lib/Physical Signals/Functions/PS Gain',[connections.subsystem,'/stroke2disp']);
        ps_port_in=get_param(ps_block,'PortHandles').LConn;
        ps_port_out=get_param(ps_block,'PortHandles').RConn;
        motor_ports=get_param(hBlock,'PortHandles');
        motor_D_port=motor_ports.LConn(1);


        name='gain';
        math_expression='D_max/stroke_max';
        dialog_unit_expression='D_max/stroke_max';
        evaluate=0;
        gain=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);

        HtoIL_apply_params(ps_block,{'gain'},gain);


        add_line(connections.subsystem,ps_port_out,ps_sat_port_in);
        add_line(connections.subsystem,ps_sat_port_out,motor_D_port);

    else

        ps_block=add_block('fl_lib/Physical Signals/Lookup Tables/PS Lookup Table (1D)',[connections.subsystem,'/stroke2disp']);
        ps_port_in=get_param(ps_block,'PortHandles').LConn;
        ps_port_out=get_param(ps_block,'PortHandles').RConn;
        motor_ports=get_param(hBlock,'PortHandles');
        motor_D_port=motor_ports.LConn(1);


        HtoIL_apply_params(ps_block,{'x'},params_derivation.cntrl_mem_tab);
        HtoIL_apply_params(ps_block,{'f'},params_derivation.displ_tab);
        HtoIL_apply_params(ps_block,{'interp_method'},params_derivation.interp_method);
        HtoIL_apply_params(ps_block,{'extrap_method'},params_derivation.extrap_method);


        add_line(connections.subsystem,ps_port_out,motor_D_port);
    end

    connections.destination_ports(3)=ps_port_in;


    warnings.messages={'New parameters Minimum volumetric efficiency and Minimum mechanical efficiency set to 1e-3. Smaller parameter values may be required to avoid unintended efficiency saturations.';
    ['New parameters Pressure drop threshold for motor-pump transition set to 1e-3 MPa, Angular velocity threshold for motor-pump transition set to 10 rad/s, '...
    ,'and Displacement threshold for motor-pump transition set to 0.1 cm^3/rev. Parameter adjustment may be required to match the behavior of the original Power threshold of '...
    ,params_derivation.power_threshold.base,' ',params_derivation.power_threshold.unit,'.']};
    warnings.subsystem=getfullname(hBlock);
    out.warnings=warnings;

    out.connections=connections;

end

