function out=update_elm_3_pos(hBlock)









    port_names={'A','B','S'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);








    init_position=get_param(hBlock,'init_position');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Valve Actuators/Multiposition Valve Actuator')


    set_param(hBlock,'positions','3');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,3]);


    if strcmp(init_position,'1')
        set_param(hBlock,'init_position_3','0');
    elseif strcmp(init_position,'2')
        set_param(hBlock,'init_position_3','1');
    else
        set_param(hBlock,'init_position_3','-1');
    end


    if~strcmp(init_position,'1')
        out.warnings.messages={['Updated actuator response when Initial position is Extended. '...
        ,'Adjustment of initial valve control input signals may be required if either signal is less than '...
        ,'50% of the Nominal signal value.']};
        out.warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;


end



