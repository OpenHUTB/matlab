function out=update_constant_area_orifice(hBlock)









    port_names={'A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'area','restriction_area'
    'C_d','Cd';
    'Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    beginning_variables=HtoIL_collect_vars(hBlock,{'q';'p'},['fl_lib/Hydraulic/Hydraulic Elements/Constant Area',newline,'Hydraulic Orifice']);
    beginning_variable_names={'Flow rate';'Pressure differential'};


    lam_spec=get_param(hBlock,'lam_spec');
    B_lam=get_param(hBlock,'B_lam');

    HtoIL_set_block_files(hBlock,'fl_lib/Isothermal Liquid/Elements/Local Restriction (IL)')
    set_param(hBlock,'restriction_type','1')
    set_param(hBlock,'area','inf')

    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[1,2]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    if strcmp(lam_spec,'1')

        set_param(hBlock,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages={'Critical Reynolds number set to 150. Behavior change not expected.'};
        else
            warnings.messages={'Critical Reynolds number set to 150.'};
        end
    else
        warnings.messages={};
    end


    warnings.subsystem=connections.subsystem;


    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);

    out.connections=connections;
    out.warnings=warnings;


end