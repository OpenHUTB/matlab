function out=update_orifice_fixed_inertia(content)









    port_names={'A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(content,port_names);




    param_list={'area','orifice_area_constant';
    'C_d','Cd';
    'Re_cr','Re_c'};

    collected_params=HtoIL_collect_params(content,param_list(:,1));


    lam_spec=get_param(content,'lam_spec');
    B_lam=get_param(content,'B_lam');


    HtoIL_set_block_files(content,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)')


    set_param(content,'orifice_type','1');


    connections.destination_ports=HtoIL_collect_destination_ports(content,[1,2]);

    HtoIL_apply_params(content,param_list(:,2),collected_params);


    set_param(content,'area','inf');


    if strcmp(lam_spec,'1')

        set_param(content,'Re_c','150');
        if strcmp(B_lam,'0.999')
            warnings.messages={'Critical Reynolds number set to 150. Behavior change not expected.'};
        else
            warnings.messages={'Critical Reynolds number set to 150.'};
        end
    else
        warnings.messages={};
    end


    warnings.subsystem=connections.subsystem;
    warnings.messages{end+1,1}='Initial flow rate removed. Adjustment of model initial conditions may be required.';

    pipe_hyperlink='<a href= "matlab: load_system( ''''SimscapeFluids_lib'''' ); open_system( ''''SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings'''' ); hilite_system( ''''SimscapeFluids_lib/Isothermal Liquid/Pipes & Fittings/Pipe (IL)'''' )" >Pipe (IL) block</a>';
    warnings.messages{end+1,1}=['Pressure effects due to fluid inertia removed. Consider modeling fluid inertia with a ',pipe_hyperlink,'.'];

    out.connections=connections;
    out.warnings=warnings;
end