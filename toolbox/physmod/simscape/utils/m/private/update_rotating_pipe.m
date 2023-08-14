function out=update_rotating_pipe(hBlock)









    port_names={'B','W','A'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'area','channel_area';
    'r_B','r_B';
    'C_d','Cd';
    'Re_cr','Re_c'};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Auxiliary Components/Rotating Channel (IL)')



    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    out.connections=connections;
end

