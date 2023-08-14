function out=update_constant_pressure_source(hBlock)








    port_names={'B','A'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);

    collected_params=HtoIL_collect_params(hBlock,{'commanded_pressure'});

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Sources/Pressure Source (IL)')
    set_param(hBlock,'source_type','1')


    set_param(hBlock,'BlockMirror','off')
    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1]);

    HtoIL_apply_params(hBlock,{'pressure_differential'},collected_params);

    out.connections=connections;

end

