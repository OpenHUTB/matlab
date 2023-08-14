function testCaseId=createUsingSLDV(obj,harnessSource,recordOutputs,translateToExcel,sldvBackToBackMode,correspondingSILHarnessCodePath)























    [sys,submodel,correspondingSILHarnessCodePath]=...
    vectorizeArgsNPerformSanityChecks(obj,correspondingSILHarnessCodePath);

    testGenModelToUse=submodel;

    if obj.fcnInterface~=""
        assert(~obj.isInBatchMode,"Non empty function interface in Batch mode.");
        Simulink.libcodegen.internal.loadCodeContext(obj.subsys,obj.fcnInterface);
        testGenModelToUse=string(obj.fcnInterface);
    end


    import stm.internal.TestForSubsystem.publishWarning;

    uniqueTestGenModelToUse=unique(testGenModelToUse);
    for i=1:numel(uniqueTestGenModelToUse)
        hCs=getActiveConfigSet(uniqueTestGenModelToUse(i));
        if~isempty(getComponent(hCs,'Design Verifier'))






            paramVal=get_param(uniqueTestGenModelToUse(i),'DVTestgenTarget');
            if~strcmp(paramVal,'Model')
                publishWarning('stm:TestForSubsystem:TestGenTargetSetToModel',obj.shouldThrow,...
                uniqueTestGenModelToUse(i));
            end
        end
    end


    if obj.fcnInterface~=""
        close_system(obj.fcnInterface,0);
    end


    oldDirtyState=get_param(submodel,'Dirty');
    oldDirtyState=string(oldDirtyState);
    obj.abortIfNoRemainingCUT();





    if obj.createHarness||...
        strcmpi(get_param(obj.subModel,'IsExportFunctionModel'),'on')||...
        (strcmp(get_param(obj.subModel,'type'),'block_diagram')&&...
        sldvshareprivate('mdl_has_missing_slfunction_defs',obj.subModel))

        origStatus=obj.proceedToNextStep;
        subsysToCreateHrnssFor=sys(origStatus);


        p=inputParser;
        p.addParameter('SaveExternally',false,@(x)validateattributes(x,{'logical'},{'scalar'}));

        try
            p.parse(obj.harnessOptions{:});
        catch
            error(message("stm:TestForSubsystem:InvalidHarnessOptionsForSLDVStrategies"));
        end

        [tempHarnessName,tempHarnessInfo]=sldvshareprivate('create_sltest_harness',...
        subsysToCreateHrnssFor,harnessSource,obj.fcnInterface,'TopModel',obj.topModel,'SaveExternally',p.Results.SaveExternally);
        if numel(subsysToCreateHrnssFor)==1
            tempHarnessInfo={tempHarnessInfo};
        end

        harnessName=strings(obj.numOfComps,1);
        harnessInfo=cell(obj.numOfComps,1);
        j=0;
        for i=1:obj.numOfComps
            if origStatus(i)
                j=j+1;
                if~isempty(tempHarnessInfo{j})&&isa(tempHarnessInfo{j},"struct")
                    harnessName(i)=tempHarnessName(j);
                    harnessInfo{i}=tempHarnessInfo{j};
                elseif~isempty(tempHarnessInfo{j})&&(isa(tempHarnessInfo{j},"MException")||isa(tempHarnessInfo{j},"MSLException"))
                    obj.populateErrorContainer(tempHarnessInfo{j},i);
                end
            end
        end




        subs=obj.subs;%#ok<NASGU> 

    else
        harnessName="";
        harnessInfo={[]};









        harnessSource='Inport';
    end
    obj.abortIfNoRemainingCUT();

    obj.harnessInfo=harnessInfo;




    loggedTestPath=simNLogTestCase(obj,harnessInfo);


    excelFilePath=strings(obj.numOfComps,1);
    if translateToExcel
        obj.resolveFilePaths();
        excelFilePath=obj.location1;
    end
    obj.abortIfNoRemainingCUT();




    warnID='Simulink:Harness:HarnessDeletedIndependentHarness';
    warning('off',warnID);


    w_ocp=onCleanup(@()warning('on',warnID));

    subModel=testGenModelToUse;
    subsys=sys;
    testCaseId=zeros(obj.numOfComps,1);


    for i=1:obj.numOfComps
        try
            if obj.proceedToNextStep(i)
                testCaseId(i)=stm.internal.createTestFromSubsystemUsingSLDV(...
                obj.parentSuiteID,...
                submodel(i),...
                subModel(i),...
                subsys(i),...
                harnessName(i),...
                harnessSource,...
                recordOutputs,...
                int32(obj.testType),...
                excelFilePath(i),...
                loggedTestPath(i),...
                sldvBackToBackMode,...
                correspondingSILHarnessCodePath(i),...
                obj.isInBatchMode);
            end
        catch ME

            if harnessName(i)~=""


                stm.internal.TestForSubsystem.closeAndDeleteHarness(sys(i),harnessName(i));
            end
            set_param(submodel(i),'Dirty',oldDirtyState(i));


            excepToShow=ME;
            if didSLDVFailDueToHarnessHavingDirtyModelReferences(ME,harnessName(i))



                eID='stm:TestForSubsystem:SldvAnalysisFailedDueToModelsBeingDirty';
                Mex=MException(eID,message(eID,sys(i)).getString);
                Mex=Mex.addCause(ME);
                excepToShow=Mex;
            elseif harnessName(i)~=""&&contains(ME.message,harnessName(i))
                eID='stm:TestForSubsystem:SldvAnalysisFailedHarness';
                Mex=MException(eID,message(eID,sys(i)));


                Mex=Mex.addCause(ME);
                excepToShow=Mex;
            end
            obj.populateErrorContainer(excepToShow,i);
        end
    end

    if strcmp(harnessSource,'Signal Editor')
        for i=1:obj.numOfComps
            if obj.proceedToNextStep(i)

                if harnessName(i)~=""
                    removeDefaultSignalEditorScenario(sys(i),harnessName(i));
                end

                if testCaseId(i)>0
                    permIds=stm.internal.getPermutations(testCaseId(i));
                    stm.internal.refreshSignalBuilderGroup(permIds(1));
                end
            end
        end
    end



    for i=1:obj.numOfComps
        if harnessName(i)~=""&&obj.proceedToNextStep(i)
            hrns=Simulink.harness.find(sys(i),'Name',harnessName(i));
            if~hrns.saveExternally
                set_param(submodel(i),'Dirty','on');
            else

                set_param(submodel(i),'Dirty',oldDirtyState(i));
            end
        end
    end
end

function removeDefaultSignalEditorScenario(harnessOwner,harnessName)
    if~bdIsLoaded(harnessName)
        Simulink.harness.load(harnessOwner,harnessName);
        clnObj=onCleanup(@()Simulink.harness.close(harnessOwner,harnessName));
    end

    sigBlk=stm.internal.blocks.SignalEditorBlock(harnessName);



    tmp=rmfield(load(sigBlk.fileName),char(sigBlk.scenarioNames(1)));
    save(sigBlk.fileName,'-struct','tmp');


    scns=sigBlk.getComponentNames();
    sigBlk.setActiveComponent(scns{1});

    hrns=Simulink.harness.find(harnessOwner,'Name',harnessName);
    if hrns.saveExternally
        save_system(harnessName);
    end
end

function loggedTestPath=simNLogTestCase(obj,harnessInfo)
    isUsingSLDVTestExtension=slfeature('STMSldvUseHarnessForAnalysis')>0&&...
    slfeature('STMSldvTestExtensionInCUT')>0&&...
    obj.sldvWithSimulation;

    loggedTestPath=strings(obj.numOfComps,1);


    if~isUsingSLDVTestExtension
        return;
    end


    if bdIsLibrary(obj.topModel)
        warning(message('stm:TestForSubsystem:CannotSimLibraryModel'));
        return;
    end














    isMAT=true;
    subs=obj.subs;
    obj.simOutSaver=cellfun(@(x,y)stm.internal.SimOutSaveHelper(isMAT,x,obj.isComponentTopModel(y.handle),obj.topModel.char),harnessInfo,subs,"UniformOutput",true);

    prevVal=struct(...
    'isExcel',obj.isExcel,...
    'location1',obj.location1,...
    'location2',obj.location2);


    obj.isExcel=false;
    obj.location1='';
    obj.location2='';

    [outputData,~]=obj.logComponentIO;





    updateSignalEditorScenarioInHarness=false;
    emptySigs=obj.flattenSaveSimOut(outputData,updateSignalEditorScenarioInHarness);
    if~isempty(emptySigs)
        publishWarning('stm:TestForSubsystem:WarningEmptySignalsFoundInTestForSubsystem',obj.shouldThrow,emptySigs.join(', '));
    end

    idx=logical(obj.hasInputs);
    loggedTestPath(idx)=obj.location1(idx);


    obj.isExcel=prevVal.isExcel;
    obj.location1=prevVal.location1;
    obj.location2=prevVal.location2;






end

function[sys,submodel,correspondingSILHarnessCodePath]=...
    vectorizeArgsNPerformSanityChecks(obj,correspondingSILHarnessCodePath)





    sys=obj.subsys;
    submodel=obj.subModel;
    correspondingSILHarnessCodePath=string(correspondingSILHarnessCodePath);


    assert(isstring(sys)&&...
    isstring(correspondingSILHarnessCodePath)&&isstring(submodel)&&...
    obj.numOfComps==numel(correspondingSILHarnessCodePath),"Arrays not converted properly or not the right size.");



    if obj.isInBatchMode
        if obj.fcnInterface~=""
            eID='stm:TestForSubsystem:FunctionInterfaceBatchModeLimitation';
            throw(MException(eID,message(eID).getString));
        elseif~obj.createHarness
            eID='stm:TestForSubsystem:HarnessAlwaysCreatedInBatchMode';
            throw(MException(eID,message(eID).getString));
        end
    end
end

function result=didSLDVFailDueToHarnessHavingDirtyModelReferences(ME,harnessName)





    result=contains(ME.message,['The model ''',char(harnessName),''' cannot be copied.'])&&...
    contains(ME.message,strsplit(message('Simulink:modelReference:SaveSystemWithDirtyReferencedModels','#').getString,'#'));
end


