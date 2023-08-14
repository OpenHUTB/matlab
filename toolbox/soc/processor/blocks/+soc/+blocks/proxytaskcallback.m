function proxytaskcallback(blk,action)%#ok<INUSD>




    taskType=get_param(blk,'TaskType');
    isExposeFcnCallPort=isequal(taskType,'Event-driven');
    if isExposeFcnCallPort
        set_param(blk,'MaskVisibilityString','on,off');
        set_param([blk,'/Constant'],'SampleTime','-1');
        set_param([blk,'/CPU Load Generator'],'SampleRate','-1');
    elseif~isExposeFcnCallPort
        set_param(blk,'MaskVisibilityString','on,on');
        stStr=get_param(blk,'SampleTime');
        set_param([blk,'/Constant'],'SampleTime',stStr);
        set_param([blk,'/CPU Load Generator'],'SampleRate',stStr);
    end
