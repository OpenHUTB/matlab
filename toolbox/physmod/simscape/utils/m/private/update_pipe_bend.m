function out=update_pipe_bend(hBlock)








    port_names={'A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'pipe_diam','diameter_bend';
    'bend_rad','bend_radius';
    'bend_angle','angle_bend';
    'compressibility','dynamic_compressibility'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));





    p0=HtoIL_collect_params(hBlock,{'p0'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Pipe Bend (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    p0=HtoIL_gauge_to_abs('p_I',p0);
    HtoIL_apply_params(hBlock,{'p0'},p0);


    out.warnings.messages={'Block treats flow as fully laminar for Re < 2000 and fully turbulent for Re > 4000. Behavior change not expected.'};
    out.warnings.subsystem=getfullname(hBlock);

    out.connections=connections;

end