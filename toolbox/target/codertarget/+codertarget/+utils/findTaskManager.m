function tskMgrBlk=findTaskManager(modelName)




    if Simulink.internal.useFindSystemVariantsMatchFilter()
        tskMgrBlk=find_system(modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'FollowLinks','on','MaskType','Task Manager');
    else
        tskMgrBlk=find_system(modelName,'LookUnderMasks','all',...
        'FollowLinks','on','MaskType','Task Manager');
    end
end
