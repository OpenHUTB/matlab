


function[dataVals,timeVals]=createFailureRegionSignalValues(data,time)

    data=data(:).';
    pad=[slTestResult.Pass,data,slTestResult.Pass];
    timeIdxs=find(diff(pad==slTestResult.Fail));


    timeIdxs(2:2:end)=timeIdxs(2:2:end)-1;
    if iscolumn(time)
        timeIdxs=timeIdxs';
    end
    timeVals=time(timeIdxs);
    dataVals=ones(size(timeIdxs));
end