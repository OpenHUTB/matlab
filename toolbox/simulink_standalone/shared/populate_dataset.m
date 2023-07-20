









function datasetToFill=populate_dataset(datasetToFill,structToFillFrom,modelName)
    if(isempty(datasetToFill)||isempty(structToFillFrom))










        datasetToFill=[];
        return;
    end
    numOfElements=datasetToFill.numElements;
    blockPathStructInfoMap=containers.Map;
    blockPathStructInfoMap=fill_blockpath_structure_info_map(blockPathStructInfoMap,structToFillFrom);
    dsIdx=1;
    while dsIdx<=numOfElements
        blockPath=get_blockId_from_dataset(datasetToFill,dsIdx);
        if~blockPathStructInfoMap.isKey(blockPath)







            error(message('SimulinkExecution:InitialState:InternalErrorSaveFinalStateDataset',modelName));
        end
        stateIdxValuesMap=blockPathStructInfoMap(blockPath);


        values=stateIdxValuesMap.values;
        valuesIter=1;




        [datasetToFill{dsIdx}.Values,valuesIter]=fill_leaf_elements(datasetToFill{dsIdx}.Values,...
        valuesIter,...
        values,...
        structToFillFrom.time);
        dsIdx=dsIdx+1;
    end
end









function[blockpathStructInfoMap]=fill_blockpath_structure_info_map(blockpathStructInfoMap,structToParse)
    numStructElements=numel(structToParse.signals);
    for loopIdx=1:numStructElements
        blockPath=structToParse.signals(loopIdx).blockName;
        actualBlockPath=trim_blockpath(blockPath,structToParse.signals(loopIdx).inReferencedModel);
        indexValuesMap=containers.Map('KeyType','int32','ValueType','any');




        actualBlockPath=strcat(actualBlockPath,...
        structToParse.signals(loopIdx).stateName);
        stateIdx=structToParse.signals(loopIdx).stateIdxList;
        value=structToParse.signals(loopIdx).values;
        if isKey(blockpathStructInfoMap,actualBlockPath)
            indexValuesMap=blockpathStructInfoMap(actualBlockPath);

            if structToParse.signals(loopIdx).inReferencedModel
                keysInIndexValuesMap=indexValuesMap.keys;
                nElements=numel(keysInIndexValuesMap);
                stateIdx=cell2mat(keysInIndexValuesMap(nElements))+1;
            end
        else
            if structToParse.signals(loopIdx).inReferencedModel
                stateIdx=0;
            end
        end
        indexValuesMap(stateIdx)=value;
        blockpathStructInfoMap(actualBlockPath)=indexValuesMap;
    end
end


function actualBlockPath=remove_escape_characters(blockPath)



    actualBlockPath=blockPath;
    if~contains(blockPath,"~")
        return;
    end
    numCharsInBlockPath=length(blockPath);
    tempStringIndex=1;
    tempString="";
    while(tempStringIndex<=numCharsInBlockPath)



        if(isequal(blockPath(tempStringIndex),'~'))&&...
            (tempStringIndex<numCharsInBlockPath)
            if isequal(blockPath(tempStringIndex+1),'~')||...
                isequal(blockPath(tempStringIndex+1),'|')


                tempStringIndex=tempStringIndex+1;
            end
        end
        tempString=plus(tempString,blockPath(tempStringIndex));
        tempStringIndex=tempStringIndex+1;
    end
    actualBlockPath=tempString;
end


function blockPath=get_blockId_from_dataset(dataset,index)
    blockPath="";
    numModels=dataset{index}.BlockPath.getLength();
    blockPath=strcat(blockPath,dataset{index}.BlockPath.getBlock(1));
    for modelIndex=2:numModels
        blockPath=strcat(blockPath,"|",dataset{index}.BlockPath.getBlock(modelIndex));
    end
    blockPath=strcat(blockPath,dataset{index}.Name);
end




















function[element,valuesIter]=fill_leaf_elements(element,valuesIter,values,time)
    if isstruct(element)
        fields=fieldnames(element);
        for idx=1:length(fields)
            [element.(char(fields(idx))),valuesIter]=fill_leaf_elements(element.(char(fields(idx))),valuesIter,values,time);
        end
    elseif isequal(class(element),'timeseries')
        element.Time=time;
        element.Data=cell2mat(values(valuesIter));
        valuesIter=valuesIter+1;
    end
end







function blockPath=trim_blockpath(blockPath,isReferencedModel)

    blockPath=regexprep(blockPath,'[\n\r]+',' ');

    blockPath=strtrim(blockPath);
    if isReferencedModel


        blockPath=remove_escape_characters(blockPath);
    end
end


