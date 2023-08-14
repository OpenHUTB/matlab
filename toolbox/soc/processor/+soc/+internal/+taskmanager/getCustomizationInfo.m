function info=getCustomizationInfo(tskMgrBlk)




    info=eval(get_param(tskMgrBlk,'CustomizationInfo'));
    if isempty(info)

        info.scheduleeditorsupported=true;
        info.maxnumtasks=99;
        info.tasktypessupported={'Event-driven','Timer-driven'};
        info.coreassignmentsupported=true;
        info.taskdropsupported=true;
        info.taskprioritiessupported=[1,99];
        info.taskpreemptionsupported=true;
        info.playbacksupported=true;
        info.taskdurationsourcesupported={'Dialog','Input port','Recorded task execution statistics'};
    end
end