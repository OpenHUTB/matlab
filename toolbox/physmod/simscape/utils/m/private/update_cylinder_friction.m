function out=update_cylinder_friction(hBlock)







    param_list={...
    'frc_preload','preload_force';...
    'fr_coef','Coulomb_coeff';...
    'frc_brkwy_coef','breakaway_Coulomb_ratio';...
    'visc_coef','viscous_coeff';...
    'vel_thr','breakaway_velocity'};

    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));


    beginning_variables=HtoIL_collect_vars(hBlock,{'flow_rate_A';'flow_rate_B';'friction_force';'rel_velocity'},'sh_lib/Hydraulic Cylinders/Cylinder Friction');
    beginning_variable_names={'Flow rate at port A';'Flow rate at port B';'Friction force';'Relative velocity'};


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Actuators/Auxiliary Components/Cylinder Friction (IL)')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    warnings.subsystem=getfullname(hBlock);






    warnings.messages={'Breakaway friction velocity has been reparameterized. Adjustment of Breakaway friction velocity may be required.'};


    warnings.messages=HtoIL_add_beginning_value_warning(warnings.messages,beginning_variables,beginning_variable_names);

    out.warnings=warnings;

end



