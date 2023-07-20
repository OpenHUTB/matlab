function out=update_journal_bearing_pressure_fed(hBlock)









    port_names={'J','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);






    half_length=HtoIL_collect_params(hBlock,{'half_length'});
    r_j=HtoIL_collect_params(hBlock,{'r_j'});
    clearance=HtoIL_collect_params(hBlock,{'clearance'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Annular Leakage (IL)')


    set_param(hBlock,'eccentricity_spec','2');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);





    HtoIL_apply_params(hBlock,{'length'},half_length);


    HtoIL_apply_params(hBlock,{'radius_in'},r_j);



    radius_out=clearance;


    r_j_value=str2double(r_j.base);
    clearance_value=str2double(clearance.base);

    params(1)=r_j;
    params(2)=clearance;
    params_simscapeValue=HtoIL_convert_to_simscape_values(params);


    C=simscape.Value(1,r_j.unit)/simscape.Value(1,clearance.unit);
    cf=value(C,'1');


    if iscell(params_simscapeValue.r_j)
        if cf~=1
            cf_str=num2str(cf);
            r_j.base=[cf_str,' * (',r_j.base,')'];
        end
    else
        r_j.base=num2str(cf*r_j_value);
    end
    r_j.unit=clearance.unit;

    if~isnan(r_j_value)&&~isnan(clearance_value)
        radius_out.base=[r_j.base,' + ',clearance.base];
    else
        radius_out.base=['(',r_j.base,') + (',clearance.base,')'];
    end

    HtoIL_apply_params(hBlock,{'radius_out'},radius_out);



    hBlock_parallel=add_block(hBlock,[connections.subsystem,'/',get_param(hBlock,'Name')],'MakeNameUnique','on');


    loc=get_param(hBlock_parallel,'Position');
    set_param(hBlock_parallel,'Position',loc-[0,90,0,90]);


    hPorts=get_param(hBlock,'PortHandles');
    hPorts_parallel=get_param(hBlock_parallel,'PortHandles');
    add_line(connections.subsystem,hPorts.LConn(1),hPorts_parallel.LConn(1),'autorouting','on');
    add_line(connections.subsystem,hPorts.LConn(2),hPorts_parallel.LConn(2),'autorouting','on');
    add_line(connections.subsystem,hPorts.RConn(1),hPorts_parallel.RConn(1),'autorouting','on');

    out.connections=connections;

end



