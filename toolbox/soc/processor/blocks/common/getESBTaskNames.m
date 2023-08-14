function[rWiredTaskNames,taskNames]=getESBTaskNames(hBlk)





    rWiredTaskNames=[];
    taskMgr=locGetTaskManagerBlockName(hBlk);


    tskBlks=find_system(taskMgr,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'MaskType','ESB Task');
    shrtNames=cell(1,length(tskBlks));
    taskNames=cell(1,length(tskBlks));
    for k=1:length(tskBlks)
        shrtNames{k}=get_param(tskBlks{k},'taskName');
        taskNames{k}=[shrtNames{k},'_trigger'];
    end
    taskNames=locSortTasks(taskNames,shrtNames);
end


function taskNames=locSortTasks(taskNames,shrtNames)

    [~,idx]=sort(shrtNames);
    taskNames=taskNames(idx);
end


function taskMgr=locGetTaskManagerBlockName(thisBlk)
    taskMgr=[];
    while(~isempty(thisBlk))
        if isequal(get_param(thisBlk,'MaskType'),'Task Manager')
            taskMgr=thisBlk;
            break;
        end
        thisBlk=get_param(thisBlk,'Parent');
    end
    assert(~isempty(taskMgr),'Task Manager block not found.');
end
