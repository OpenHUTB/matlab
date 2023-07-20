function callbackPWMInitialDelay(blk,InitialDelay)
    x=find_system(blk,'LookUnderMasks','all','FollowLinks','on','BlockType','PropagationDelay');

    if(InitialDelay<=eps)
        if(~isempty(x))
            delete_line(blk,'Variable Pulse Generator/1','Propagation Delay/1');
            delete_line(blk,'delay/1','Propagation Delay/2');
            delete_line(blk,'Propagation Delay/1','pwm/1');
            delete_block([blk,'/Propagation Delay']);
            delete_block([blk,'/delay']);
            add_line(blk,'Variable Pulse Generator/1','pwm/1','autorouting','on');
        end
    else
        if(isempty(x))
            posPropDelay=[350,102,380,133];
            posDelayValue=[255,190,285,220];
            delete_line(blk,'Variable Pulse Generator/1','pwm/1');
            add_block('simulink/Discrete/Propagation Delay',[blk,'/Propagation Delay'],'Position',posPropDelay);
            add_block('simulink/Sources/Constant',[blk,'/delay'],'Position',posDelayValue);
            add_line(blk,'Variable Pulse Generator/1','Propagation Delay/1','autorouting','on');
            add_line(blk,'delay/1','Propagation Delay/2','autorouting','on');
            add_line(blk,'Propagation Delay/1','pwm/1','autorouting','on');
        end
        set_param([blk,'/delay'],'Value',get_param(blk,'InitialDelay'));
        set_param([blk,'/Propagation Delay'],'RunAtFixedTimeIntervals',get_param(blk,'RunAtFixedTimeIntervals'));
        set_param([blk,'/Propagation Delay'],'SampleTime',get_param(blk,'SampleTime'));

    end
end
