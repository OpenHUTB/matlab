function setClockSampleTime(sysBlock)




    rootModel=bdroot(sysBlock);
    if contains(rootModel,'studio5000_plclib')
        return
    end


    if~strcmpi(slplc.utils.getModelGenerationStatus(sysBlock),...
        'none')
        return
    end

    TONBlks=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','TON');
    TOFBlks=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','TOF');
    RTOBlks=plc_find_system(sysBlock,'LookUnderMasks','all','FollowLinks','on','PLCBlockType','RTO');
    timerBlks=[TONBlks;TOFBlks;RTOBlks];
    if isempty(timerBlks),return,end

    timerClockSampleTime=getTimerSampleTime(sysBlock,rootModel);

    for blkCount=1:numel(timerBlks)
        timerBlk=timerBlks{blkCount};
        set_param(timerBlk,'PLCTimerSampleTime',timerClockSampleTime);
    end
end

function timerClockSampleTime=getTimerSampleTime(sysBlock,rootModel)
    timerClockSampleTime=get_param(sysBlock,'SystemSampleTime');
    if strcmpi(timerClockSampleTime,'-1')
        mdlSolverType=get_param(rootModel,'SolverType');
        if strcmpi(mdlSolverType,'Fixed-step')
            mdlBaseStep=get_param(rootModel,'FixedStep');
            if~strcmpi(mdlBaseStep,'auto')
                timerClockSampleTime=mdlBaseStep;
            else

                simStopTime=str2double(get_param(rootModel,'StopTime'));
                if isinf(simStopTime)

                    timerClockSampleTime='0.2';
                else
                    simStartTime=str2double(get_param(rootModel,'StartTime'));
                    timerClockSampleTime=num2str((simStopTime-simStartTime)/50);
                end
            end
        else
            timerClockSampleTime='0.001';
            warning('slplc:wrongSampleTime',...
            ['Set the timer clock sample time to default 0.001 sec. '...
            ,'Please set model solver to Fixed-step and specify a model sample time, '...
            ,'or specify a sample time for the top POU block %s to override the default sample time'],...
            sysBlock);
        end
    end
end
