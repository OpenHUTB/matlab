function out=update_orifice_annular(hBlock)









    port_names={'S','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'orifice_r','radius_out';
    'insert_r','radius_in';
    'ecc','eccentricity'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    L0=HtoIL_collect_params(hBlock,{'length'});
    or=str2double(get_param(hBlock,'or'));

    if or==1
        x_or=1;
    else
        x_or=-1;
    end



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Annular Leakage (IL)')


    set_param(hBlock,'overlap_spec','2');





    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    if x_or==1
        PS_block_name='fl_lib/Physical Signals/Functions/PS Add';
    else
        PS_block_name='fl_lib/Physical Signals/Functions/PS Subtract';
    end


    PS_block=add_block(PS_block_name,[connections.subsystem,'/PS Convert']);
    PS_block_ports=get_param(PS_block,'PortHandles');


    out_port=PS_block_ports.RConn;
    orifice_L_port=get_param(hBlock,'PortHandles').LConn(2);
    add_line(connections.subsystem,out_port,orifice_L_port,'autorouting','on');



    L0_port=PS_block_ports.LConn(1);
    S_port=PS_block_ports.LConn(2);


    const_block=add_block('fl_lib/Physical Signals/Sources/PS Constant',[connections.subsystem,'/Initial length']);
    HtoIL_apply_params(const_block,{'constant'},L0);
    const_port=get_param(const_block,'PortHandles').RConn;
    add_line(connections.subsystem,const_port,L0_port,'autorouting','on');


    S_input_port=get_param([connections.subsystem,'/S'],'PortHandles').RConn;
    add_line(connections.subsystem,S_input_port,S_port,'autorouting','on');
    connections.source_ports(1)=[];



    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,3]);

    out.connections=connections;

end