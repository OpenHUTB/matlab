function out=update_elm_2_pos(hBlock)






    init_position=HtoIL_collect_params(hBlock,{'init_position'});











    act_orientation=get_param(hBlock,'act_orientation');


    HtoIL_set_block_files(hBlock,'SimscapeFluids_lib/Valve Actuators/Multiposition Valve Actuator')


    HtoIL_apply_params(hBlock,{'init_position_2'},init_position);


    if strcmp(act_orientation,'1')
        set_param(hBlock,'act_orientation','1');
    else
        set_param(hBlock,'act_orientation','-1');
    end


    if strcmp(init_position.base,'1')
        out.warnings.messages={['Updated actuator response when Initial position is Extended. '...
        ,'Adjustment of Initial valve control input signal may be required if the signal is less than 50% of the Nominal signal value.']};
        out.warnings.subsystem=getfullname(hBlock);
    else
        out=struct;
    end

end



