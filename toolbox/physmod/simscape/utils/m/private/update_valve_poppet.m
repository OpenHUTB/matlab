function out=update_valve_poppet(hBlock)







    port_names={'S','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={...
    'd_stem','diam_stem';...
    'C_d','Cd';...
    'A_leak','area_leak';...
    'Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));










    x_0=HtoIL_collect_params(hBlock,{'x_0'});
    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Flow Control Valves/Poppet Valve (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    Smin=x_0;
    Smin.base=['-(',x_0.base,')'];
    HtoIL_apply_params(hBlock,{'S_min'},Smin);


    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages={'Critical Reynolds number set to 150. Behavior change not expected.'};
        else
            warnings.messages={'Critical Reynolds number set to 150.'};
        end
        warnings.subsystem=getfullname(hBlock);
    else
        warnings={};
    end

    out.connections=connections;
    out.warnings=warnings;

end



