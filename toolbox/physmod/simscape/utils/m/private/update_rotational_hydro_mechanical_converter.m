function out=update_rotational_hydro_mechanical_converter(hBlock)








    rotation_spec=eval(get_param(hBlock,'rotation_spec'));

    if rotation_spec==1
        port_names={'C','A','S'};
    else
        port_names={'C','A','S','q'};
    end
    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'D','volume_displacement';
    'initial_angle','theta0';
    'V_dead','dead_volume';
    'compressibility','dynamic_compressibility'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    or=get_param(hBlock,'or');
    initial_pressure=HtoIL_collect_params(hBlock,{'initial_pressure'});

    compressibility=eval(get_param(hBlock,'compressibility'));
    k_sh=get_param(hBlock,'k_sh');
    initial_angle=get_param(hBlock,'initial_angle');
    initial_angle_unit=get_param(hBlock,'initial_angle_unit');
    V_dead=get_param(hBlock,'V_dead');
    V_dead_unit=get_param(hBlock,'V_dead_unit');


    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Rotational Mechanical Converter (IL)')
    set_param(hBlock,'pressure_spec','1');

    if rotation_spec==1
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[3,1,2]);
    else
        connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[4,1,3,2]);
    end


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    if strcmp(or,'1')
        mech_orientation='1';
    else
        mech_orientation='-1';

        set_param(hBlock,'theta0',['-(',initial_angle,')']);
    end
    set_param(hBlock,'mech_orientation',mech_orientation);


    p0=HtoIL_gauge_to_abs('p0',initial_pressure);
    HtoIL_apply_params(hBlock,{'p0'},p0);



    if compressibility==1

        if isempty(str2num(k_sh))%#ok<*ST2NM>
            k_sh=['''''',k_sh,''''''];
        end

        il_properties_block_hyperlink='<a href= "matlab: load_system( ''''fl_lib'''' ); open_system( ''''fl_lib/Isothermal Liquid/Utilities'''' ); hilite_system( ''''fl_lib/Isothermal Liquid/Utilities/Isothermal Liquid Properties (IL)'''' )" >Isothermal Liquid Properties (IL) block</a>';
        warnings.messages={['Original block had Specific heat ratio of ',k_sh,'. Set Air polytropic index to this value in an ',il_properties_block_hyperlink,'.']};

    else

        if isempty(str2num(initial_angle))%#ok<*ST2NM>
            initial_angle=['''''',initial_angle,''''''];
        end
        if isempty(str2num(V_dead))%#ok<*ST2NM>
            V_dead=['''''',V_dead,''''''];
        end
        warnings.messages={['Block uses Interface initial rotation of ',initial_angle,' ',initial_angle_unit,'. Adjustment of Interface initial rotation may be required.'];
        ['Block uses Dead volume of ',V_dead,' ',V_dead_unit,'. Adjustment of Dead volume may be required.']};
    end

    warnings.subsystem=getfullname(hBlock);

    out.connections=connections;
    out.warnings=warnings;

end

