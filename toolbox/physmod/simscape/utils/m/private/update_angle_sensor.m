function out=update_angle_sensor(hBlock)









    port_names={'W','A'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'phase_angle','offset';};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    HtoIL_set_block_files(hBlock,'fl_lib/Mechanical/Mechanical Sensors/Ideal Rotational Motion Sensor');


    set_param(hBlock,'wrap_angle','simscape.enum.onoff.on');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,4]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    sensor_ports=get_param(hBlock,'PortHandles');
    sensor_C_port=sensor_ports.RConn(1);
    add_line(connections.subsystem,sensor_C_port,rotational_reference_port,'autorouting','on');

    out.connections=connections;
end

