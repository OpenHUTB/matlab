function out=update_tank_var_head(hBlock)






    SourceFile=get_param(hBlock,'SourceFile');
    if strcmp(SourceFile,'sh.low_pressure_blocks.tank_var_head')
        num_inlet=1;
        port_names={'V','A'};
    elseif strcmp(SourceFile,'sh.low_pressure_blocks.tank_var_head_two_arm')
        num_inlet=2;
        port_names={'B','V','A'};
    else
        num_inlet=3;
        port_names={'V','B','A','C'};
    end



    [out.connections.subsystem,out.connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    param_list={'level_spec','volume_spec';
    'fluid_level_tab','level_TLU';
    'fluid_volume_tab','volume_TLU';
    'fluid_level_check','level_check'};










    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));
    collected_vars=HtoIL_collect_vars(hBlock,{'volume';'level'},'sh_lib/Low-Pressure Blocks/Tank');


    collected_reference_block=getSimulinkBlockHandle(get_param(hBlock,'ReferenceBlock'));


    if num_inlet==1
        params_for_derivation=HtoIL_collect_params(hBlock,...
        {'press';'pipe_diam';'loss_coeff'});
    elseif num_inlet==2
        params_for_derivation=HtoIL_collect_params(hBlock,...
        {'press';'height_B';'pipe_diam_A';'pipe_diam_B';'loss_coeff_A';'loss_coeff_B'});
    else
        params_for_derivation=HtoIL_collect_params(hBlock,...
        {'press';'height_B';'height_C';'pipe_diam_A';'pipe_diam_B';'pipe_diam_C';'loss_coeff_A';'loss_coeff_B';'loss_coeff_C'});
    end

    level_spec=get_param(hBlock,'level_spec');
    interp_method=get_param(hBlock,'interp_method');
    extrap_method=get_param(hBlock,'extrap_method');
    fluid_level_check=get_param(hBlock,'fluid_level_check');



    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Tanks & Accumulators/Tank (IL)')



    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);





    if strcmp(collected_vars(1).specify,'off')
        collected_vars(1).base=get_param(collected_reference_block,'volume');
        collected_vars(1).unit=get_param(collected_reference_block,'volume_unit');
    end

    if strcmp(collected_vars(2).specify,'off')
        collected_vars(2).base=get_param(collected_reference_block,'level');
        collected_vars(2).unit=get_param(collected_reference_block,'level_unit');
    end
    collected_vars(1).specify='on';
    collected_vars(2).specify='on';
    HtoIL_apply_vars(hBlock,{'volume';'level'},collected_vars);


    set_param(hBlock,'num_inlet',num2str(num_inlet));


    if num_inlet==1
        out.connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,1]);
    elseif num_inlet==2
        out.connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[2,3,1]);
    else
        out.connections.destination_ports=HtoIL_collect_destination_ports(hBlock,[4,2,1,3]);
    end





    params=HtoIL_cellToStruct(params_for_derivation);


    press_value=str2num(params.press.base);%#ok<ST2NM>
    if~isempty(press_value)&&press_value==0

    else
        set_param(hBlock,'pressure_spec','2')

        tank_pressure=HtoIL_gauge_to_abs('min_valid_pressure',params.press);
        HtoIL_apply_params(hBlock,{'tank_pressure'},tank_pressure);
    end



    evaluate=0;
    if num_inlet==1

        set_param(hBlock,'inlet_height_A','0');


        inlet_area_A.base=['pi/4.*(',params.pipe_diam.base,').^2'];
        inlet_area_A.unit=['(',params.pipe_diam.unit,')^2'];
        inlet_area_A.conf=params.pipe_diam.conf;
        HtoIL_apply_params(hBlock,{'inlet_area_A'},inlet_area_A);


        HtoIL_apply_params(hBlock,{'loss_coeff_A'},params.loss_coeff);
    elseif num_inlet==2

        inlet_height_AB=params.height_B;
        inlet_height_AB.base=['[0, ',inlet_height_AB.base,']'];
        HtoIL_apply_params(hBlock,{'inlet_height_AB'},inlet_height_AB);


        dialog_unit_expression='pipe_diam_A';

        inlet_diam_A=HtoIL_derive_params('inlet_diam_A','pipe_diam_A',params,dialog_unit_expression,evaluate);
        inlet_diam_B=HtoIL_derive_params('inlet_diam_B','pipe_diam_B',params,dialog_unit_expression,evaluate);
        inlet_area_AB=inlet_diam_A;
        inlet_area_AB.base=['pi/4.*([',inlet_diam_A.base,', ',inlet_diam_B.base,']).^2'];
        inlet_area_AB.unit=['(',params.pipe_diam_A.unit,')^2'];
        if all(strcmp('runtime',{params.pipe_diam_A.conf,params.pipe_diam_B.conf}))
            inlet_area_AB.conf='runtime';
        else
            inlet_area_AB.conf='compiletime';
        end
        HtoIL_apply_params(hBlock,{'inlet_area_AB'},inlet_area_AB);


        loss_coeff_AB.base=['[',params.loss_coeff_A.base,', ',params.loss_coeff_B.base,']'];
        loss_coeff_AB.unit='1';
        if all(strcmp('runtime',{params.loss_coeff_A.conf,params.loss_coeff_B.conf}))
            loss_coeff_AB.conf='runtime';
        else
            loss_coeff_AB.conf='compiletime';
        end
        HtoIL_apply_params(hBlock,{'loss_coeff_AB'},loss_coeff_AB);
    else

        inlet_height_ABC=params.height_B;

        dialog_unit_expression='height_B';
        inlet_height_C=HtoIL_derive_params('inlet_height_C','height_C',params,dialog_unit_expression,evaluate);
        inlet_height_ABC.base=['[0, ',params.height_B.base,', ',inlet_height_C.base,']'];
        if all(strcmp('runtime',{params.height_B.conf,params.height_C.conf}))
            inlet_height_ABC.conf='runtime';
        else
            inlet_height_ABC.conf='compiletime';
        end
        HtoIL_apply_params(hBlock,{'inlet_height_ABC'},inlet_height_ABC);



        dialog_unit_expression='pipe_diam_A';
        inlet_diam_A=HtoIL_derive_params('inlet_diam_A','pipe_diam_A',params,dialog_unit_expression,evaluate);
        inlet_diam_B=HtoIL_derive_params('inlet_diam_B','pipe_diam_B',params,dialog_unit_expression,evaluate);
        inlet_diam_C=HtoIL_derive_params('inlet_diam_C','pipe_diam_C',params,dialog_unit_expression,evaluate);
        inlet_area_ABC=inlet_diam_A;
        inlet_area_ABC.base=['pi/4.*([',inlet_diam_A.base,', ',inlet_diam_B.base,', ',inlet_diam_C.base,']).^2'];
        inlet_area_ABC.unit=['(',params.pipe_diam_A.unit,')^2'];
        if all(strcmp('runtime',{params.pipe_diam_A.conf,params.pipe_diam_B.conf,params.pipe_diam_C.conf}))
            inlet_area_ABC.conf='runtime';
        else
            inlet_area_ABC.conf='compiletime';
        end
        HtoIL_apply_params(hBlock,{'inlet_area_ABC'},inlet_area_ABC);


        loss_coeff_ABC.base=['[',params.loss_coeff_A.base,', ',params.loss_coeff_B.base,', ',params.loss_coeff_C.base,']'];
        loss_coeff_ABC.unit='1';
        if all(strcmp('runtime',{params.loss_coeff_A.conf,params.loss_coeff_B.conf,params.loss_coeff_C.conf}))
            loss_coeff_ABC.conf='runtime';
        else
            loss_coeff_ABC.conf='compiletime';
        end
        HtoIL_apply_params(hBlock,{'loss_coeff_ABC'},loss_coeff_ABC);
    end


    warnings.subsystem=getfullname(hBlock);
    warnings.messages={};

    if strcmp(fluid_level_check,'1')
        warnings.messages{end+1,1}='Warning for minimum fluid level converted to warning for liquid level below inlet height. Adjustment of Warning setting may be required';
    end
    if strcmp(level_spec,'2')&&strcmp(extrap_method,'2')
        warnings.messages{end+1,1}='Extrapolation method changed to Linear. Extension of Liquid level vector and Liquid volume vector may be required.';
    end
    if strcmp(level_spec,'2')&&strcmp(interp_method,'2')
        warnings.messages{end+1,1}='Interpolation method changed to Linear. Additional elements in Liquid level vector and Liquid volume vector may be required.';
    end

    if~isempty(warnings.messages)
        out.warnings=warnings;
    end

end