function checkTimes(labelData,dataSource)




    dsTimes=dataSource.TimeStamps;
    ldTimes=labelData.Time;


    if~isequal(size(dsTimes),size(ldTimes))
        error(message('vision:groundTruth:inconsistentTimeStamps'))
    end


    maxAbsDiff=max(abs(seconds(dsTimes)-seconds(ldTimes)));
    tol=1e-6;
    if maxAbsDiff>tol
        error(message('vision:groundTruth:inconsistentTimeStamps'))
    end
end