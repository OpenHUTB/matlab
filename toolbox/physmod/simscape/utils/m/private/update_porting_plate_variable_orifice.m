function out=update_porting_plate_variable_orifice(hBlock)







    param_list={...
    'piston_pitch_radius','piston_pitch_radius';...
    'orifice_diam','orifice_diameter';...
    'pressure_angle','press_angle';...
    'phase_angle','phase_angle';...


    'C_d','Cd';...
    'Re_cr','Re_c';...
    'A_leak','area_leak'};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Auxiliary Components/Valve Plate Orifice (IL)');


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);


    set_param(hBlock,'smoothing_factor','0');


    warnings.messages={'Transition slot angle and Transition slot maximum area removed due to block reparameterization. Significant behavior change not expected.'};
    warnings.subsystem=getfullname(hBlock);
    out.warnings=warnings;

end



