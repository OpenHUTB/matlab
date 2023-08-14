function addDataFromSrc(data)















    if~isfield(data,'MinValue')&&~isfield(data,'MaxValue')
        return;
    end


    if isfield(data,'MinValue')&&data.MinValue==(realmax('double'))
        return;
    end


    if isfield(data,'MaxValue')&&data.MaxValue==(-1*realmax('double'))
        return;
    end

    if isfield(data,'SignalName')
        data.ElementName=data.SignalName;
        data=rmfield(data,'SignalName');
    end

    data.HistogramData=struct();
    data.HistogramData.BinData=int32([]);
    if isfield(data,'histogramValues')
        if~isempty(data.histogramValues)
            data.HistogramData.BinData=int32(data.histogramValues);
        end
        data=rmfield(data,'histogramValues');
    end

    data.PrecisionHistogramData=struct();
    data.PrecisionHistogramData.BinData=int32([]);
    data.PrecisionHistogramData.numZeros=0;
    if isfield(data,'precisionHistogramValues')
        if~isempty(data.precisionHistogramValues)
            data.PrecisionHistogramData.BinData=int32(data.precisionHistogramValues);
        end
        data=rmfield(data,'precisionHistogramValues');
    end

    if isfield(data,'numZeros')
        data.HistogramData.numZeros=data.numZeros;
        data=rmfield(data,'numZeros');
    else
        data.HistogramData.numZeros=0;
    end


    isBlkInMdlRef=false;


    if isfield(data,'isAlwaysInteger')
        data.WholeNumber=data.isAlwaysInteger;
        data=rmfield(data,'isAlwaysInteger');
    end

    data.ExecutionOrder=get_param(data.Path,'SortedOrderDisplay');

    actualModel=bdroot(data.Path);

    blkPathToTop=get_param(actualModel,'modelReferenceNormalModeVisibilityBlockPath');
    topModel=actualModel;

    if~isempty(blkPathToTop)
        topModel=bdroot(blkPathToTop.getBlock(1));
        if~strcmp(actualModel,topModel)


            isBlkInMdlRef=true;
        end
    end



    isTopMerge=strcmp(get_param(topModel,'MinMaxOverflowArchiveMode'),'Merge');

    FPTRunName='';
    if isempty(FPTRunName)
        FPTRunName=get_param(topModel,'FPTRunName');
    end

    if isBlkInMdlRef

        refInstanceName=data.RefMdlPath;
        if isempty(refInstanceName)

            refInstanceName=blkPathToTop.getBlock(blkPathToTop.getLength());
        end

        instanceHandle=get_param(refInstanceName,'handle');
        instanceBlkDgr=bdroot(refInstanceName);
        appdata=SimulinkFixedPoint.getApplicationDataAsSubMdl(instanceBlkDgr,instanceHandle);
        curRefDataset=appdata.subDatasetMap(instanceHandle);
    else

        appdata=SimulinkFixedPoint.getApplicationData(actualModel);

        curRefDataset=appdata.dataset;
    end

    curRefDataset.setLastUpdatedRun(FPTRunName);
    if isTopMerge
        dataHandler=fxptds.SimulinkDataArrayHandler;
        runObj=curRefDataset.getRun(FPTRunName);

        oldDsRanges=runObj.getResultByID(dataHandler.getUniqueIdentifier(data));

        if~isempty(oldDsRanges)

            data=mergeMinMaxOvfFromSrc(oldDsRanges,data);
        end
    end




    runObj=curRefDataset.getRun(FPTRunName);
    runObj.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(data));


    function outDsData=mergeMinMaxOvfFromSrc(oldDsRanges,newDsRanges)


        outDsData=newDsRanges;


        if~isempty(oldDsRanges.SimMin)
            if~isfield(newDsRanges,'MinValue')||isempty(newDsRanges.MinValue)||(newDsRanges.MinValue>oldDsRanges.SimMin)
                outDsData.MinValue=oldDsRanges.SimMin;
            end
        end

        if~isempty(oldDsRanges.SimMax)
            if~isfield(newDsRanges,'MaxValue')||isempty(newDsRanges.MaxValue)||(newDsRanges.MaxValue<oldDsRanges.SimMax)
                outDsData.MaxValue=oldDsRanges.SimMax;
            end
        end

        if~isempty(oldDsRanges.OverflowWrap)
            if isfield(newDsRanges,'OverflowOccurred')&&~isempty(newDsRanges.OverflowOccurred)
                outDsData.OverflowOccurred=newDsRanges.OverflowOccurred+oldDsRanges.OverflowWrap;
            else
                outDsData.OverflowOccurred=oldDsRanges.OverflowWrap;
            end
        end

        if~isempty(oldDsRanges.OverflowSaturation)
            if isfield(newDsRanges,'SaturationOccurred')&&~isempty(newDsRanges.SaturationOccurred)
                outDsData.SaturationOccurred=newDsRanges.SaturationOccurred+oldDsRanges.OverflowSaturation;
            else
                outDsData.SaturationOccurred=oldDsRanges.OverflowSaturation;
            end
        end

        if~isempty(oldDsRanges.ParameterSaturation)
            if isfield(newDsRanges,'ParameterSaturationOccurred')&&~isempty(newDsRanges.ParameterSaturationOccurred)
                outDsData.ParameterSaturationOccurred=newDsRanges.ParameterSaturationOccurred+oldDsRanges.ParameterSaturation;
            else
                outDsData.ParameterSaturationOccurred=oldDsRanges.ParameterSaturation;
            end
        end

        if~isempty(oldDsRanges.DivideByZero)
            if isfield(newDsRanges,'DivisionByZeroOccurred')&&~isempty(newDsRanges.DivisionByZeroOccurred)
                outDsData.DivisionByZeroOccurred=newDsRanges.DivisionByZeroOccurred+oldDsRanges.DivideByZero;
            else
                outDsData.DivisionByZeroOccurred=oldDsRanges.DivideByZero;
            end
        end


        if isfield(newDsRanges,'WholeNumber')&&~isempty(newDsRanges.WholeNumber)
            if~isempty(oldDsRanges.WholeNumber)
                outDsData.WholeNumber=(newDsRanges.WholeNumber>0)&&oldDsRanges.WholeNumber;
            else
                outDsData.WholeNumber=(newDsRanges.WholeNumber>0);
            end
        end



        if isfield(newDsRanges,'HistogramData')&&~isempty(newDsRanges.HistogramData)
            outDsData.HistogramData=fxptds.HistogramUtil.mergeHistogramData(oldDsRanges.HistogramData,newDsRanges.HistogramData);
        end

        if isfield(newDsRanges,'PrecisionHistogramData')&&~isempty(newDsRanges.PrecisionHistogramData)
            outDsData.PrecisionHistogramData=fxptds.HistogramUtil.mergeHistogramData(oldDsRanges.PrecisionHistogramData,newDsRanges.PrecisionHistogramData);
        end
        return;




