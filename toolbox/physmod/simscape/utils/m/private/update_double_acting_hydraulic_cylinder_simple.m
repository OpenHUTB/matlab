function out=update_double_acting_hydraulic_cylinder_simple(hBlock)








    port_names={'C','A','R','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'area_A','piston_area_A';
    'area_B','piston_area_B';
    'stroke','stroke'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    or=get_param(hBlock,'or');
    init_pos=HtoIL_collect_params(hBlock,{'init_pos'});







    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Double-Acting Actuator (IL)')

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,4,5]);



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'dynamic_compressibility','0');


    set_param(hBlock,'smoothing_factor_A','0');
    set_param(hBlock,'smoothing_factor_B','0');



    if strcmp(or,'1')
        mech_orientation='1';
    else
        mech_orientation='-1';
        init_pos.base=['-(',init_pos.base,')'];
    end
    set_param(hBlock,'mech_orientation',mech_orientation);
    HtoIL_apply_params(hBlock,{'x0'},init_pos);





    warnings.messages={'Hard-stop model has been reparameterized and uses default parameter values. Adjustment of Hard Stop parameters may be required.';
    'Actuator Dead volume in chambers A and B set to 1e-5 m^3. Adjustment of these parameters may be required.'};

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
    out.connections=connections;

end

