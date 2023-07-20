function UD=dataSet_store(UD)






    dsIdx=UD.current.dataSetIdx;

    if isfield(UD,'sbobj')
        sigCnt=UD.sbobj.Groups(dsIdx).NumSignals;

        if length(UD.channels)>sigCnt

            numSignals=length(UD.channels)-sigCnt;
            UD.sbobj.Groups(dsIdx).Signals(end+1:numSignals)=SigSuiteSignals(numSignals);
        end

    end

    UD.dataSet(dsIdx).timeRange=[UD.common.minTime,UD.common.maxTime];
    UD.dataSet(dsIdx).displayRange=UD.common.dispTime;
    if(isfield(UD,'axes')&&~isempty(UD.axes))
        UD.dataSet(dsIdx).activeDispIdx=fliplr(unique([UD.axes.channels]));
    else
        UD.dataSet(dsIdx).activeDispIdx=[];
    end
