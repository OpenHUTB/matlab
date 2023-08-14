function setupTestCase(tc,model,hStruct,sldvFile,simIndex,translateToExcelFile)







    assert(~isempty(tc));
    if~exist('simIndex','var')
        simIndex=1;
    end
    if~exist('translateToExcelFile','var')
        translateToExcelFile='';
    end

    if~strcmp(tc.TestType,'equivalence')
        simIndex=1;
    end

    bTopModelEmpty=false;
    for sIdx=1:length(simIndex)
        if(isempty(tc.getProperty('model',sIdx)))
            bTopModelEmpty=true;
            tc.setProperty('model',model,'SimulationIndex',sIdx);
        end
    end

    isSignalBuilderHarness=false;
    isSignalEditorHarness=false;
    if~isempty(hStruct)

        for sIdx=1:length(simIndex)
            if(bTopModelEmpty&&isempty(tc.getProperty('harnessname',sIdx)))
                tc.setProperty('harnessname',hStruct.name,'HarnessOwner',...
                hStruct.ownerFullPath,'SimulationIndex',sIdx);
            end
        end


        isSignalBuilderHarness=strcmpi(hStruct.origSrc,'Signal Builder');
        isSignalEditorHarness=strcmpi(hStruct.origSrc,'Signal Editor');
    end


    variableInfo=who('-file',sldvFile);
    if~ismember('sldvData',variableInfo)

        return;
    end

    sldvData=load(sldvFile,'sldvData');
    sldvData=sldvData.sldvData;
    if isfield(sldvData,'TestCases')
        dvData=sldvData.TestCases;
        dvDataType='TestCases';
    else
        dvData=sldvData.CounterExamples;
        dvDataType='CounterExamples';
    end


    useExcelFile=false;
    fileToUse=sldvFile;
    useTopLevelExcel=false;


    if~isempty(translateToExcelFile)
        useExcelFile=true;
        fileToUse=translateToExcelFile;
    elseif tc.getProperty('isTestDataReferenced')&&~isempty(tc.getProperty('TestDataPath'))

        useExcelFile=true;
        fileToUse=tc.getProperty('TestDataPath');
        useTopLevelExcel=true;
    end

    usedSigs=Simulink.harness.internal.populateUsedSignals(sldvData.AnalysisInformation.InputPortInfo,{});
    flatUsedSigs=flattenInputsUsedInAnalysis(usedSigs);
    usesInputsFromAnalysis=any(cell2mat(flatUsedSigs));
    usesParametersFromAnalysis=isfield(dvData,'paramValues')&&~isempty([dvData.paramValues]);
    usesOutputsFromAnalysis=isfield(dvData,'expectedOutput')&&strcmp(tc.TestType,'baseline');

    outportNamesToUse={};
    if usesOutputsFromAnalysis

        sut=model;
        if~isempty(hStruct)
            sut=hStruct.name;
            if~hStruct.isOpen
                Simulink.harness.load(hStruct.ownerFullPath,sut);
                c=onCleanup(@()sltest.harness.close(hStruct.ownerHandle,sut));
            end
        end
        saveFormat=get_param(get_param(sut,'Handle'),'SaveFormat');


        outportBlks=find_system(get_param(sut,'Handle'),'SearchDepth',1,'BlockType','Outport');

        rootOutportNames=get_param(outportBlks,'Name');

        outportPortHandles=get_param(outportBlks,'PortHandles');

        if ischar(rootOutportNames)
            rootOutportNames={rootOutportNames};
        end

        if isstruct(outportPortHandles)
            outportPortHandles={outportPortHandles};
        end
        outportNamesToUse=cellfun(@(prtHdl)get_param(prtHdl.Inport,'Name'),...
        outportPortHandles,'UniformOutput',false);


        noSigNameIdx=strcmp(outportNamesToUse,'');


        lineHdls=cellfun(@(prtHdl)get_param(prtHdl.Inport,'line'),outportPortHandles);
        outportPropagationSetting=arrayfun(@(lh)get(lh,'SignalPropagation'),...
        lineHdls,'UniformOutput',false);
        sigPropEnabledIndx=strcmp(outportPropagationSetting,'on');
        sigPropDisabledIndx=find(~sigPropEnabledIndx);




        propNames=arrayfun(@(lh)get(get_param(lh,'SrcPortHandle'),'PropagatedSignals'),...
        lineHdls,'UniformOutput',false);
        propNames(sigPropDisabledIndx)={''};


        propNameIndx=~strcmp(propNames,'');


        if useExcelFile||strcmp(saveFormat,'Dataset')
            outportNamesToUse(noSigNameIdx)=strcat(rootOutportNames(noSigNameIdx),':1');
            outportNamesToUse(propNameIndx)=propNames(propNameIndx);
        else
            outportNamesToUse(noSigNameIdx)=rootOutportNames(noSigNameIdx);
            outportNamesToUse(propNameIndx)=strcat('<',propNames(propNameIndx),'>');
        end
    end


    if useExcelFile


        sheetsAdded=stm.internal.util.exportSLDataSetsToExcel(fileToUse,sldvData,true,...
        [usesInputsFromAnalysis,usesOutputsFromAnalysis,usesParametersFromAnalysis],...
        outportNamesToUse);


        if useTopLevelExcel
            stm.internal.refreshTestCase(tc.getID);
            return
        end
    end



    nTestCases=length(dvData);
    iterationList(nTestCases)=sltest.testmanager.TestIteration();
    msng_str=string(missing);
    iterNames=strings(1,nTestCases);
    iterNames(:)=deal(msng_str);


    if(usesInputsFromAnalysis)
        if(isSignalBuilderHarness||isSignalEditorHarness)




            [groupNames,isSignalBuilderHarness]=getSignalBuilderGroups(model,hStruct.name,hStruct.ownerHandle,isSignalBuilderHarness);


            groupNames=groupNames((end-nTestCases+1):end);




            permutationID=stm.internal.getPermutations(tc.getID);
            for simIndx=1:length(simIndex)
                tc.setProperty('UseSignalBuilderGroups',true,'simulationindex',simIndx);
                stm.internal.refreshSignalBuilderGroup(permutationID(simIndx));
                tc.setProperty('signalbuildergroup',groupNames{1},'simulationindex',simIndx);
                if isSignalBuilderHarness
                    tc.setProperty('StopSimAtLastTimePoint',true,'simulationindex',simIndx);
                end
                for inpCtr=1:length(groupNames)
                    setTestParam(iterationList(inpCtr),'SignalBuilderGroup',groupNames{inpCtr},'SimulationIndex',simIndx);
                end
            end

            iterNames=groupNames;
        else

            for simIndx=1:length(simIndex)

                if useExcelFile


                    inp=tc.addInput(fileToUse,'CreateIterations',false,'SimulationIndex',simIndex(simIndx),'Sheets',sheetsAdded);
                else
                    inp=tc.addInput(fileToUse,'CreateIterations',false,'SimulationIndex',simIndex(simIndx));
                end


                prntCnt=0;
                if~useExcelFile&&nTestCases>1
                    prntCnt=1;
                end
                for inpCtr=1:length(inp)-prntCnt
                    if useExcelFile
                        inp(inpCtr+prntCnt).map();
                    end
                    setTestParam(iterationList(inpCtr),'ExternalInput',inp(inpCtr+prntCnt).Name,'SimulationIndex',simIndx);
                end
            end
            iterNames=string({inp(1+prntCnt:end).Name});
        end
    end




    if usesParametersFromAnalysis
        if usesInputsFromAnalysis&&isSignalBuilderHarness

            paramData=[dvData.paramValues];
            for simK=1:length(simIndex)
                for psIndx=1:nTestCases
                    if~isempty(paramData(psIndx))
                        psName=addParamSet(tc,paramData(:,psIndx),iterationList(psIndx),simK);
                        if ismissing(iterNames(psIndx))
                            iterNames(psIndx)=psName;
                        end
                    end
                end
            end
        else

            for simK=1:length(simIndex)
                pSets=[];
                try
                    pSets=tc.addParameterSet('FilePath',fileToUse,'simulationindex',simK);
                catch me

                    if~strcmp(me.identifier,'stm:Parameters:NoParamsFoundInFileError')
                        rethrow(me);
                    end
                end
                if~isempty(pSets)
                    for indx=1:length(pSets)
                        setTestParam(iterationList(indx),'ParameterSet',...
                        pSets(indx).Name,'SimulationIndex',simK);
                        if ismissing(iterNames(indx))
                            iterNames(indx)=pSets(indx).Name;
                        end
                    end
                end
            end
        end
    end



    if usesOutputsFromAnalysis
        if~useExcelFile

            [folderLoc,~,~]=fileparts(sldvFile);
            folderName=stm.internal.util.helperCreateUniqueFolder(folderLoc);


            convertedData=Sldv.DataUtils.convertTestCasesToSLDataSet(sldvData);
            bslnData=[convertedData.(dvDataType).expectedOutput];

            for indx=1:length(bslnData)
                if~isempty(bslnData(indx))

                    expData=bslnData(indx);
                    for elmIndx=1:expData.numElements
                        expData{elmIndx}=updateModelNPortNameInDataset(expData{elmIndx},outportNamesToUse{elmIndx},model);
                    end
                    bslnName=fullfile(folderName,[dvDataType,'_',num2str(indx),'.mat']);
                    save(bslnName,'expData');

                    bc=tc.addBaselineCriteria(bslnName,true);

                    setTestParam(iterationList(indx),'Baseline',bc.Name);
                    if ismissing(iterNames(indx))
                        iterNames(indx)=bc.Name;
                    end
                end
            end
        else

            bsln=tc.addBaselineCriteria(fileToUse,true);


            for bslnCtr=1:length(bsln)
                setTestParam(iterationList(bslnCtr),'Baseline',bsln(bslnCtr).Name);
                if ismissing(iterNames(bslnCtr))
                    iterNames(bslnCtr)=bsln(bslnCtr).Name;
                end
            end
        end
    end



    nonEmptyIterIndx=~ismissing(iterNames);
    if any(nonEmptyIterIndx)
        tc.addIteration(iterationList(nonEmptyIterIndx),iterNames(nonEmptyIterIndx));
    end

end


function pSetName=addParamSet(tc,param,itrObj,simIndex)

    pSet=tc.getParameterSets('simulationindex',simIndex);
    pSetNames={pSet.Name};
    pSetNames{end+1}='SldvParam';
    pSetNames=matlab.lang.makeUniqueStrings(pSetNames);
    pSetName=pSetNames{end};
    pSet=tc.addParameterSet('Name',pSetName,'simulationindex',simIndex);
    nParams=numel(param);
    for j=1:nParams
        pSet.addParameterOverride(param(j).name,param(j).value);
    end
    setTestParam(itrObj,'ParameterSet',pSetName);
end

function[groupNames,isSignalBuilderHarness]=getSignalBuilderGroups(model,harnessName,harnessOwnerHdl,isSignalBuilderHarness)
    groupNames=[];
    harnessList=sltest.harness.find(model,'Name',harnessName,'OpenOnly','on');
    if(isempty(harnessList))
        sltest.harness.load(harnessOwnerHdl,harnessName);
        c=onCleanup(@()sltest.harness.close(harnessOwnerHdl,harnessName));
    end


    if isSignalBuilderHarness




        sigBlk=stm.internal.blocks.SignalBuilderBlock(harnessName);
        if isempty(sigBlk.handle)
            sigBlk=stm.internal.blocks.SignalEditorBlock(harnessName);
            isSignalBuilderHarness=false;
        end
    else
        sigBlk=stm.internal.blocks.SignalEditorBlock(harnessName);
    end

    if~isempty(sigBlk.handle)
        groupNames=sigBlk.getComponentNames();
    end
end

function fListSig=flattenInputsUsedInAnalysis(usedSigs)
    fListSig={};
    for i=1:numel(usedSigs)
        if(~iscell(usedSigs{i}))
            fListSig=[fListSig,usedSigs{i}];
        else
            temp=flattenInputsUsedInAnalysis(usedSigs{i});
            fListSig=[fListSig,temp{:}];
        end
    end
end

function dsElement=updateModelNPortNameInDataset(dsElement,newPortName,newModelName)
    switch class(dsElement)
    case 'Simulink.SimulationData.Signal'


        dsElement.Name=newPortName;
        dsElement.Values=updateModelNPortNameInDataset(dsElement.Values,newPortName,newModelName);









        if~isempty(dsElement.BlockPath)
            bpCell=dsElement.BlockPath.convertToCell;
            level1PathArray=split(bpCell{1},'/');
            if~strcmp(level1PathArray{1},newModelName)
                level1PathArray{1}=newModelName;
                level1PathStr=join(level1PathArray,'/');
                bpCell{1}=level1PathStr{1};
                dsElement.BlockPath=Simulink.BlockPath(bpCell);
            end
        end

    case 'timeseries'
        dsElement.Name=newPortName;
    end
end

