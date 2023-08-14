function out=update_flow_rate_sensor(hBlock)








    port_names={'A','V','B','M'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Sensors/Flow Rate Sensor (IL)')
    set_param(hBlock,'sensor_type','3');

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,4,2,3]);

    out.connections=connections;
end

