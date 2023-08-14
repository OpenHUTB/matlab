function out=update_flow_divider(hBlock)







    port_names={'P','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    servo_cylinder_param_list={...
    'area_sc','spool_area'
    'stroke','stroke'
    'spring_rate','stiff_coeff';
    'damping','damping_coeff'};
    servo_cylinder_collected_params=HtoIL_collect_params(hBlock,servo_cylinder_param_list(:,1));
    servo_stroke=HtoIL_collect_params(hBlock,{'stroke'});

    fixed_orifice_A_param_list={...
    'area_A','orifice_area_constant';
    'C_d_A','Cd';
    'Re_cr_A','Re_c'};
    fixed_orifice_A_collected_params=HtoIL_collect_params(hBlock,fixed_orifice_A_param_list(:,1));

    fixed_orifice_B_param_list={...
    'area_B','orifice_area_constant';
    'C_d_B','Cd';
    'Re_cr_B','Re_c'};
    fixed_orifice_B_collected_params=HtoIL_collect_params(hBlock,fixed_orifice_B_param_list(:,1));

    fixed_orifice_lam_spec=get_param(hBlock,'lam_spec');
    B_lam_A=get_param(hBlock,'B_lam_A');
    B_lam_B=get_param(hBlock,'B_lam_B');

    variable_orifice_A_param_list={...
    'orifice_d','diameter_hole';
    'orifice_numb','num_hole';
    'C_d_or','Cd';
    'leak_area','area_leak';
    'Re_cr_or_A','Re_c'};
    variable_orifice_A_collected_params=HtoIL_collect_params(hBlock,variable_orifice_A_param_list(:,1));

    variable_orifice_B_param_list={...
    'orifice_d','diameter_hole';
    'orifice_numb','num_hole';
    'C_d_or','Cd';
    'leak_area','area_leak';
    'Re_cr_or_B','Re_c';
    'init_B','S_min'};
    variable_orifice_B_collected_params=HtoIL_collect_params(hBlock,variable_orifice_B_param_list(:,1));


    variable_orifice_init_A=HtoIL_collect_params(hBlock,{'init_A'});
    variable_orifice_lam_spec=get_param(hBlock,'lam_spec_or');
    B_lam_or_A=get_param(hBlock,'B_lam_or_A');
    B_lam_or_B=get_param(hBlock,'B_lam_or_B');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Double-Acting Servo Valve Actuator (IL)')
    servo_cylinder_block=hBlock;
    set_param(servo_cylinder_block,'Name','Double-Acting Servo Cylinder');


    HtoIL_apply_params(servo_cylinder_block,servo_cylinder_param_list(:,2),servo_cylinder_collected_params);

    servo_cylinder_port_A=get_param(servo_cylinder_block,'PortHandles').LConn(1);
    servo_cylinder_port_B=get_param(servo_cylinder_block,'PortHandles').LConn(2);
    servo_cylinder_port_S=get_param(servo_cylinder_block,'PortHandles').RConn;


    subtract_block=add_block('fl_lib/Physical Signals/Functions/PS Subtract',[connections.subsystem,'/PS Subtract']);

    subtract_pos_in_port=get_param(subtract_block,'PortHandles').LConn(1);
    subtract_neg_in_port=get_param(subtract_block,'PortHandles').LConn(2);
    subtract_out_port=get_param(subtract_block,'PortHandles').RConn;


    constant_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',[connections.subsystem,'/PS Constant']);

    half_stroke=servo_stroke;
    half_stroke.base=['(',servo_stroke.base,')/2'];
    HtoIL_apply_params(constant_block,{'constant'},half_stroke);

    constant_port=get_param(constant_block,'PortHandles').RConn;



    fixed_orifice_A_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',...
    [connections.subsystem,'/Fixed Orifice A']);

    set_param(fixed_orifice_A_block,'orifice_type','1');
    HtoIL_apply_params(fixed_orifice_A_block,fixed_orifice_A_param_list(:,2),fixed_orifice_A_collected_params);

    fixed_orifice_A_port_A=get_param(fixed_orifice_A_block,'PortHandles').LConn;
    fixed_orifice_A_port_B=get_param(fixed_orifice_A_block,'PortHandles').RConn;


    fixed_orifice_B_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',...
    [connections.subsystem,'/Fixed Orifice B']);

    set_param(fixed_orifice_B_block,'orifice_type','1');
    HtoIL_apply_params(fixed_orifice_B_block,fixed_orifice_B_param_list(:,2),fixed_orifice_B_collected_params);

    fixed_orifice_B_port_A=get_param(fixed_orifice_B_block,'PortHandles').LConn;
    fixed_orifice_B_port_B=get_param(fixed_orifice_B_block,'PortHandles').RConn;



    variable_orifice_A_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Spool Orifice (IL)',...
    [connections.subsystem,'/Variable Orifice A']);

    HtoIL_apply_params(variable_orifice_A_block,variable_orifice_A_param_list(:,2),variable_orifice_A_collected_params);
    variable_orifice_init_A.base=['-(',variable_orifice_init_A.base,')'];
    HtoIL_apply_params(variable_orifice_A_block,{'S_min'},variable_orifice_init_A);
    set_param(variable_orifice_A_block,'smoothing_factor','0');

    variable_orifice_A_port_S=get_param(variable_orifice_A_block,'PortHandles').LConn(1);
    variable_orifice_A_port_A=get_param(variable_orifice_A_block,'PortHandles').LConn(2);
    variable_orifice_A_port_B=get_param(variable_orifice_A_block,'PortHandles').RConn;


    variable_orifice_B_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Spool Orifice (IL)',...
    [connections.subsystem,'/Variable Orifice B']);

    HtoIL_apply_params(variable_orifice_B_block,variable_orifice_B_param_list(:,2),variable_orifice_B_collected_params);
    set_param(variable_orifice_B_block,'open_orientation','-1')
    set_param(variable_orifice_B_block,'smoothing_factor','0');

    variable_orifice_B_port_S=get_param(variable_orifice_B_block,'PortHandles').LConn(1);
    variable_orifice_B_port_A=get_param(variable_orifice_B_block,'PortHandles').LConn(2);
    variable_orifice_B_port_B=get_param(variable_orifice_B_block,'PortHandles').RConn;





    add_line(connections.subsystem,servo_cylinder_port_S,subtract_pos_in_port);
    add_line(connections.subsystem,constant_port,subtract_neg_in_port);

    add_line(connections.subsystem,fixed_orifice_A_port_A,fixed_orifice_B_port_A);
    add_line(connections.subsystem,fixed_orifice_A_port_B,servo_cylinder_port_A);
    add_line(connections.subsystem,fixed_orifice_B_port_B,servo_cylinder_port_B);

    add_line(connections.subsystem,variable_orifice_A_port_S,subtract_out_port);
    add_line(connections.subsystem,variable_orifice_A_port_A,servo_cylinder_port_A);
    add_line(connections.subsystem,variable_orifice_B_port_S,subtract_out_port);
    add_line(connections.subsystem,variable_orifice_B_port_A,servo_cylinder_port_B);


    Simulink.BlockDiagram.createSubsystem([servo_cylinder_block,subtract_block,constant_block]);
    set_param([connections.subsystem,'/Subsystem'],'Name','Double-Acting Servo Cylinder')
    Simulink.BlockDiagram.arrangeSystem([connections.subsystem,'/Double-Acting Servo Cylinder']);


    block_connections_Servo=get_param(servo_cylinder_block,'PortConnectivity');
    port_names={'A','B'};
    for i=1:2

        port_block=block_connections_Servo(i).DstBlock;
        set_param(port_block,'Name',port_names{i});
    end

    block_connections_Subtract=get_param(subtract_block,'PortConnectivity');
    port_block=block_connections_Subtract(3).DstBlock;
    set_param(port_block,'Name','S');


    connections.destination_ports=[fixed_orifice_A_port_A,variable_orifice_A_port_B,variable_orifice_B_port_B];
    out.connections=connections;




    warnings.messages={['Servo cylinder hard-stop model has been reparameterized and uses default parameter values. '...
    ,'Adjustment of Hard Stop parameters in the Double-Acting Servo Cylinder may be required.']};


    if strcmp(fixed_orifice_lam_spec,'1')

        set_param(fixed_orifice_A_block,'Re_c','150');
        set_param(fixed_orifice_B_block,'Re_c','150');
        if strcmp(B_lam_A,'0.999')&&strcmp(B_lam_B,'0.999')
            warnings.messages{end+1,1}='Fixed Orifices Critical Reynolds numbers set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Fixed Orifices Critical Reynolds numbers set to 150.';
        end
    end


    if strcmp(variable_orifice_lam_spec,'1')

        set_param(variable_orifice_A_block,'Re_c','150');
        set_param(variable_orifice_B_block,'Re_c','150');
        if strcmp(B_lam_or_A,'0.999')&&strcmp(B_lam_or_B,'0.999')
            warnings.messages{end+1,1}='Variable Orifices Critical Reynolds numbers set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Variable Orifices Critical Reynolds numbers set to 150.';
        end
    end

    warnings.subsystem=connections.subsystem;
    out.warnings=warnings;
end



