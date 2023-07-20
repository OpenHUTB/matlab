function out=update_valve_needle(hBlock)







    port_names={'S','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);



    param_list={'d_orif','diam_orifice';
...
    'A_leak','area_leak';
    'C_d','Cd';
    'Re_cr','Re_c'};





    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    x_0=HtoIL_collect_params(hBlock,{'x_0'});


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Flow Control Valves/Needle Valve (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);




    S0=x_0;
    S0.base=['-(',x_0.base,')'];
    HtoIL_apply_params(hBlock,{'S_min'},S0);


    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            out.warnings.messages={'Critical Reynolds number set to 150. Behavior change not expected.'};
        else
            out.warnings.messages={'Critical Reynolds number set to 150.'};
        end
        out.warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;
end