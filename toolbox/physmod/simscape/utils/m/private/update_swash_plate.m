function out=update_swash_plate(hBlock)







    param_list={...
    'act_arm','actuator_arm';...
    'pitch_rad','pitch_radius';...
    'h_off','h_offset';...
    'mu_visc','mu_visc'};


    collected_params=HtoIL_collect_params(hBlock,param_list(:,1));
    collected_IC_params=HtoIL_collect_params(hBlock,{'phase_angle','act_init_disp'});


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Isothermal Liquid/Pumps & Motors/Auxiliary Components/Swash Plate')


    HtoIL_apply_params(hBlock,param_list(:,2),collected_params);



    collected_IC_vars=HtoIL_parameters_to_variables(collected_IC_params);
    var_IC_list={'rotor_angle','actuator_displacement'};
    HtoIL_apply_vars(hBlock,var_IC_list,collected_IC_vars);


    out=struct;
end



