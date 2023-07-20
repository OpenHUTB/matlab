function activeCoreSet=getActiveCoresFromTaskManager(modelName)




    activeCoreSet=[];
    try
        tm=soc.internal.connectivity.getTaskManagerBlock(modelName,'all');
        if~isempty(tm)
            if~iscell(tm),tm={tm};end
            for procIdx=1:numel(tm)
                rawTaskData=get_param(tm{procIdx},'allTaskData');
                allTaskData=soc.internal.TaskManagerData(rawTaskData,'evaluate',modelName);
                myTaskNames=allTaskData.getTaskNames;
                taskData=allTaskData.getTask(myTaskNames);
                activeCoreSet=[activeCoreSet,arrayfun(@(x)(x.coreNum),taskData')];%#ok
            end
            activeCoreSet=sort(unique(activeCoreSet,'stable'));
        else
            activeCoreSet=0;
        end
    catch
        activeCoreSet=0;
    end

