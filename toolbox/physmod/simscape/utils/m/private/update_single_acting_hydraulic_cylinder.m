function out=update_single_acting_hydraulic_cylinder(hBlock)









    port_names={'C','A','R','P'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'area','piston_area';
    'stroke','stroke';
    'dead_vol','dead_volume';
    'init_pressure','p0';
    'stiff','stiff_coeff';
    'D','damping_coeff';
    'hardstop_model','hardstop_model';
    'transition','transition'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    or=eval(get_param(hBlock,'or'));
    init_pressure=HtoIL_collect_params(hBlock,{'init_pressure'});
    init_pos=HtoIL_collect_params(hBlock,{'init_pos'});


    k_sh=get_param(hBlock,'k_sh');







    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Single-Acting Actuator (IL)')

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2,4,3]);



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'smoothing_factor','0');



    p0=HtoIL_gauge_to_abs('p0',init_pressure);
    HtoIL_apply_params(hBlock,{'p0'},p0);


    if or==1
        mech_orientation='1';
    else
        mech_orientation='-1';
        init_pos.base=['-(',init_pos.base,')'];
    end
    set_param(hBlock,'mech_orientation',mech_orientation);
    HtoIL_apply_params(hBlock,{'x0'},init_pos);




    if isempty(str2num(k_sh))%#ok<*ST2NM>
        k_sh=['''''',k_sh,''''''];
    end

    il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
    il_predefined_properties_block='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Utilities/Isothermal Liquid Predefined Properties (IL)'''' )" >Isothermal Liquid Predefined Properties (IL) block</a>';
    warnings.messages={['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,' or ',il_predefined_properties_block,'.']};

    warnings.subsystem=getfullname(hBlock);

    out.warnings=warnings;
    out.connections=connections;

end

