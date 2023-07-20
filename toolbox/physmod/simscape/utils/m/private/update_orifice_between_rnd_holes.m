function out=update_orifice_between_rnd_holes(hBlock)








    port_names={'S','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'d_sleeve','diameter_sleeve';
    'd_case','diameter_case';
    'num_pairs','num_pair';
    'C_d','Cd';
    'A_leak','area_leak';
    'Re_cr','Re_c'};




    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Variable Overlapping Orifice (IL)')


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,3]);


    set_param(hBlock,'smoothing_factor','0');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    warnings.subsystem=getfullname(hBlock);
    warnings.messages{1}='Overlapping area has been reparameterized. Adjustment of the larger Hole diameter, Sleeve position when holes are concentric, or other parameters may be required.';


    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages{2}='Critical Reynolds number set to 150. Behavior change not expected.';
        else
            warnings.messages{2}='Critical Reynolds number set to 150.';
        end
    end

    out.connections=connections;
    out.warnings=warnings;

end