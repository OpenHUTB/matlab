function out=update_flow_rate_source(hBlock)








    port_names={'B','V','A'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Sources/Flow Rate Source (IL)')

    set_param(hBlock,'flow_type','2')


    set_param(hBlock,'BlockMirror','off')
    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[3,2,1]);

    out.connections=connections;

end

