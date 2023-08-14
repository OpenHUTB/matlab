function out=update_rotating_cylinder_force(hBlock)










    port_names={'W','C','R'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={...
    'r_o','r_outer';...
    'r_i','r_inner';...
    'r_p','r_fluid';...
    'or','mech_orientation'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    or=get_param(hBlock,'or');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Auxiliary Components/Rotating Cylinder Force (IL)')

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,4]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    if strcmp(or,'1')
        set_param(hBlock,'mech_orientation','1');
    else
        set_param(hBlock,'mech_orientation','-1');
    end



    reservoir_block=add_block('fl_lib/Isothermal Liquid/Elements/Reservoir (IL)',[connections.subsystem,'/Reservoir (IL)']);
    reservoir_port=get_param(reservoir_block,'PortHandles').LConn;
    rotating_cylinder_force_ports=get_param(hBlock,'PortHandles');
    X_port=rotating_cylinder_force_ports.LConn(3);
    add_line(connections.subsystem,X_port,reservoir_port,'autorouting','on');



    warnings.messages={'Port X has been connected to a Reservoir (IL) at atmospheric pressure. Connect port X to the isothermal liquid conserving port of the actuator inlet to sense fluid density.'};
    warnings.subsystem=getfullname(hBlock);

    out.connections=connections;
    out.warnings=warnings;

end



