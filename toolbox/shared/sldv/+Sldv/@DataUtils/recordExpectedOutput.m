function sldvDataOutputs=recordExpectedOutput(sldvData,model,testComp,tcIdxToSimoutMap)




    if nargin<4
        tcIdxToSimoutMap=[];
    end
    sldvDataOutputs=sldvData;
    try


        if~isa(tcIdxToSimoutMap,'containers.Map')
            runtestopts=sldvruntestopts;
            runtestopts.fastRestart=true;
            runtestopts.expectedOutput=true;
            if(strcmp(testComp.activeSettings.UseParallel,'on'))
                runtestopts.useParallel=true;
            end
            expectedOutput=sldvruntest(model,sldvData,runtestopts);
            for idx=1:length(expectedOutput)

                if~isempty(expectedOutput(idx).ErrorMessage)
                    expectedOutput(idx)=[];
                end
            end
        else
            expectedOutput=[];
            runtestopts=sldvruntestopts;
            runtestopts.fastRestart=true;
            runtestopts.expectedOutput=true;
            if(strcmp(testComp.activeSettings.UseParallel,'on'))
                runtestopts.useParallel=true;
            end
            for idx=1:length(sldvData.TestCases)
                simOut=tcIdxToSimoutMap(idx);
                if isempty(simOut)


                    runtestopts.testIdx=[runtestopts.testIdx,idx];
                elseif simOut==-1


                    tcIdxToSimoutMap(idx)=[];
                end
            end
            if~isempty(runtestopts.testIdx)
                expOut=sldvruntest(model,sldvData,runtestopts);
            end
            for idx=1:length(runtestopts.testIdx)
                if isempty(expOut(idx).ErrorMessage)
                    tcIdxToSimoutMap(runtestopts.testIdx(idx))=expOut(idx);
                else

                    tcIdxToSimoutMap(runtestopts.testIdx(idx))=[];
                end
            end
        end
    catch Mex




        if strcmp(Mex.identifier,'Simulink:Logging:RefModelSaveFormatMismatch')
            warnmsg=getString(message('Sldv:Sldvruntest:UnableToIncludeExpectedOutputValues',[newline,Mex.message]));
            warning('Sldv:Sldvruntest:UnableToIncludeExpectedOutputValues',warnmsg);
        else
            warnmsg='';
            for i=1:length(Mex.cause)
                if strcmp(Mex.cause{i}.identifier,'Simulink:Logging:RefModelSaveFormatMismatch')
                    if isempty(warnmsg)
                        warnmsg=Mex.cause{i}.message;
                    else
                        warnmsg=[warnmsg,newline,Mex.cause{i}.message];%#ok<AGROW>
                    end
                end
            end
            if~isempty(warnmsg)
                warnmsg=getString(message('Sldv:Sldvruntest:UnableToIncludeExpectedOutputValues',[newline,warnmsg]));
                warning('Sldv:Sldvruntest:UnableToIncludeExpectedOutputValues',warnmsg);
            end
        end
        rethrow(Mex);
    end
    outputPortInfo=sldvData.AnalysisInformation.OutputPortInfo;
    numOutports=length(outputPortInfo);

    if(~isempty(expectedOutput)||~isSimDataEmpty(tcIdxToSimoutMap))&&numOutports>0
        SimData=Sldv.DataUtils.getSimData(sldvDataOutputs);
        if~isa(tcIdxToSimoutMap,'containers.Map')
            numTestCases=length(expectedOutput);
        else
            if isfield(sldvData,'TestCases')
                numTestCases=length(sldvData.TestCases);
            elseif isfield(sldvData,'CounterExamples')
                numTestCases=length(sldvData.CounterExamples);
            else
                return;
            end
        end
        origTsTimeInfo=cell(numTestCases,numOutports);
        for idx=1:numTestCases
            if~isa(tcIdxToSimoutMap,'containers.Map')
                simOut=expectedOutput(idx);
            else
                simOut=tcIdxToSimoutMap(idx);
            end
            if isempty(simOut)
                SimData(idx).expectedOutput={};
                continue;
            end

            expectedOutputData=cell(numOutports,1);
            outTimeseries=findDataSet(simOut,outputPortInfo,testComp,model);
            timeValuesInTc=SimData(idx).timeValues;

            for jdx=1:numOutports
                isPortBusArray=false;
                if iscell(outputPortInfo{jdx})&&isfield(outputPortInfo{jdx}{1},'Dimensions')&&...
                    any(outputPortInfo{jdx}{1}.Dimensions~=1)
                    isPortBusArray=true;
                end

                expectedOutputData{jdx}=getCellArrayData(...
                outTimeseries{jdx},...
                outputPortInfo{jdx},...
                isPortBusArray,...
                length(timeValuesInTc));
                origTsTimeInfo{idx,jdx}=findTimeValues(outTimeseries{jdx},...
                outputPortInfo{jdx},isPortBusArray);
            end
            SimData(idx).expectedOutput=expectedOutputData;
        end

        funTs=...
        sldvshareprivate('mdl_derive_sampletime_for_sldvdata',sldvDataOutputs.AnalysisInformation.SampleTimes);

        if~acceptableOutData(origTsTimeInfo,outputPortInfo,funTs,SimData)
            wstate=warning('backtrace');
            warning('backtrace','off');
            warning(message('Sldv:shared:DataUtils:MissingOutportValues',get_param(model,'Name')));
            warning('backtrace',wstate.state);
            return;
        end

        sldvDataOutputs=Sldv.DataUtils.setSimData(sldvDataOutputs,[],SimData);

        for i=1:length(SimData)
            simData=SimData(i);
            if isempty(simData.expectedOutput)||isempty(simData.dataValues)

                continue;
            end

            timeExpanded=Sldv.DataUtils.expandTimeForTimeseries(simData.timeValues,funTs);

            for j=1:length(simData.expectedOutput)
                isPortBusArray=false;
                if iscell(outputPortInfo{j})&&isfield(outputPortInfo{j}{1},'Dimensions')&&...
                    any(outputPortInfo{j}{1}.Dimensions~=1)
                    isPortBusArray=true;
                end

                simData.expectedOutput{j}=resampleOutputValues(timeExpanded,...
                simData.expectedOutput{j},...
                outputPortInfo{j},...
                origTsTimeInfo{i,j},...
                isPortBusArray);
            end
            sldvDataOutputs=Sldv.DataUtils.setSimData(sldvDataOutputs,i,simData);
        end
    end
end

function out=isSimDataEmpty(tcIdxToSimoutMap)
    out=false;
    if isempty(tcIdxToSimoutMap)
        out=true;
        return;
    end
    for idx=1:tcIdxToSimoutMap.Count
        if~isempty(tcIdxToSimoutMap(idx))
            return;
        end
    end
    out=true;
end

function outTimeseries=findDataSet(simOut,outputPortInfo,testComp,simModel)
    [~,outPorts]=Sldv.utils.getSubSystemPortBlks(simModel);



    modelHasOutBusElem=any(contains(get_param(outPorts,'IsBusElementPort'),'on'));
    numOutports=length(outputPortInfo);
    if(modelHasOutBusElem)
        isCompiledInfoNotAvailable=isOutBusDataTypeInherited(outputPortInfo);
        if isCompiledInfoNotAvailable
            errorMessage=getString(message('Sldv:DataUtils:ModelHasInheritedOutBusElems',Simulink.ID.getFullName(simModel)));
            Mex=MException('Sldv:DataUtils:ModelHasInheritedOutBusElems',errorMessage);
            throw(Mex);
        end







        outTimeseries=findDataSet_BEP(simOut,outputPortInfo,testComp,simModel,outPorts);
        return;
    end
    outTimeseries=cell(numOutports,1);
    outDataSet=[];
    yout=[];
    loggedvars=simOut.who;
    for idx=1:length(loggedvars)
        if isa(simOut.get(loggedvars{idx}),'Simulink.SimulationData.Dataset')
            if strcmp(loggedvars{idx},'logsout_Validator')||strcmp(loggedvars{idx},'logsout_sldvruntest')
                outDataSet=simOut.get(loggedvars{idx});
            elseif strcmp(loggedvars{idx},'yout_Validator')||strcmp(loggedvars{idx},'yout_sldvruntest')
                yout=simOut.get(loggedvars{idx});
            end
        end
    end
    assert(~isempty(outDataSet));
    for idx=1:numOutports
        out_idx_info=outputPortInfo{idx};
        if iscell(out_idx_info)
            out_idx_info=out_idx_info{1};
        end

        forceMapToExtractedModel=true;


        outBlockPath=...
        Sldv.DataUtils.mapReplacementObject(get_param(out_idx_info.BlockPath,'Handle'),simModel,testComp,forceMapToExtractedModel);

        portHandles=get_param(outBlockPath,'PortHandles');
        lineH=get_param(portHandles.Inport(1),'Line');

        if lineH==-1
            for i=1:yout.getLength
                blkPathObject=yout.getElement(i).BlockPath;
                if outBlockPath==get_param(blkPathObject.getBlock(1),'handle')
                    outTimeseries{idx}=yout.getElement(i).Values;
                    break;
                end
            end
        else
            srcBlockH=get_param(lineH,'SrcBlockHandle');
            srcOutportNum=get_param(get_param(lineH,'SrcPortHandle'),'PortNumber');
            for jdx=1:outDataSet.getLength
                element=outDataSet.getElement(jdx);
                if~isa(element,'Simulink.SimulationData.Signal')
                    continue;
                end
                if element.BlockPath.getLength>1

                    continue;
                end
                loggedBlkH=get_param(element.BlockPath.getBlock(1),'handle');
                loggedPortNum=element.PortIndex;
                if srcOutportNum==loggedPortNum&&srcBlockH==loggedBlkH
                    outTimeseries{idx}=element.Values;
                    break;
                end
            end
        end
    end
end

function timeValues=findTimeValues(elem,portInfo,isBusArray)
    if isstruct(elem)
        if isBusArray
            timeValues=findTimeValues(elem(1),portInfo,false);
        else
            fields=fieldnames(elem);
            pInfo=portInfo{2};
            isChildBusArray=false;
            if iscell(pInfo)&&isfield(pInfo{1},'Dimensions')&&any(pInfo{1}.Dimensions~=1)
                isChildBusArray=true;
            end
            timeValues=findTimeValues(elem.(fields{1}),pInfo,isChildBusArray);
        end
    else
        timeValues=elem.Time';
    end
end

function dataCellArray=getCellArrayData(value,portInfo,isBusArray,numSteps)
    if~isa(value,'timeseries')
        if isBusArray

            dataCellArray=cell(size(value));
            for idx=1:numel(value)
                dataCellArray{idx}=getCellArrayData(value(idx),portInfo,...
                false,numSteps);
            end
        else

            fields=fieldnames(value);
            numElements=length(fields);
            dataCellArray=cell(numElements,1);
            for idx=1:numElements
                pInfo=portInfo{idx+1};
                isChildBusArray=false;
                if iscell(pInfo)&&isfield(pInfo{1},'Dimensions')&&any(pInfo{1}.Dimensions~=1)
                    isChildBusArray=true;
                end
                dataCellArray{idx}=getCellArrayData(value.(fields{idx}),...
                pInfo,isChildBusArray,...
                numSteps);
            end
        end
    else
        dataCellArray=convertTimeseriesToSldvData(value,portInfo.Dimensions);








        if(numel(dataCellArray)~=numSteps)&&...
            numel(dataCellArray)==1
            value=dataCellArray;
            dataCellArray=value*ones(1,numSteps);
        end
    end
end

function dataArray=convertTimeseriesToSldvData(timeseriesdata,portDim)



















    nTimeSteps=length(timeseriesdata.time);
    dataArray=timeseriesdata.Data;







    if isscalar(portDim)&&isequal(size(dataArray),[nTimeSteps,portDim])
        doTranspose=true;
    else
        doTranspose=false;
    end

    if doTranspose
        dataArray=transpose(dataArray);
    end

    if nTimeSteps==1&&length(portDim)>=2&&portDim(1)>1


        dataArray=reshape(dataArray,portDim);
    end
end

function status=acceptableOutData(origTsTimeInfo,outputPortInfo,funTs,SimData)
    status=true;
    [numTestCases,numOutports]=size(origTsTimeInfo);
    for idx=1:numTestCases
        if isempty(SimData(idx).expectedOutput)
            continue;
        end
        for jdx=1:numOutports
            timeInfo=origTsTimeInfo{idx,jdx};
            if isempty(timeInfo)
                status=false;
                break;
            else
                outportDiscreteSampleTime=deriveSampleTime(outputPortInfo{jdx},funTs);
                timeValuesExpanded=Sldv.DataUtils.expandTimeForTimeseries(timeInfo,funTs);
                nTimeStepsDecimated=ceil(length(timeValuesExpanded)/floor(outportDiscreteSampleTime(1)/funTs));


                nTimeStepsRequired=round((timeInfo(end)-outportDiscreteSampleTime(2))/outportDiscreteSampleTime(1))+1;
                if nTimeStepsRequired~=nTimeStepsDecimated
                    status=false;
                    break;
                end
            end
        end
        if~status
            break;
        end
    end
end

function outportDiscreteSampleTime=deriveSampleTime(outputPortInfo,funTs)
    if~iscell(outputPortInfo)
        outportDiscreteSampleTime=outputPortInfo.ParentSampleTime;
        if length(outportDiscreteSampleTime)==1&&...
            (isinf(outportDiscreteSampleTime)||outportDiscreteSampleTime==0)
            outportDiscreteSampleTime=[funTs,0];
        end
    else
        outportDiscreteSampleTime=deriveSampleTime(outputPortInfo{2},funTs);
    end
end

function sampledOutputValues=resampleOutputValues(tcTimeValues,outputData,outportInfo,outTimeValues,isBusArray)
    if(length(tcTimeValues)==length(outTimeValues)&&all(tcTimeValues==outTimeValues))

        sampledOutputValues=outputData;
        return;
    end

    if~iscell(outputData)
        DataMatrix=Sldv.DataUtils.interpBelow(outTimeValues,outputData,tcTimeValues,outportInfo.Dimensions);
        if isscalar(outportInfo.Dimensions)
            sampledOutputValues=DataMatrix';
        else
            sampledOutputValues=DataMatrix;
        end
    else
        if isBusArray
            sampledOutputValues=cell(size(outputData));
            for i=1:numel(outputData)
                sampledOutputValues{i}=resampleOutputValues(tcTimeValues,outputData{i},outportInfo,outTimeValues,false);
            end
        else
            numComponents=length(outputData);
            sampledOutputValues=cell(numComponents,1);
            for i=1:numComponents
                pInfo=outportInfo{i+1};
                isChildBusArray=false;
                if iscell(pInfo)&&isfield(pInfo{1},'Dimensions')&&any(pInfo{1}.Dimensions~=1)
                    isChildBusArray=true;
                end
                sampledOutputValues{i}=resampleOutputValues(tcTimeValues,outputData{i},pInfo,outTimeValues,isChildBusArray);
            end
        end
    end
end

function outTimeseries=findDataSet_BEP(simOut,outputPortInfo,testComp,simModel,outPorts)





    numOutports=length(outPorts);
    simStartTime=simOut.SimulationMetadata.ModelInfo.StartTime;
    simStopTime=simOut.SimulationMetadata.ModelInfo.StopTime;

    outDataSet=[];
    yout=[];
    loggedvars=simOut.who;
    for idx=1:length(loggedvars)
        if isa(simOut.get(loggedvars{idx}),'Simulink.SimulationData.Dataset')
            if strcmp(loggedvars{idx},'logsout_Validator')||strcmp(loggedvars{idx},'logsout_sldvruntest')
                outDataSet=simOut.get(loggedvars{idx});
            elseif strcmp(loggedvars{idx},'yout_Validator')||strcmp(loggedvars{idx},'yout_sldvruntest')
                yout=simOut.get(loggedvars{idx});
            end
        end
    end
    assert(~isempty(outDataSet));



    outTimeseries=sldvshareprivate('createDefaultTimeSeries',outputPortInfo,...
    testComp.mdlFlatIOInfo.Outport,...
    simStartTime,simStopTime,simModel);
    for idx=1:numOutports
        portNumber=str2double(get_param(outPorts(idx),'Port'));
        out_idx_info=outputPortInfo{portNumber};
        if iscell(out_idx_info)
            out_idx_info=out_idx_info{1};%#ok<NASGU> % will be used in a eval command
        end
        outBlockPath=Sldv.DataUtils.mapReplacementObject(outPorts(idx),simModel,testComp);

        portHandles=get_param(outBlockPath,'PortHandles');
        lineH=get_param(portHandles.Inport(1),'Line');

        if lineH==-1
            for i=1:yout.getLength
                blkPathObject=yout.getElement(i).BlockPath;
                if outBlockPath==get_param(blkPathObject.getBlock(1),'handle')
                    outTimeseries{idx}=yout.getElement(i).Values;
                    break;
                end
            end
        else
            srcBlockH=get_param(lineH,'SrcBlockHandle');
            srcOutportNum=get_param(get_param(lineH,'SrcPortHandle'),'PortNumber');
            for jdx=1:outDataSet.getLength
                element=outDataSet.getElement(jdx);
                if~isa(element,'Simulink.SimulationData.Signal')
                    continue;
                end
                if element.BlockPath.getLength>1

                    continue;
                end
                loggedBlkH=get_param(element.BlockPath.getBlock(1),'handle');
                loggedPortNum=element.PortIndex;
                if srcOutportNum==loggedPortNum&&srcBlockH==loggedBlkH
                    outElement=get_param(outBlockPath,'Element');
                    if isempty(outElement)


                        outTimeseries{portNumber}=element.Values;
                    else
                        eval(['outTimeseries{portNumber}.',outElement,'= outDataSet.getElement(jdx).Values;']);%#ok<EVLDOT> 
                    end
                end
            end
        end
    end

    for idx=1:length(outputPortInfo)
        out_idx_info=outputPortInfo{idx};
        if iscell(out_idx_info)
            out_idx_info=out_idx_info{1};
        end
        blockH=get_param(out_idx_info.BlockPath,'handle');
        portNumber=str2double(get_param(blockH,'port'));
        assert(idx==portNumber);
    end
end

function isOutBusDataTypeDefined=isOutBusDataTypeInherited(outputPortInfo)

    isOutBusDataTypeDefined=false;
    for idx=1:length(outputPortInfo)
        out_idx_info=outputPortInfo{idx};
        if iscell(out_idx_info)
            out_idx_info=out_idx_info{1};
        end
        blockH=get_param(out_idx_info.BlockPath,'handle');
        if sldvshareprivate('isBusElem',blockH)
            if strcmp(out_idx_info.SignalHierarchy.BusObject,"auto")
                isOutBusDataTypeDefined=true;
                return;
            end
        end
    end
end

