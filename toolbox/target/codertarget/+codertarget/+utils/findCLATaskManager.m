function CLAtskMgrBlk=findCLATaskManager(modelName)





    tskMgrBlk={};%#ok<NASGU> % store all task manager blocks in the model
    CLAtskMgrBlk='';
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        tskMgrBlk=find_system(modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'FollowLinks','on','MaskType','Task Manager');
    else
        tskMgrBlk=find_system(modelName,'LookUnderMasks','all',...
        'FollowLinks','on','MaskType','Task Manager');
    end
    for i=1:numel(tskMgrBlk)
        if contains(get_param(tskMgrBlk{i},'ReferenceBlock'),'c2000')
            CLAtskMgrBlk=tskMgrBlk{i};
            break;
        end
    end
end