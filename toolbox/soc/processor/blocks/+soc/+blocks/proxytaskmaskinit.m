function proxytaskmaskinit(blk)




    taskType=get_param(blk,'TaskType');
    isExposeFcnCallPort=isequal(taskType,'Event-driven');

    tp=find_system(blk,'LookUnderMasks','all','FollowLinks','on',...
    'SearchDepth',1,'BlockType','TriggerPort');
    if isExposeFcnCallPort&&isempty(tp)
        add_block('simulink/Ports & Subsystems/Trigger',[blk,'/function'],...
        'TriggerType','function-call');
    elseif~isExposeFcnCallPort&&~isempty(tp)
        delete_block([blk,'/function']);
    end
    if isExposeFcnCallPort
        set_param([blk,'/Constant'],'SampleTime','-1');
    elseif~isExposeFcnCallPort&&~isempty(tp)
        set_param([blk,'/Constant'],'SampleTime',get_param(blk,'SampleTime'));
    end
    soc.internal.setBlockIcon(blk,'socicons.ProxyTask');
end

