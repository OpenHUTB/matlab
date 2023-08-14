function logBenchData(data)




    try
        if isempty(data)
            return;
        end


        loopSize=min(size(data,1),10);
        localTimestamp=datestr(datetime('now','TimeZone','local'),'mmmm dd, yyyy HH:MM:SS.FFF');

        for i=1:loopSize
            logRowData(data(i,:),loopSize,localTimestamp);
        end
    catch ME

    end
end

function logRowData(rowData,inputParam,timestamp)

    if isequal(size(rowData),[1,6])&&isa(rowData,'double')
        dataId=matlab.ddux.internal.DataIdentification("ML","ML_PERFORMANCE","ML_PERFORMANCE_BENCH");
        matlab.ddux.internal.logData(dataId,...
        "lu",rowData(1),...
        "fft",rowData(2),...
        "ode",rowData(3),...
        "sparse",rowData(4),...
        "plot2D",rowData(5),...
        "plot3D",rowData(6),...
        "inputParam",int32(inputParam),...
        "timestampAtRun",timestamp);
    end
end
