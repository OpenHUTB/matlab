function out=update_elbow(hBlock)








    port_names={'A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'elbow_diam','diameter_elbow';
    'elbow_angle','angle_elbow';
    'Re_cr','Re_c'};




    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Elbow (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2]);



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



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