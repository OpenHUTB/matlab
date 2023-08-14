function info=getProxyTaskInfo(modelName)




    import soc.internal.*

    info.hasProxyTask=false;
    info.numTimerDriven=0;
    info.numEventDriven=0;
    info.numEventDrivenPeriodic=0;
    info.numEventDrivenAperiodic=0;
    info.hasTimerDrivenInBaseRate=false;
    info.hasTimerDrivenInSubRate=false;
    info.hasEventDrivenSrcInBaseRate=false;
    info.hasEventDrivenSrcInSubRate=false;

    data=soc.blocks.proxyTaskData('get',modelName);
    if isempty(data),return;end

    sampleTimes=get_param(modelName,'SampleTimes');

    proxyTaskData=data.proxyTask;
    idx=arrayfun(@(x)(isequal(x.MaskType,'ProxyTask')),proxyTaskData);
    pAll=proxyTaskData(idx);
    idx=arrayfun(@(x)(isequal(x.TaskType,'Event-driven')),pAll);
    pEventDriven=pAll(idx);
    idx=arrayfun(@(x)(isequal(x.TaskType,'Timer-driven')),pAll);
    pTimerDriven=pAll(idx);

    info.numTimerDriven=numel(pTimerDriven);
    info.numEventDriven=numel(pEventDriven);

    [numPeriodic,numAperiodic]=locGetNumEventDriven(modelName);
    isBaseRateTrigSrc=isRateTriggerForEventDrivenProxyTask(modelName,0);
    info.hasProxyTask=true;

    info.numEventDrivenPeriodic=numPeriodic;
    info.numEventDrivenAperiodic=numAperiodic;
    info.hasEventDrivenSrcInBaseRate=logical(isBaseRateTrigSrc);
    info.hasEventDrivenSrcInSubRate=logical(numPeriodic-isBaseRateTrigSrc);
    info.hasTimerDrivenInBaseRate=locIsProxyTaskBlockInBaseRate(sampleTimes,modelName);
    info.hasTimerDrivenInSubRate=locIsProxyTaskBlockInSubRate(sampleTimes,modelName);
end


function[numPeriodic,numAperiodic]=locGetNumEventDriven(modelName)
    import soc.internal.connectivity.*
    numPeriodic=0;
    numAperiodic=0;
    theMap=getTaskManagerEventSources(modelName);
    if isempty(theMap)
        return
    end
    keys=theMap.keys;
    for i=1:numel(keys)
        thisEventSrc=theMap(keys{i});
        if thisEventSrc.IsFromInputPort
            error(...
            message('soc:scheduler:ProxyTaskDrivenByIODataSrcFromInputPort',...
            keys{i},thisEventSrc.SrcBlkName));
        end
        numPeriodic=numPeriodic+thisEventSrc.IsFromDialog;
    end
    numAperiodic=numel(keys)-numPeriodic;
end


function ret=locIsProxyTaskBlockInBaseRate(sampleTimes,modelName)
    ret=false;
    idxDiscSampleTimes=contains(arrayfun(@(x)(x.Description),sampleTimes,...
    'UniformOutput',false),'Discrete');
    if any(idxDiscSampleTimes)
        data=soc.blocks.proxyTaskData('get',modelName);
        discSampleTimes=sampleTimes(idxDiscSampleTimes);
        baseRate=discSampleTimes(1).Value(1);
        for i=1:numel(data.proxyTask)
            thisProxyTask=data.proxyTask(i);
            if isequal(thisProxyTask.SampleTime,baseRate)
                ret=true;
                return
            end
        end
    end
end


function ret=locIsProxyTaskBlockInSubRate(sampleTimes,modelName)
    ret=false;
    idxDiscSampleTimes=contains(arrayfun(@(x)(x.Description),sampleTimes,...
    'UniformOutput',false),'Discrete');
    if any(idxDiscSampleTimes)&&(numel(sampleTimes(idxDiscSampleTimes))>1)
        data=soc.blocks.proxyTaskData('get',modelName);
        discSampleTimes=sampleTimes(idxDiscSampleTimes);
        for i=1:numel(data.proxyTask)
            thisProxyTask=data.proxyTask(i);
            for j=2:numel(discSampleTimes)
                subRate=discSampleTimes(j).Value(1);
                if isequal(thisProxyTask.SampleTime,subRate)
                    ret=true;
                    return
                end
            end
        end
    end
end
