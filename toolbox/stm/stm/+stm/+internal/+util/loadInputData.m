function[loadExternalInputState,externalInputState,sigB,ind,...
    varsLoaded,currStopTime,paramValues,warnMessage,...
    logOrError,externalInputRunData,sigBuilderInfo,realTimeInfo]...
    =loadInputData(obj,simInputs,inputDataSetsRunFile,inputSignalGroupRunFile)





    loadExternalInputState='';
    externalInputState='';
    sigB=[];
    ind=[];
    varsLoaded=[];
    currStopTime='';
    warnMessage={};
    logOrError={};
    paramValues=[];
    realTimeInfo.stopTime=[];
    realTimeInfo.externalInput='';
    block=[];
    blockHandle=[];

    if~isempty(obj)&&simInputs.IsSigBuilderUsed
        block=stm.internal.blocks.SignalSourceBlock.getBlock(obj.Model,simInputs.SigBuilderGroupName);
        blockHandle=block.handle;
    end

    isEditor=double(isa(block,'stm.internal.blocks.SignalEditorBlock'));
    includeSigBuilderGroup=simInputs.IsSigBuilderUsed&&~isempty(blockHandle);
    includeExternalInputs=(~isempty(simInputs.InputFilePath)&&~isempty(simInputs.InputMappingString));

    numberOfTypesOfExternalInputs=0;
    if(simInputs.IncludeExternalInputs)
        numberOfTypesOfExternalInputs=includeExternalInputs+includeSigBuilderGroup;
    end

    externalInputRunData=...
    repmat(struct('type',[],'runID',[]),1,numberOfTypesOfExternalInputs);

    sigBuilderInfo=struct('SignalSourceComponent','','SignalSourceBlock','','SignalSourceType',isEditor);
    if simInputs.IsSigBuilderUsed
        sigBuilderInfo.SignalSourceBlock=getfullname(blockHandle);
        sigBuilderInfo.SignalSourceComponent=block.overrideScenario;
    end


    externalInput='';
    [bRequiresMapping,isSLDVData]=getInputMetadata(simInputs.InputType);
    if~isempty(simInputs.InputFilePath)
        switch simInputs.InputType
        case stm.internal.InputTypes.Mat
            varsLoaded=stm.internal.MRT.share.loadMatFile(simInputs.InputFilePath);
        case stm.internal.InputTypes.Spreadsheet

            if isfield(simInputs,'IsRunningOnCurrentRelease')&&~simInputs.IsRunningOnCurrentRelease
                stm.internal.MRT.share.error('stm:InputsView:MRTInputFileFormatError');
            end

            varsLoaded=stm.internal.InputReader.MappedInput.loadSpreadsheet(simInputs);
        case stm.internal.InputTypes.Sldv


            [externalInput,scenario,sldvVarName]=...
            stm.internal.MRT.share.loadSldvFile(simInputs.InputFilePath,str2double(simInputs.ExcelSheet));
            varsLoaded={sldvVarName};




            if isfield(simInputs,'RunOnTarget')&&simInputs.RunOnTarget&&isfield(scenario,'paramValues')
                paramValues=scenario.paramValues;
            end

            stopTimeValue=scenario.timeValues(end);
            realTimeInfo.stopTime=stopTimeValue;
            if~isempty(obj)
                currStopTime=get_param(obj.Model,'StopTime');
                stopTime=stm.internal.util.SimulinkModel.formatSimTime(stopTimeValue);
                set_param(obj.Model,'StopTime',stopTime);
            end
        otherwise
            stm.internal.MRT.share.error('stm:general:InvalidExternalInputFile');
        end

        if isempty(externalInput)
            externalInput=simInputs.InputMappingString;
        end


        if~isempty(externalInput)
            if(~isempty(obj))

                loadExternalInputState=get_param(obj.Model,'LoadExternalInput');
                externalInputState=get_param(obj.Model,'ExternalInput');
                set_param(obj.Model,'LoadExternalInput','on','ExternalInput',externalInput);
            end
        end
        realTimeInfo.externalInput=externalInput;

        if bRequiresMapping
            [mapWarn,mapLog]=stm.internal.MRT.share.verifyMappingStatus(simInputs.InputMappingStatus);
            if~isempty(mapWarn)
                warnMessage{end+1}=mapWarn;
                logOrError{end+1}=mapLog;
            end
        end
    elseif~isempty(obj)


        loadExternalInputState=get_param(obj.Model,'LoadExternalInput');
        externalInputState=get_param(obj.Model,'ExternalInput');
    end

    bIsPCT=~isempty(inputDataSetsRunFile)||~isempty(inputSignalGroupRunFile);
    simInputs.InputMappingString=externalInput;

    [fileRun,dataSets]=...
    stm.internal.MRT.share.createExternalInputRunFromFile(...
    simInputs,bIsPCT,inputDataSetsRunFile);
    if~isempty(fileRun)
        externalInputRunData(1)=fileRun;
    end

    if(includeSigBuilderGroup)
        sigBuilderGroupName=sigBuilderInfo.SignalSourceComponent;
        [sigB,ind]=block.setActiveComponent(sigBuilderGroupName);
        if(simInputs.IncludeExternalInputs)
            if(bIsPCT)
                externalInputRunData(end).runID=1;
                if(~isempty(inputSignalGroupRunFile))
                    block.getSignalFromComponent(sigBuilderGroupName,inputSignalGroupRunFile);
                end
            else
                externalInputRunId=block.getSignalFromComponent(sigBuilderGroupName,'');
                externalInputRunData(end).runID=externalInputRunId;
            end
            externalInputRunData(end).type=block.getSignalBlockType;
        end
    end

    inputRunData=externalInputRunData;
    numberOfRunsToConsiderForLastTimePoint=0;
    if(simInputs.StopSimAtLastTimePoint)
        numberOfRunsToConsiderForLastTimePoint=includeExternalInputs+includeSigBuilderGroup;
    end

    if~isfield(simInputs,'IsRunningOnCurrentRelease')
        simInputs.IsRunningOnCurrentRelease=true;
    end


    if(simInputs.StopSimAtLastTimePoint&&~isSLDVData&&numberOfRunsToConsiderForLastTimePoint>0)
        if(simInputs.IsRunningOnCurrentRelease)

            if isempty(inputRunData)||bIsPCT
                inputRunData=repmat(struct('type',[],'runID',[]),1,numberOfRunsToConsiderForLastTimePoint);


                if isempty(dataSets)
                    dataSets=stm.internal.util.SimulinkModel.getInputDataHelper(externalInput);
                end

                if(~isempty(dataSets))
                    inpRunID=stm.internal.createSet();
                    inputRunData(1).runID=inpRunID;
                    names=repmat({'input'},[1,length(dataSets)]);

                    Simulink.sdi.addToRun(inpRunID,'namevalue',names,dataSets);
                end

                if includeSigBuilderGroup
                    sigBuilderGroupName=sigBuilderInfo.SignalSourceComponent;
                    inpRunID=block.getSignalFromComponent(sigBuilderGroupName,'');
                    inputRunData(end).runID=inpRunID;
                end
            end


            tMax=stm.internal.util.SimulinkModel.getLastTimePoint(inputRunData);
        else

            tMax=[];

            dataSets=stm.internal.util.SimulinkModel.getInputDataHelper(externalInput);



            if(~isempty(dataSets))

                warnMessage{end+1}=stm.internal.MRT.share.getString('stm:MultipleReleaseTesting:StoppingAtLastPointMRT');
                logOrError{end+1}=false;
            end


            if includeSigBuilderGroup
                sigBuilderGroupName=sigBuilderInfo.SignalSourceComponent;
                tMax=block.getMaxTime(sigBuilderGroupName);
            end
        end
        if~isempty(tMax)
            realTimeInfo.stopTime=tMax;
            tMaxString=stm.internal.util.SimulinkModel.formatSimTime(tMax);
            if(~isempty(obj))
                currStopTime=get_param(obj.Model,'StopTime');
                set_param(obj.Model,'StopTime',tMaxString);
            end
            warnMessage{end+1}=stm.internal.MRT.share.getString('stm:InputsView:InputTimeModified',tMaxString);
            logOrError{end+1}=false;
        end
    end
end

function[bRequiresMapping,isSLDVData]=getInputMetadata(type)
    bRequiresMapping=false;
    isSLDVData=false;
    if~isempty(type)
        bRequiresMapping=...
        type==stm.internal.InputTypes.Mat||...
        type==stm.internal.InputTypes.Spreadsheet;
        isSLDVData=type==stm.internal.InputTypes.Sldv;
    end
end
