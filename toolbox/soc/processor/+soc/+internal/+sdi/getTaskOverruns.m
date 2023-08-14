function[taskOverruns,numExpected]=getTaskOverruns(task,taskPeriod,taskDropTimes,stopTime)







    taskOverruns=[];
    taskEnds=soc.internal.sdi.getTaskEndTimes(task);
    numExpected=floor(stopTime/taskPeriod);
    dropIdx=1;
    for i=1:numExpected
        expTrigTime=(i-1)*taskPeriod;
        if~isempty(taskDropTimes)&&...
            dropIdx<=numel(taskDropTimes)&&...
            isequal(expTrigTime,taskDropTimes(dropIdx))
            dropIdx=dropIdx+1;
            continue
        end
        expTaskEndTime=i*taskPeriod;
        jj=i-dropIdx+1;
        if(expTaskEndTime<=stopTime)&&...
            ((jj>numel(taskEnds))||(taskEnds(jj)>=expTaskEndTime))
            taskOverruns(end+1)=expTaskEndTime;%#ok<AGROW>
        end
    end
end
