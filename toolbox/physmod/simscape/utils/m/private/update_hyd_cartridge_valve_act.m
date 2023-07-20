function out=update_hyd_cartridge_valve_act(hBlock)








    param_list={...
    'ar_ratio','area_A_X_ratio';...
    'frc_preload','preload_force';...
    'spr_rate','stiff_coeff';...
    'poppet_str','stroke';...
    'time_constant','tau'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));








    act_orientation=get_param(hBlock,'act_orientation');


    x_0=get_param(hBlock,'x_0');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Valves & Orifices/Valve Actuators & Forces/Cartridge Valve Actuator (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'actuator_dynamics','1');
    set_param(hBlock,'smoothing_factor','0');


    if strcmp(act_orientation,'1')
        set_param(hBlock,'mech_orientation','1');
    else
        set_param(hBlock,'mech_orientation','-1');
    end


    warnings.messages={'Poppet-seat initial gap removed. Adjustment of model initial conditions may be required.'};
    warnings.subsystem=getfullname(hBlock);


    out.warnings=warnings;

end



