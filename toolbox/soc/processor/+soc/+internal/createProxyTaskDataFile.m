function createProxyTaskDataFile(modelName,fName)




    import soc.internal.*
    tmBlock=soc.internal.connectivity.getTaskManagerBlock(modelName);
    rawTaskData=get_param(tmBlock,'allTaskData');
    allTaskData=soc.internal.TaskManagerData(rawTaskData,'evaluate',modelName);
    allTaskNames=allTaskData.getTaskNames;
    [~,sampleTimes,~]=getDiscreteRatesInfoFromModel(modelName);
    allTasks=allTaskData.getTask(allTaskNames);
    timerTaskIdx=arrayfun(@(x)contains(x.taskType,'Timer-driven'),allTasks);
    eventTaskIdx=arrayfun(@(x)contains(x.taskType,'Event-driven'),allTasks);
    timerTasks=allTasks(timerTaskIdx);
    eventTasks=allTasks(eventTaskIdx);
    timerTaskPeriods=arrayfun(@(x)x.taskPeriod,timerTasks);
    eventTaskDurSrc=arrayfun(@(x)x.taskDurationSource,eventTasks,'UniformOutput',false);
    numRates=numel(sampleTimes);
    proxyTaskInfo=soc.internal.getProxyTaskInfo(modelName);

    fid=fopen([fName,'.c'],'w');
    fprintf(fid,'#include "mw_cpuloadgenerator.h"\n');
    fprintf(fid,'durationStructType durationStruct_P[] = {\n');
    nTotalLines=numRates+proxyTaskInfo.numEventDriven;
    for i=1:numRates
        thisSampleTime=sampleTimes(i);
        if(i<nTotalLines),sep=',';else,sep='';end
        [isTskMgrTsk,idx]=ismember(thisSampleTime,timerTaskPeriods);
        if locIsProxyTask(modelName,isTskMgrTsk,allTaskData,thisSampleTime)
            locPrintTaskData(fid,allTaskData,allTaskNames,idx,sep);
        else
            locPrintDefaultTaskData(fid,sep)
        end
    end
    eventProxyTasks=getEventDrivenProxyTaskNames(modelName);
    for i=1:proxyTaskInfo.numEventDriven
        if(i<proxyTaskInfo.numEventDriven),sep=',';else,sep='';end
        [~,idx]=ismember(eventProxyTasks{i},eventProxyTasks);
        if isequal(eventTaskDurSrc{idx},'Dialog')
            [~,idx]=ismember(eventProxyTasks{i},allTaskNames);
            locPrintTaskData(fid,allTaskData,allTaskNames,idx,sep);
        else
            locPrintDefaultTaskData(fid,sep)
        end
    end
    fprintf(fid,'};\n');
    fclose(fid);
end


function thisTask=locGetTaskData(allTaskData,thisSampleTime)
    allTaskNames=allTaskData.getTaskNames;
    allTasks=allTaskData.getTask(allTaskNames);
    for i=1:numel(allTasks)
        thisTask=allTasks(i);
        if isequal(thisTask.taskType,'Timer-driven')&&...
            isequal(thisTask.taskPeriod,thisSampleTime)
            return
        end
    end
end


function locPrintDefaultTaskData(fid,sep)
    defaultStr=...
    '{0, {100,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}}';
    fprintf(fid,'%s%s\n',defaultStr,sep);
end


function locPrintTaskData(fid,taskData,allTaskNames,taskIdx,taskSep)
    import soc.internal.dialog.*
    MAXNUMDISTR=5;
    task=taskData.getTask(allTaskNames{taskIdx});
    perStr='';
    meaStr='';
    minStr='';
    maxStr='';
    devStr='';
    durData=task.taskDurationData;
    numDistr=numel(durData);
    for i=1:numDistr
        if(i<MAXNUMDISTR),sep=',';else,sep='';end
        perStr=[perStr,num2str(task.taskDurationData(i).percent),sep];%#ok<*AGROW>
        meaStr=[meaStr,num2str(task.taskDurationData(i).mean),sep];
        minStr=[minStr,num2str(task.taskDurationData(i).min),sep];
        maxStr=[maxStr,num2str(task.taskDurationData(i).max),sep];
        devStr=[devStr,num2str(task.taskDurationData(i).dev),sep];
    end
    for i=numDistr+1:MAXNUMDISTR
        if(i<MAXNUMDISTR),sep=',';else,sep='';end
        perStr=[perStr,'0',sep];
        meaStr=[meaStr,'0',sep];
        minStr=[minStr,'0',sep];
        maxStr=[maxStr,'0',sep];
        devStr=[devStr,'0',sep];
    end
    fprintf(fid,'{%d, {%s}, {%s}, {%s}, {%s}, {%s}}%s\n',...
    1,perStr,meaStr,minStr,maxStr,devStr,taskSep);
end


function ret=locIsProxyTask(modelName,isTskMgrTsk,allTaskData,thisSampleTime)
    ret=false;
    if~isTskMgrTsk,return;end
    task=locGetTaskData(allTaskData,thisSampleTime);
    data=soc.blocks.proxyTaskData('get',modelName);
    for i=1:numel(data.proxyTask)
        if isequal(task.taskType,'Timer-driven')&&...
            isequal(task.taskPeriod,data.proxyTask(i).SampleTime)
            ret=true;
            return
        end
    end
end