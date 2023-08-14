function[ati,traceStruct]=removeDuplicateTestTraces(ati,traceStruct)




    try
        if isempty(ati)
            return;
        end

        numAllRuns=numel(ati);
        [~,idx]=unique({ati.uniqueId},'stable');
        ati=ati(idx);

        traceStruct=fixTrace(traceStruct,idx,numAllRuns);

    catch MEx
        rethrow(MEx);
    end
end

function traceStruct=fixTrace(traceStruct,uniqueIdx,numAllRuns)


    if isempty(traceStruct)
        return
    end

    metricList=fields(traceStruct);
    for m=1:numel(metricList)
        curMetric=metricList{m};
        if strcmp(curMetric,'testobjectives')

            traceStructTO=fixTrace(traceStruct.testobjectives,uniqueIdx,numAllRuns);
            traceStruct.testobjectives=traceStructTO;
        else
            curTrace=traceStruct.(curMetric);
            if~isempty(curTrace)
                assert(numAllRuns==size(curTrace,2));
                traceStruct.(curMetric)=curTrace(:,uniqueIdx);
            end
        end
    end
end


