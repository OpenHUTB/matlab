function connectedRows=getConnectedRowsForViewers(signalHandles,activeAxes)








    if(length(signalHandles{activeAxes})==1&&signalHandles{activeAxes}.Handle==-1)
        connectedRows=[];
        return;
    end


    activeSignals=signalHandles{activeAxes};


    outportHandles=[activeSignals.Handle];


    outportHandles(outportHandles==-1)=[];


    validHandles=arrayfun(@(x)ishandle(x),outportHandles);
    outportHandles=outportHandles(validHandles);


    outportRelativePaths={activeSignals.RelativePath};


    [modelRefBlockIndex,SFBlockIndex]=slsignalselector.utils.SignalSelectorUtilities....
    hasSelectionModelRefOrSF(outportHandles);


    numRowsModelRef=0;
    outportHandlesWithoutModelRef=[];
    if~isempty(modelRefBlockIndex)
        modelRefHandles=outportHandles(modelRefBlockIndex);
        outportModelRefRelativePaths=outportRelativePaths(modelRefBlockIndex);
        numRowsModelRef=numel(outportModelRefRelativePaths);
        outportHandlesWithoutModelRef=outportHandles(~modelRefBlockIndex);
    end


    numRowsSF=0;
    outportHandlesWithoutSF=[];
    if~isempty(SFBlockIndex)
        SFHandles=outportHandles(SFBlockIndex);
        outportSFRelativePaths=outportRelativePaths(SFBlockIndex);
        numRowsSF=numel(outportSFRelativePaths);
        outportHandlesWithoutSF=outportHandles(~SFBlockIndex);
    end


    if~isempty(SFBlockIndex)&&~isempty(modelRefBlockIndex)
        outportHandles=intersect(outportHandlesWithoutModelRef,outportHandlesWithoutSF);
    elseif~isempty(SFBlockIndex)||~isempty(modelRefBlockIndex)
        outportHandles=[outportHandlesWithoutModelRef,outportHandlesWithoutSF];
    end



    isHandleBlock=get_param(outportHandles,'Type');
    if~iscell(isHandleBlock)
        isHandleBlock={isHandleBlock};
    end
    blockTypeSigs=cellfun(@(portH)strcmp(portH,'block'),isHandleBlock);

    outportHandles=outportHandles(~blockTypeSigs);







    srcBlockHandles=get_param(outportHandles,'ParentHandle');


    srcPortNums=get_param(outportHandles,'PortNumber');


    bindableNames=get_param(outportHandles,'Name');


    if~iscell(srcBlockHandles)
        srcBlockHandles={srcBlockHandles};
        srcPortNums={srcPortNums};
        bindableNames={bindableNames};
    end


    connectionStatus=cell(1,numel(srcBlockHandles));
    connectionStatus(:)={1};

    numRows=numel(outportHandles);
    boundRows=cell(1,numRows+numRowsModelRef+numRowsSF);


    for idx=1:numRows
        metaData=BindMode.SLSignalMetaData(bindableNames{idx},getfullname(srcBlockHandles{idx}),...
        srcPortNums{idx});
        boundRows{idx}=BindMode.BindableRow(connectionStatus{idx},BindMode.BindableTypeEnum.SLSIGNAL,...
        bindableNames{idx},metaData);
    end



    for idx=1:numRowsModelRef
        metaData=slsignalselector.utils.SignalSelectorUtilities.createMRMetaData(outportModelRefRelativePaths{idx},...
        modelRefHandles(idx));

        if~isempty(metaData)
            if isa(metaData,'BindMode.SFStateMetaData')
                BindableType=BindMode.BindableTypeEnum.SFSTATE;
            elseif isa(metaData,'BindMode.SFDataMetaData')
                BindableType=BindMode.BindableTypeEnum.SFDATA;
            else
                BindableType=BindMode.BindableTypeEnum.SLSIGNAL;
            end
            boundRows{numRows+idx}=BindMode.BindableRow(true,BindableType,metaData.name,metaData);
        else
            boundRows{numRows+idx}=[];
        end
    end



    for idx=1:numRowsSF
        [bindableName,relPath,~,~,sfInfo]=slsignalselector.utils.SignalSelectorUtilities....
        getSFSignalData(SFHandles(idx),0,'',outportSFRelativePaths{idx});



        if~isempty(relPath)
            if sfInfo.isSFData
                metaDataStruct=slsignalselector.utils.SignalSelectorUtilities.createSFDataMetaData(bindableName,sfInfo.sid,sfInfo.path,sfInfo.SFDataScope);
                bindableType=BindMode.BindableTypeEnum.SFDATA;
            else

                metaDataStruct=slsignalselector.utils.SignalSelectorUtilities.createSFStateMetaData(bindableName,sfInfo.sid,sfInfo.path,sfInfo.activityType);
                bindableType=BindMode.BindableTypeEnum.SFSTATE;
            end
            metaData=BindMode.utils.getBindableMetaDataFromStruct(bindableType,metaDataStruct);
            boundRows{numRows+numRowsModelRef+idx}=BindMode.BindableRow(true,...
            bindableType,metaData.name,metaData);
        else
            boundRows{numRows+numRowsModelRef+idx}=[];
        end
    end



    if iscell(boundRows)
        connectedRows=boundRows(~cellfun('isempty',boundRows));
    else
        connectedRows=boundRows;
    end

end
