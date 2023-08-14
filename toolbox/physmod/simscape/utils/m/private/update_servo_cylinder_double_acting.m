function out=update_servo_cylinder_double_acting(hBlock)








    port_names={'A','B','S'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={...
    'piston_area','spool_area';
...
    'spring_rate','stiff_coeff';
    'damping','damping_coeff'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    stroke=HtoIL_collect_params(hBlock,{'stroke'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Double-Acting Servo Valve Actuator (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    subtract_block=add_block('fl_lib/Physical Signals/Functions/PS Subtract',[connections.subsystem,'/PS Subtract']);

    subtract_pos_in_port=get_param(subtract_block,'PortHandles').LConn(1);
    subtract_neg_in_port=get_param(subtract_block,'PortHandles').LConn(2);
    subtract_out_port=get_param(subtract_block,'PortHandles').RConn;


    constant_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',[connections.subsystem,'/PS Constant']);

    half_stroke=stroke;
    half_stroke.base=['(',stroke.base,')/2'];
    HtoIL_apply_params(constant_block,{'constant'},half_stroke);

    constant_port=get_param(constant_block,'PortHandles').RConn;


    actuator_S_port=get_param(hBlock,'PortHandles').RConn;
    add_line(connections.subsystem,actuator_S_port,subtract_pos_in_port,'autorouting','on');
    add_line(connections.subsystem,constant_port,subtract_neg_in_port,'autorouting','on');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2]);
    connections.destination_ports(3)=subtract_out_port;
    out.connections=connections;



    out.warnings.messages={'Hard-stop model has been reparameterized and uses default parameter values. Adjustment of Hard Stop parameters may be required.'};
    out.warnings.subsystem=getfullname(hBlock);

end



