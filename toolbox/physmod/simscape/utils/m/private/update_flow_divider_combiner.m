function out=update_flow_divider_combiner(hBlock)







    port_names={'P','A','B'};

    [connections.subsystem,connections.source_ports]=HtoIL_collect_source_ports(hBlock,port_names);




    fixed_orifice_A_param_list={...
    'area_or_A','orifice_area_constant';
    'C_d_or','Cd';
    'Re_cr_or','Re_c'};
    fixed_orifice_A_collected_params=HtoIL_collect_params(hBlock,fixed_orifice_A_param_list(:,1));

    fixed_orifice_B_param_list={...
    'area_or_B','orifice_area_constant';
    'C_d_or','Cd';
    'Re_cr_or','Re_c'};
    fixed_orifice_B_collected_params=HtoIL_collect_params(hBlock,fixed_orifice_B_param_list(:,1));

    piston_A_param_list={...
    'piston_A_area','piston_area_A';
    'piston_A_area','piston_area_B';
    'piston_A_stroke','stroke'};
    piston_A_collected_params=HtoIL_collect_params(hBlock,piston_A_param_list(:,1));

    piston_B_param_list={...
    'piston_B_area','piston_area_A';
    'piston_B_area','piston_area_B';
    'piston_B_stroke','stroke';
    'piston_B_init_pos','x0'};
    piston_B_collected_params=HtoIL_collect_params(hBlock,piston_B_param_list(:,1));

    spring_A_param_list={...
    'spring_A_rate','spr_rate';
    'spring_A_preload','x'};
    spring_A_collected_params=HtoIL_collect_params(hBlock,spring_A_param_list(:,1));

    spring_B_param_list={...
    'spring_B_rate','spr_rate';
    'spring_B_preload','x'};
    spring_B_collected_params=HtoIL_collect_params(hBlock,spring_B_param_list(:,1));

    spring_A_B_param_list={...
    'spring_A_B_rate','spr_rate';
    'spring_A_B_preload','x'};
    spring_A_B_collected_params=HtoIL_collect_params(hBlock,spring_A_B_param_list(:,1));

    damper_A_param_list={'damping_A','D'};
    damper_A_collected_params=HtoIL_collect_params(hBlock,damper_A_param_list(:,1));

    damper_B_param_list={...
    'damping_B','D'};
    damper_B_collected_params=HtoIL_collect_params(hBlock,damper_B_param_list(:,1));

    damper_A_B_param_list={'damping_A_B','D'};
    damper_A_B_collected_params=HtoIL_collect_params(hBlock,damper_A_B_param_list(:,1));

    hard_stop_param_list={...
    'hs_upper_bound','upper_bnd';
    'hs_lower_bound','lower_bnd';
    'stop_stiffness','stiff_up';
    'stop_stiffness','stiff_low';
    'stop_damping','D_up';
    'stop_damping','D_low';
    'hardstop_model','model';
    'transition','transition'};
    hard_stop_collected_params=HtoIL_collect_params(hBlock,hard_stop_param_list(:,1));

    variable_orifice_A_param_list={...
    'var_or_A_hole_diam','diameter_hole';
    'orifice_numb','num_hole';
    'C_d_var_or','Cd';
    'leak_area','area_leak';
    'Re_cr_var_or','Re_c';
    'init_A','S_min'};
    variable_orifice_A_collected_params=HtoIL_collect_params(hBlock,variable_orifice_A_param_list(:,1));

    variable_orifice_B_param_list={...
    'var_or_B_hole_diam','diameter_hole';
    'orifice_numb','num_hole';
    'C_d_var_or','Cd';
    'leak_area','area_leak';
    'Re_cr_var_or','Re_c';
    'init_B','S_min'};
    variable_orifice_B_collected_params=HtoIL_collect_params(hBlock,variable_orifice_B_param_list(:,1));



    fixed_orifice_lam_spec=get_param(hBlock,'lam_spec_or');
    B_lam_or=get_param(hBlock,'B_lam_or');
    piston_A_init_pos=HtoIL_collect_params(hBlock,{'piston_A_init_pos'});
    variable_orifice_lam_spec=get_param(hBlock,'lam_spec_or');
    B_lam_var_or=get_param(hBlock,'B_lam_var_or');
    variable_orifice_init_A=HtoIL_collect_params(hBlock,{'init_A'});
    variable_orifice_init_B=HtoIL_collect_params(hBlock,{'init_B'});



    delete_block(hBlock);


    fixed_orifice_A_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',...
    [connections.subsystem,'/Fixed Orifice A']);
    set_param(fixed_orifice_A_block,'Position','[555   480   615   510]');

    set_param(fixed_orifice_A_block,'orifice_type','1');
    HtoIL_apply_params(fixed_orifice_A_block,fixed_orifice_A_param_list(:,2),fixed_orifice_A_collected_params);

    fixed_orifice_A_port_A=get_param(fixed_orifice_A_block,'PortHandles').LConn;
    fixed_orifice_A_port_B=get_param(fixed_orifice_A_block,'PortHandles').RConn;


    fixed_orifice_B_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Orifice (IL)',...
    [connections.subsystem,'/Fixed Orifice B']);
    set_param(fixed_orifice_B_block,'Position','[215   480   275   510]')
    set_param(fixed_orifice_B_block,'Orientation','left')

    set_param(fixed_orifice_B_block,'orifice_type','1');
    HtoIL_apply_params(fixed_orifice_B_block,fixed_orifice_B_param_list(:,2),fixed_orifice_B_collected_params);

    fixed_orifice_B_port_A=get_param(fixed_orifice_B_block,'PortHandles').LConn;
    fixed_orifice_B_port_B=get_param(fixed_orifice_B_block,'PortHandles').RConn;


    piston_A_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Actuators/Double-Acting Actuator (IL)',...
    [connections.subsystem,'/Piston A']);
    set_param(piston_A_block,'Position','[495   380   575   420]')
    set_param(piston_A_block,'Orientation','left')

    HtoIL_apply_params(piston_A_block,piston_A_param_list(:,2),piston_A_collected_params);
    set_param(piston_A_block,'dynamic_compressibility','0');
    set_param(piston_A_block,'mech_orientation','-1');
    piston_A_init_pos.base=['-(',piston_A_init_pos.base,')'];
    HtoIL_apply_params(piston_A_block,{'x0'},piston_A_init_pos);
    set_param(piston_A_block,'smoothing_factor_A','0');
    set_param(piston_A_block,'smoothing_factor_B','0');

    piston_A_port_P=get_param(piston_A_block,'PortHandles').RConn(1);
    piston_A_port_C=get_param(piston_A_block,'PortHandles').LConn(1);
    piston_A_port_A=get_param(piston_A_block,'PortHandles').LConn(2);
    piston_A_port_R=get_param(piston_A_block,'PortHandles').RConn(2);
    piston_A_port_B=get_param(piston_A_block,'PortHandles').RConn(3);


    piston_A_ground_block=add_block('fl_lib/Mechanical/Translational Elements/Mechanical Translational Reference',...
    [connections.subsystem,'/Mechanical Translational Reference1']);
    set_param(piston_A_ground_block,'Position','[605   380   625   400]');
    set_param(piston_A_ground_block,'Orientation','right');
    set_param(piston_A_ground_block,'ShowName','off');
    piston_A_ground_port=get_param(piston_A_ground_block,'PortHandles').LConn;


    piston_B_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Actuators/Double-Acting Actuator (IL)',...
    [connections.subsystem,'/Piston B']);
    set_param(piston_B_block,'Position','[240   380   320   420]');

    HtoIL_apply_params(piston_B_block,piston_B_param_list(:,2),piston_B_collected_params);
    set_param(piston_B_block,'dynamic_compressibility','0');
    set_param(piston_B_block,'smoothing_factor_A','0');
    set_param(piston_B_block,'smoothing_factor_B','0');

    piston_B_port_P=get_param(piston_B_block,'PortHandles').RConn(1);
    piston_B_port_C=get_param(piston_B_block,'PortHandles').LConn(1);
    piston_B_port_A=get_param(piston_B_block,'PortHandles').LConn(2);
    piston_B_port_R=get_param(piston_B_block,'PortHandles').RConn(2);
    piston_B_port_B=get_param(piston_B_block,'PortHandles').RConn(3);


    piston_B_ground_block=add_block('fl_lib/Mechanical/Translational Elements/Mechanical Translational Reference',...
    [connections.subsystem,'/Mechanical Translational Reference2']);
    set_param(piston_B_ground_block,'Position','[185   380   205   400]');
    set_param(piston_B_ground_block,'Orientation','left')
    set_param(piston_B_ground_block,'ShowName','off');
    piston_B_ground_port=get_param(piston_B_ground_block,'PortHandles').LConn;


    spring_A_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Spring',...
    [connections.subsystem,'/Spring A']);
    set_param(spring_A_block,'Position','[505   326   545   354]')
    HtoIL_apply_params(spring_A_block,spring_A_param_list(:,2),spring_A_collected_params);
    set_param(spring_A_block,'x_specify','on');
    set_param(spring_A_block,'x_priority','High');
    spring_A_port_R=get_param(spring_A_block,'PortHandles').LConn;
    spring_A_port_C=get_param(spring_A_block,'PortHandles').RConn;


    spring_B_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Spring',...
    [connections.subsystem,'/Spring B']);
    set_param(spring_B_block,'Position','[260   326   300   354]')
    set_param(spring_B_block,'Orientation','left')
    HtoIL_apply_params(spring_B_block,spring_B_param_list(:,2),spring_B_collected_params);
    set_param(spring_B_block,'x_specify','on');
    set_param(spring_B_block,'x_priority','High');
    spring_B_port_R=get_param(spring_B_block,'PortHandles').LConn;
    spring_B_port_C=get_param(spring_B_block,'PortHandles').RConn;


    spring_A_B_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Spring',...
    [connections.subsystem,'/Spring A-B']);
    set_param(spring_A_B_block,'Position','[380   326   420   354]')
    HtoIL_apply_params(spring_A_B_block,spring_A_B_param_list(:,2),spring_A_B_collected_params);
    set_param(spring_A_B_block,'x_specify','on');
    set_param(spring_A_B_block,'x_priority','High');
    spring_A_B_port_R=get_param(spring_A_B_block,'PortHandles').LConn;
    spring_A_B_port_C=get_param(spring_A_B_block,'PortHandles').RConn;


    damper_A_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Damper',...
    [connections.subsystem,'/Damper A']);
    set_param(damper_A_block,'Position','[505   251   545   279]')
    HtoIL_apply_params(damper_A_block,damper_A_param_list(:,2),damper_A_collected_params);
    damper_A_port_R=get_param(damper_A_block,'PortHandles').LConn;
    damper_A_port_C=get_param(damper_A_block,'PortHandles').RConn;


    damper_B_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Damper',...
    [connections.subsystem,'/Damper B']);
    set_param(damper_B_block,'Position','[260   251   300   279]')
    set_param(damper_B_block,'Orientation','left')
    HtoIL_apply_params(damper_B_block,damper_B_param_list(:,2),damper_B_collected_params);
    damper_B_port_R=get_param(damper_B_block,'PortHandles').LConn;
    damper_B_port_C=get_param(damper_B_block,'PortHandles').RConn;


    damper_A_B_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Damper',...
    [connections.subsystem,'/Damper A-B']);
    set_param(damper_A_B_block,'Position','[380   251   420   279]');
    set_param(damper_A_B_block,'Orientation','left')
    HtoIL_apply_params(damper_A_B_block,damper_A_B_param_list(:,2),damper_A_B_collected_params);
    damper_A_B_port_R=get_param(damper_A_B_block,'PortHandles').LConn;
    damper_A_B_port_C=get_param(damper_A_B_block,'PortHandles').RConn;


    variable_orifice_A_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Spool Orifice (IL)',...
    [connections.subsystem,'/Variable Orifice A']);
    set_param(variable_orifice_A_block,'Position','[617    90   652   141]')
    set_param(variable_orifice_A_block,'Orientation','up')

    HtoIL_apply_params(variable_orifice_A_block,variable_orifice_A_param_list(:,2),variable_orifice_A_collected_params);
    variable_orifice_init_A.base=['-(',variable_orifice_init_A.base,')'];
    HtoIL_apply_params(variable_orifice_A_block,{'S_min'},variable_orifice_init_A);
    set_param(variable_orifice_A_block,'smoothing_factor','0');

    variable_orifice_A_port_S=get_param(variable_orifice_A_block,'PortHandles').LConn(1);
    variable_orifice_A_port_A=get_param(variable_orifice_A_block,'PortHandles').LConn(2);
    variable_orifice_A_port_B=get_param(variable_orifice_A_block,'PortHandles').RConn;


    variable_orifice_B_block=add_block('SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Orifices/Spool Orifice (IL)',...
    [connections.subsystem,'/Variable Orifice B']);
    set_param(variable_orifice_B_block,'Position','[152    95   187   146]')
    set_param(variable_orifice_B_block,'Orientation','up')

    HtoIL_apply_params(variable_orifice_B_block,variable_orifice_B_param_list(:,2),variable_orifice_B_collected_params);
    variable_orifice_init_B.base=['-(',variable_orifice_init_B.base,')'];
    HtoIL_apply_params(variable_orifice_B_block,{'S_min'},variable_orifice_init_B);
    set_param(variable_orifice_B_block,'smoothing_factor','0');

    variable_orifice_B_port_S=get_param(variable_orifice_B_block,'PortHandles').LConn(1);
    variable_orifice_B_port_A=get_param(variable_orifice_B_block,'PortHandles').LConn(2);
    variable_orifice_B_port_B=get_param(variable_orifice_B_block,'PortHandles').RConn;


    hard_stop_block=add_block('fl_lib/Mechanical/Translational Elements/Translational Hard Stop',...
    [connections.subsystem,'/Hard Stop A-B']);
    set_param(hard_stop_block,'Position','[380   380   420   400]')
    HtoIL_apply_params(hard_stop_block,hard_stop_param_list(:,2),hard_stop_collected_params);
    hard_stop_port_R=get_param(hard_stop_block,'PortHandles').LConn;
    hard_stop_port_C=get_param(hard_stop_block,'PortHandles').RConn;






    add_line(connections.subsystem,fixed_orifice_A_port_A,fixed_orifice_B_port_A,'autorouting','on');
    add_line(connections.subsystem,piston_A_port_B,piston_B_port_B,'autorouting','on');
    add_line(connections.subsystem,fixed_orifice_A_port_A,piston_A_port_B,'autorouting','on');


    add_line(connections.subsystem,fixed_orifice_A_port_B,piston_A_port_A,'autorouting','on');
    add_line(connections.subsystem,piston_A_port_A,variable_orifice_A_port_A,'autorouting','on');


    add_line(connections.subsystem,fixed_orifice_B_port_B,piston_B_port_A,'autorouting','on');
    add_line(connections.subsystem,piston_B_port_A,variable_orifice_B_port_A,'autorouting','on');


    add_line(connections.subsystem,piston_A_port_C,spring_A_port_C,'autorouting','on');
    add_line(connections.subsystem,spring_A_port_C,damper_A_port_C,'autorouting','on');
    add_line(connections.subsystem,piston_B_port_C,spring_B_port_C,'autorouting','on');
    add_line(connections.subsystem,spring_B_port_C,damper_B_port_C,'autorouting','on');
    add_line(connections.subsystem,piston_A_port_C,piston_A_ground_port,'autorouting','on');
    add_line(connections.subsystem,piston_B_port_C,piston_B_ground_port,'autorouting','on');


    add_line(connections.subsystem,piston_A_port_R,hard_stop_port_C,'autorouting','on');
    add_line(connections.subsystem,spring_A_B_port_C,spring_A_port_R,'autorouting','on');
    add_line(connections.subsystem,damper_A_port_R,damper_A_B_port_R,'autorouting','on');
    add_line(connections.subsystem,spring_A_B_port_C,damper_A_port_R,'autorouting','on');
    add_line(connections.subsystem,spring_A_B_port_C,hard_stop_port_C,'autorouting','on');


    add_line(connections.subsystem,piston_B_port_R,hard_stop_port_R,'autorouting','on');
    add_line(connections.subsystem,spring_A_B_port_R,spring_B_port_R,'autorouting','on');
    add_line(connections.subsystem,damper_B_port_R,damper_A_B_port_C,'autorouting','on');
    add_line(connections.subsystem,spring_A_B_port_R,hard_stop_port_R,'autorouting','on');
    add_line(connections.subsystem,spring_A_B_port_R,damper_A_B_port_C,'autorouting','on');


    add_line(connections.subsystem,piston_A_port_P,variable_orifice_A_port_S,'autorouting','on');
    add_line(connections.subsystem,piston_B_port_P,variable_orifice_B_port_S,'autorouting','on');


    connections.destination_ports=[fixed_orifice_A_port_A,variable_orifice_A_port_B,variable_orifice_B_port_B];
    out.connections=connections;


    if(getSimulinkBlockHandle([connections.subsystem,'/A'])~=-1)
        set_param([connections.subsystem,'/A'],'Position','[670    53   700    67]');
    end
    if(getSimulinkBlockHandle([connections.subsystem,'/B'])~=-1)
        set_param([connections.subsystem,'/B'],'Position','[190    53   220    67]');
    end
    if(getSimulinkBlockHandle([connections.subsystem,'/P'])~=-1)
        set_param([connections.subsystem,'/P'],'Position','[385   533   415   547]');
    end




    warnings.messages={'Hard-stop model in Pistons A and B has been reparameterized and uses default parameter values. Adjustment of Hard Stop parameters may be required.';
    'New parameters Dead volume in Chambers A and B in Pistons A and B set to 1e-5 m^3. Adjustment of these parameters may be required.'};

    if strcmp(fixed_orifice_lam_spec,'1')

        set_param(fixed_orifice_A_block,'Re_c','150');
        set_param(fixed_orifice_B_block,'Re_c','150');
        if strcmp(B_lam_or,'0.999')
            warnings.messages{end+1,1}='Fixed Orifices Critical Reynolds numbers set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Fixed Orifices Critical Reynolds numbers set to 150.';
        end
    end


    if strcmp(variable_orifice_lam_spec,'1')

        set_param(variable_orifice_A_block,'Re_c','150');
        set_param(variable_orifice_B_block,'Re_c','150');
        if strcmp(B_lam_var_or,'0.999')
            warnings.messages{end+1,1}='Variable Orifices Critical Reynolds numbers set to 150. Behavior change not expected.';
        else
            warnings.messages{end+1,1}='Variable Orifices Critical Reynolds numbers set to 150.';
        end
    end

    warnings.subsystem=connections.subsystem;
    out.warnings=warnings;
end



