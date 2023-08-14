function selectedSignals=populateCurrentSelectedSignals(modelName,widgetID,isLibWidget)







    bIsCoreBlock=~ischar(widgetID);
    selLines=gsl(gcs,1);
    selBlocks=gsb(gcs,1);
    signalLineList=unique([selLines;utils.getSignalsForSelectedBlocks(selBlocks)']);
    signalNames={};
    signalPortNums={};
    signalBlockPaths={};
    combinedSignalNames={};
    DefaultColorAndStyle={};
    LineStyles={};
    LineColorTuples={};
    defaultColor=utils.getNextScopeDefaultColor(modelName,widgetID,isLibWidget);
    for idx=1:length(signalLineList)
        signalLine=signalLineList(idx);
        try
            signalPort=get_param(signalLine,'SrcPortHandle');
            if(isequal(-1,signalPort)||...
                ~strcmpi(get(signalPort,'PortType'),'outport'))
                continue;
            end
            signalName=get_param(signalPort,'Name');
            signalBlockPath=get_param(signalPort,'Parent');
            signalPortNum=get_param(signalPort,'PortNumber');

            signalNames{end+1}=signalName;%#ok<AGROW>
            signalPortNums{end+1}=signalPortNum;%#ok<AGROW>
            signalBlockPaths{end+1}=signalBlockPath;%#ok<AGROW>

            combinedSignalNames{end+1}=...
            [signalBlockPath,':',num2str(signalPortNum),':',signalName];%#ok<AGROW>

            signalInfo.mdl=modelName;
            signalInfo.portH=signalPort;
            [client,~,wasAdded]=Simulink.sdi.internal.Utils.getWebClient(signalInfo);
            if~wasAdded
                DefaultColorAndStyle{end+1}=isempty(client.ObserverParams.LineSettings.Color);%#ok
                LineStyles{end+1}=client.ObserverParams.LineSettings.LineStyle;%#ok
                LineColorTuples{end+1}=...
                locGetColorTuple(bIsCoreBlock,client.ObserverParams.LineSettings.Color);%#ok
            else
                DefaultColorAndStyle{end+1}=locSignalIsBadged(signalInfo);%#ok
                LineStyles{end+1}='-';%#ok
                LineColorTuples{end+1}=locGetColorTuple(bIsCoreBlock,defaultColor);%#ok
            end

        catch me %#ok<NASGU>
        end
    end
    if~isempty(combinedSignalNames)
        [combinedSignalNames,uniqueIndices]=unique(combinedSignalNames);
        signalNames=signalNames(uniqueIndices);
        signalPortNums=signalPortNums(uniqueIndices);
        signalBlockPaths=signalBlockPaths(uniqueIndices);
        LineStyles=LineStyles(uniqueIndices);
        LineColorTuples=LineColorTuples(uniqueIndices);
        DefaultColorAndStyle=DefaultColorAndStyle(uniqueIndices);
    end
    selectedSignals=struct('BlockPath',cell(size(combinedSignalNames)),...
    'OutputPortIndex',cell(size(combinedSignalNames)),...
    'SignalName',cell(size(combinedSignalNames)),...
    'DefaultColorAndStyle',cell(size(combinedSignalNames)),...
    'LineStyle',cell(size(LineStyles)),...
    'LineColorTuple',cell(size(LineColorTuples)));
    for idx=1:length(signalNames)
        if bIsCoreBlock
            sigInfo.BlockPath=signalBlockPaths{idx};
        else
            sigInfo.BlockPath=locRemoveModelNameFromBlockPath(modelName,signalBlockPaths{idx});
        end
        sigInfo.OutputPortIndex=signalPortNums{idx};
        sigInfo.SignalName=signalNames{idx};
        sigInfo.DefaultColorAndStyle=DefaultColorAndStyle{idx};
        sigInfo.LineStyle=LineStyles{idx};
        sigInfo.LineColorTuple=LineColorTuples{idx};
        selectedSignals(idx)=sigInfo;
    end
end


function colorTuple=locGetColorTuple(bIsCoreBlock,color)
    tmpColor=int32(color*255);
    if bIsCoreBlock
        colorTuple=tmpColor;
    else
        colorTuple=num2str(tmpColor);
    end
end


function blockPath=locRemoveModelNameFromBlockPath(model,fullBlockPath)
    blockPath=fullBlockPath;
    if contains(fullBlockPath,model)
        blockPath=fullBlockPath(length(model)+2:end);
    end
end

function ret=locSignalIsBadged(sigInfo)
    ret=Simulink.sdi.internal.SignalObserverMenu.hasVisuOnPort(sigInfo.portH,sigInfo.mdl);
end
