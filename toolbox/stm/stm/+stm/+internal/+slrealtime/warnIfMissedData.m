function missingData=warnIfMissedData(timePoints,expectedSampleTime)




    timeTolerance=1.9;
    missingData=false;

    if isempty(timePoints)||(~all(diff(timePoints)<expectedSampleTime*timeTolerance))

        warning(message('stm:realtime:IncompleteLogData'));
        missingData=true;
    end
end

