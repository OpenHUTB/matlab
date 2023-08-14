







function dataExtractors=getSimulationOutputExtractors(simOutStruct)
    validateattributes(simOutStruct,{'struct'},{'scalar'});

    dataExtractors=[];
    outputIdentifiers=fieldnames(simOutStruct);

    for dataIndex=1:numel(outputIdentifiers)
        curOut=simOutStruct.(outputIdentifiers{dataIndex});
        if isa(curOut,"Simulink.SimulationData.Dataset")
            signalDataExtractors=createDatasetExtractors(curOut,outputIdentifiers{dataIndex});
        elseif isnumeric(curOut)
            signalDataExtractors=createNumArrayExtractors(curOut,outputIdentifiers{dataIndex});
        elseif isstruct(curOut)&&isSupportedLoggingStruct(curOut)
            signalDataExtractors=createStructExtractors(curOut,outputIdentifiers{dataIndex});
        else
            signalDataExtractors=[];
        end

        if~isempty(signalDataExtractors)
            dataExtractors=[dataExtractors,signalDataExtractors];
        end
    end
end

function validity=isSupportedLoggingStruct(curOut)
    validity=isfield(curOut,'signals')&&...
    ~isempty(curOut.signals)&&...
    allSignalsHaveUnidimensionalValues(curOut.signals);
end

function passingCriteria=allSignalsHaveUnidimensionalValues(signals)
    signalsHaveUnidimensionalValues=arrayfun(@(signal)signalHasUnidimensionalValues(signal),signals);
    passingCriteria=all(signalsHaveUnidimensionalValues);
end

function passingCriteria=signalHasUnidimensionalValues(signal)
    passingCriteria=isfield(signal,'values')&&...
    isfield(signal,'dimensions')&&...
    all(signal.dimensions==1);
end

function dataExtractors=createDatasetExtractors(dataSet,outputIdentifier)
    dataExtractors=[];
    elementNames=dataSet.getElementNames;
    [~,~,nameIndices]=unique(elementNames);
    for elIndex=1:numel(elementNames)
        curData=dataSet{elIndex};
        repeatIndex=getRepeatIndex(elIndex,nameIndices);

        if isstruct(curData.Values)
            elementExtractors=createDatasetStructValueExtractors(...
            curData.Values,outputIdentifier,elIndex,curData.Name,repeatIndex);
        else
            elementExtractors=MultiSim.internal.DatasetExtractor(outputIdentifier,elIndex,curData.Name,repeatIndex);
        end
        dataExtractors=[dataExtractors,elementExtractors];
    end
end

function idx=getRepeatIndex(elIndex,nameIndices)
    nameIndex=nameIndices(elIndex);
    sameNameIndices=(nameIndices==nameIndex);
    if sum(sameNameIndices)==1
        idx=0;
    else
        idx=sum(sameNameIndices(1:elIndex));
    end
end

function dataExtractors=createDatasetStructValueExtractors(structData,outputIdentifier,curField,elIndex,repeatIndex)
    dataExtractors=[];
    fields=fieldnames(structData);
    for fieldIndex=1:numel(fields)




        if isscalar(structData)&&isa(structData.(fields{fieldIndex}),'timeseries')
            elementExtractor=MultiSim.internal.DatasetStructValueExtractor(outputIdentifier,curField,elIndex,repeatIndex,fields{fieldIndex});
            dataExtractors=[dataExtractors,elementExtractor];
        end
    end
end

function arrayExtractors=createNumArrayExtractors(curOut,outputIdentifier)
    arrayExtractors=[];
    numColumns=size(curOut,2);
    for dataIndex=1:numColumns
        extractor=MultiSim.internal.ArrayExtractor(outputIdentifier,dataIndex,numColumns);
        arrayExtractors=[arrayExtractors,extractor];
    end
end

function structExtractors=createStructExtractors(curOut,outputIdentifier)
    structExtractors=[];
    for structIndex=1:numel(curOut.signals)
        curData=curOut.signals(structIndex).label;
        extractor=MultiSim.internal.StructExtractor(outputIdentifier,curData,structIndex);
        structExtractors=[structExtractors,extractor];
    end
end