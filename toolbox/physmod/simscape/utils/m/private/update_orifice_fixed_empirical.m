function out=update_orifice_fixed_empirical(hBlock)








    port_names={'A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'pressure_tab','p_diff_TLU_constant'
    'flow_rate_tab','vol_flow_TLU_constant'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    interp_method=get_param(hBlock,'interp_method');
    extrap_method=get_param(hBlock,'extrap_method');
    pressure_tab=HtoIL_collect_params(hBlock,{'pressure_tab'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)')


    set_param(hBlock,'orifice_type','1');
    set_param(hBlock,'constant_orifice_spec','2');


    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    warnings.messages={};

    if strcmp(interp_method,'2')
        warnings.messages{end+1,1}='Interpolation method changed to Linear. Additional elements in Pressure drop vector and Volumetric flow rate vector may be required.';
    end
    if strcmp(extrap_method,'2')
        warnings.messages{end+1,1}='Extrapolation method changed to Linear. Extension of Pressure drop vector and Volumetric flow rate vector may be required.';
    end

    pressure_tab_first=HtoIL_get_vector_element(pressure_tab,'first');
    pressure_tab_first_value=str2num(pressure_tab_first.base);
    if isempty(pressure_tab_first_value)||pressure_tab_first_value>=0

        warnings.messages{end+1,1}=['If all values of the Pressure drop vector are greater than 0, '...
        ,'then the block internally extends the Pressure drop vector and Volumetric flow rate vectors to contain negative values. '...
        ,'Adjustment of these parameters may be required.'];
    end

    if isempty(warnings.messages)
        warnings={};
    else
        warnings.subsystem=getfullname(hBlock);
    end

    out.connections=connections;
    out.warnings=warnings;

end