

function tMax=getMaxTimeFromSignalBuilder(blockName,groupName)

    tMax=[];
    [time,data,sigNames]=signalbuilder(blockName);%#ok
    numberOfSignals=length(sigNames);

    for sigId=1:numberOfSignals
        [time,data]=signalbuilder(blockName,'get',sigNames{sigId},groupName);%#ok
        currTMax=max(time);
        if isempty(tMax)
            tMax=currTMax;
        else
            tMax=max(tMax,currTMax);
        end
    end







