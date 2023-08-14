function out=update_pressure_source(hBlock)








    port_names={'B','P','A'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Sources/Pressure Source (IL)');




    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[3,2,1]);

    out.connections=connections;

end

