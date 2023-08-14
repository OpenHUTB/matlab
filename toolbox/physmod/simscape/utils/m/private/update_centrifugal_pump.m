function out=update_centrifugal_pump(hBlock)









    port_names={'S','P','T'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);


    param_list={'design_del','capacity_ref_nominal';
    'ref_velocity','omega_ref_analytic';
    'ref_velocity','omega_ref_1D';
    'pump_del_1D','capacity_ref_1D_TLU';
    'pump_del_2D','omega_2D_TLU';
    'pump_del_2D','capacity_2D_TLU';
    'pump_vel_2D','omega_2D_TLU'};



    modelType=get_param(hBlock,'mdl_type');


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    params_derivation=HtoIL_cellToStruct(HtoIL_collect_params(hBlock,...
    {'c_1','c_2','c_3','c_4','c_f',...
    'ref_density',...
    'ref_velocity',...
    'design_del',...
    'T_const',...
    'trq_press_coeff',...
    'press_diff_1D',...
    'press_diff_2D',...
    'pump_del_1D',...
    'pump_del_power_1D',...
    'power_1D',...
    'pump_del_power_2D',...
    'power_2D',...
    'pump_del_2D',...
    'interp_method',...
    'extrap_method'}));


    params_derivation.g.name='g';
    params_derivation.g.base='9.81';
    params_derivation.g.unit='m/s^2';
    params_derivation.g.conf='runtime';



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Centrifugal Pump (IL)')


    switch modelType
    case '1'
        set_param(hBlock,'pump_parameterization','fluids.isothermal_liquid.pumps_motors.enum.centrifugal_pump_spec.table1D');
    case '2'
        set_param(hBlock,'pump_parameterization','fluids.isothermal_liquid.pumps_motors.enum.centrifugal_pump_spec.table1D');
    case '3'
        set_param(hBlock,'pump_parameterization','fluids.isothermal_liquid.pumps_motors.enum.centrifugal_pump_spec.table2D');
    end

    set_param(hBlock,'operation_check','simscape.enum.assert.action.warn');



    connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1,4]);


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);

    if strcmp(modelType,'2')
        HtoIL_apply_params(hBlock,{'rho_ref_1D'},params_derivation.ref_density);
    elseif strcmp(modelType,'3')
        HtoIL_apply_params(hBlock,{'rho_ref_2D'},params_derivation.ref_density);
    end



    if strcmp(modelType,'1')

        name='A';
        math_expression='-c_3 - c_4';
        dialog_unit_expression='c_3';
        evaluate=1;
        params_derivation.A=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


        name='B';
        math_expression='-c_f*c_2 + 2*c_4*design_del';
        dialog_unit_expression='c_2';
        evaluate=1;
        params_derivation.B=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


        name='C';
        math_expression='c_f*c_1 - c_4*design_del*design_del';
        dialog_unit_expression='c_1';
        evaluate=1;
        params_derivation.C=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


        name='term1_intmdt';
        math_expression='B*B - 4*A*C';
        dialog_unit_expression='B*B';
        evaluate=1;
        params_derivation.term1_intmdt=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


        params_derivation.term1=params_derivation.term1_intmdt;
        params_derivation.term1.base=['(',params_derivation.term1_intmdt.base,')^0.5'];
        params_derivation.term1.unit=['(',params_derivation.term1_intmdt.unit,')^0.5'];


        name='capacity_ref_max';
        math_expression='-B/2/A - term1/2/A';
        dialog_unit_expression='design_del';
        evaluate=1;
        capacity_ref_max=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);


        capacity_ref_1D_TLU=capacity_ref_max;

        capacity_ref_1D_TLU.name='capacity_ref_1D_TLU';
        capacity_ref_1D_TLU.base=['linspace(0, (',capacity_ref_max.base,')*0.99, 20)'];
        params_derivation.capacity_ref_1D_TLU=capacity_ref_1D_TLU;

        HtoIL_apply_params(hBlock,{'capacity_ref_1D_TLU'},capacity_ref_1D_TLU);


        name='head_ref_1d_TLU';
        math_expression='A*capacity_ref_1D_TLU*capacity_ref_1D_TLU/g + B*capacity_ref_1D_TLU/g + C/g';
        dialog_unit_expression='C/g';
        evaluate=0;
        head_ref_1d_TLU=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);

        head_ref_1d_TLU.base=strrep(head_ref_1d_TLU.base,'*','.*');

        dialog_param_numeric_value=str2num(head_ref_1d_TLU.base);
        if~isempty(dialog_param_numeric_value)&&~isnan(sum(dialog_param_numeric_value))
            head_ref_1d_TLU.base=['[ ',num2str(dialog_param_numeric_value),' ]'];
        end
        params_derivation.head_ref_1d_TLU=head_ref_1d_TLU;
        HtoIL_apply_params(hBlock,{'head_ref_1d_TLU'},head_ref_1d_TLU);


        name='power_ref_1D_TLU';
        math_expression='ref_density*c_1*c_f*capacity_ref_1D_TLU - ref_density*c_2*c_f*capacity_ref_1D_TLU*capacity_ref_1D_TLU + ref_velocity*T_const + ref_velocity*trq_press_coeff*ref_density*g*head_ref_1d_TLU';
        dialog_unit_expression='ref_density*c_1*capacity_ref_1D_TLU';
        evaluate=0;
        power_ref_1D_TLU=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);

        power_ref_1D_TLU.base=strrep(power_ref_1D_TLU.base,'.*','*');
        power_ref_1D_TLU.base=strrep(power_ref_1D_TLU.base,'*','.*');

        dialog_param_numeric_value=str2num(power_ref_1D_TLU.base);
        if~isempty(dialog_param_numeric_value)&&~isnan(sum(dialog_param_numeric_value))
            power_ref_1D_TLU.base=['[ ',num2str(dialog_param_numeric_value),' ]'];
        end
        params_derivation.power_ref_1D_TLU=power_ref_1D_TLU;
        HtoIL_apply_params(hBlock,{'power_ref_1D_TLU'},power_ref_1D_TLU);


        HtoIL_apply_params(hBlock,{'rho_ref_1D'},params_derivation.ref_density);

    elseif strcmp(modelType,'2')


        H_ref_1D_TLU.base=[params_derivation.press_diff_1D.base,'/',params_derivation.g.base,'/',params_derivation.ref_density.base];
        H_ref_1D_TLU.unit=[params_derivation.press_diff_1D.unit,'/(',params_derivation.g.unit,'*',params_derivation.ref_density.unit,')'];
        H_ref_1D_TLU.conf=params_derivation.press_diff_1D.conf;

        HtoIL_apply_params(hBlock,{'head_ref_1D_TLU'},H_ref_1D_TLU);



        if~strcmp(params_derivation.pump_del_power_1D.base,params_derivation.pump_del_1D.base)





            params_derivation.conversion_factor=params_derivation.pump_del_1D;
            params_derivation.conversion_factor.base='1';
            params_derivation.conversion_factor.name='conversion_factor';
            name='conversion_factor';
            math_expression='conversion_factor';
            dialog_unit_expression='pump_del_power_1D';
            evaluate=1;
            conversion_factor=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);

            power_ref_1D_TLU.base=['interp1(',params_derivation.pump_del_power_1D.base,', ',params_derivation.power_1D.base,', (',params_derivation.pump_del_1D.base,')*(',conversion_factor.base,'), ''linear'', ''extrap'') '];
            power_ref_1D_TLU.unit=params_derivation.power_1D.unit;

            if all(strcmp('runtime',{params_derivation.pump_del_power_1D.conf,params_derivation.power_1D.conf,params_derivation.pump_del_1D.conf}))
                power_ref_1D_TLU.conf='runtime';
            else
                power_ref_1D_TLU.conf='compiletime';
            end
        else
            power_ref_1D_TLU=params_derivation.power_1D;
        end

        HtoIL_apply_params(hBlock,{'power_ref_1D_TLU'},power_ref_1D_TLU);

    else


        H_2D_TLU.base=[params_derivation.press_diff_2D.base,'/',params_derivation.g.base,'/',params_derivation.ref_density.base];
        H_2D_TLU.unit=[params_derivation.press_diff_2D.unit,'/(',params_derivation.g.unit,'*',params_derivation.ref_density.unit,')'];
        H_2D_TLU.conf=params_derivation.press_diff_2D.conf;

        HtoIL_apply_params(hBlock,{'head_2D_TLU'},H_2D_TLU);



        if~strcmp(params_derivation.pump_del_power_2D.base,params_derivation.pump_del_2D.base)





            params_derivation.conversion_factor=params_derivation.pump_del_2D;
            params_derivation.conversion_factor.base='1';
            params_derivation.conversion_factor.name='conversion_factor';
            name='conversion_factor';
            math_expression='conversion_factor';
            dialog_unit_expression='pump_del_power_2D';
            evaluate=1;
            conversion_factor=HtoIL_derive_params(name,math_expression,params_derivation,dialog_unit_expression,evaluate);

            power_2D_TLU.base=['interp1(',params_derivation.pump_del_power_2D.base,', ',params_derivation.power_2D.base,', (',params_derivation.pump_del_2D.base,')*(',conversion_factor.base,'), ''linear'', ''extrap'') '];
            power_2D_TLU.unit=params_derivation.power_2D.unit;

            if all(strcmp('runtime',{params_derivation.pump_del_power_2D.conf,params_derivation.power_2D.conf,params_derivation.pump_del_2D.conf}))
                power_2D_TLU.conf='runtime';
            else
                power_2D_TLU.conf='compiletime';
            end
        else
            power_2D_TLU=params_derivation.power_2D;
        end

        HtoIL_apply_params(hBlock,{'power_2D_TLU'},power_2D_TLU);

    end





    rotational_reference_block=add_block('fl_lib/Mechanical/Rotational Elements/Mechanical Rotational Reference',[connections.subsystem,'/Mechanical Rotational Reference']);
    rotational_reference_port=get_param(rotational_reference_block,'PortHandles').LConn;
    pump_ports=get_param(hBlock,'PortHandles');
    pump_C_port=pump_ports.RConn(2);
    add_line(connections.subsystem,pump_C_port,rotational_reference_port,'autorouting','on');


    warnings.messages={};

    if strcmp(modelType,'1')
        warnings.messages{end+1,1}='Pump reparameterized to use 1D tabulated data. Adjustment of Reference capacity vector, Reference head vector, and Reference brake power vector may be required if pump operates beyond normal pump operation.';
    elseif strcmp(modelType,'2')

        if~strcmp(params_derivation.pump_del_power_1D.base,params_derivation.pump_del_1D.base)
            warnings.messages{end+1,1}='Reference brake power vector interpolated to correspond to Reference capacity vector. Adjustment of Reference capacity vector, Reference head vector, and Reference brake power vector may be required.';
        end
        if strcmp(params_derivation.interp_method.base,'2')
            warnings.messages{end+1,1}='Interpolation method changed to Linear. Additional elements in the Reference capacity vector, Reference head vector, Reference brake power vector, and Reference shaft speed may be required.';
        end
        if strcmp(params_derivation.extrap_method.base,'2')
            warnings.messages{end+1,1}='Extrapolation method changed to Linear. Extension of the Reference capacity vector, Reference head vector, Reference brake power vector, and Reference shaft speed may be required.';
        end

    else

        if~strcmp(params_derivation.pump_del_power_2D.base,params_derivation.pump_del_2D.base)
            warnings.messages{end+1,1}='Brake power table interpolated to correspond to Capacity vector. Adjustment of Capacity vector, Head table, and Brake power table may be required.';
        end
        if strcmp(params_derivation.interp_method.base,'2')
            warnings.messages{end+1,1}='Interpolation method changed to Linear. Additional elements in the Capacity vector, Shaft speed vector, Head table, and Brake power table may be required.';
        end
        if strcmp(params_derivation.extrap_method.base,'2')
            warnings.messages{end+1,1}='Extrapolation method changed to Linear. Extension of the Capacity vector, Shaft speed vector, Head table, and Brake power table may be required.';
        end

    end

    if strcmp(modelType,'3')
        warnings.messages{end+1,1}='Angular speed threshold for flow reversal set to 0.01% of mean value of first and last elements of Shaft speed vector. Behavior change not expected.';
    else
        warnings.messages{end+1,1}='Angular speed threshold for flow reversal set to 0.01% of Reference shaft speed. Behavior change not expected.';
    end


    warnings.subsystem=getfullname(hBlock);
    out.warnings=warnings;

    out.connections=connections;

end

