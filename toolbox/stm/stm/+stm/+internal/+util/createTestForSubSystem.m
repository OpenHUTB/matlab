function[result,status]=createTestForSubSystem(subsys,topModel,testfileLocation,parentSuiteID,shouldThrow,...
    testCaseType,loc1,loc2,dataLocation,isExcel,options)










    [harnessOpts,parentSuiteID,testfileLocation,subsys,topModel,...
    subModel,numOfComps,fcnInterface,isInBatchMode,isUIMode]=...
    preProcessArgsForUIWorkflow(options,parentSuiteID,testfileLocation,subsys,topModel);%#ok<ASGLU>



    if(options.useSldv&&options.sldvWithSimulation)||(~options.useSldv&&options.recordCurrentState)
        validateTopModelsSimulationSettings(topModel);
    end


    origAutoSaveSetting=get_param(0,"AutoSaveOptions");
    if isInBatchMode&&origAutoSaveSetting.SaveOnModelUpdate
        ocpRevertAutoSaveSetting=onCleanup(@()set_param(0,"AutoSaveOptions",origAutoSaveSetting));
        newAutoSaveSetting=origAutoSaveSetting;
        newAutoSaveSetting.SaveOnModelUpdate=false;
        set_param(0,"AutoSaveOptions",newAutoSaveSetting);
    end






    tForSubsys=stm.internal.TestForSubsystem(subsys,topModel,testfileLocation,...
    parentSuiteID,shouldThrow,options.createForTopModel,harnessOpts);
    tForSubsys=setTestForSubsystemProperties(tForSubsys,testCaseType,loc1,loc2,options,isExcel,dataLocation,isUIMode);


    useSldv=options.useSldv;
    if options.harnessSrcType==""
        options.harnessSrcType="Inport";
    end
    isLoggingWorkflow=~useSldv&&options.recordCurrentState;


    tForSubsys.validateMsgPortsNHrnss(isLoggingWorkflow);





    oldDirtyState=get_param(topModel,"Dirty");
    if bdIsLibrary(topModel)&&(~options.createForTopModel||isInBatchMode)
        if get_param(topModel,"Lock")=="on"
            set_param(topModel,"Lock","off");
            rstLock=onCleanup(@()set_param(topModel,"Lock","on"));
        end
    end


    [correspondingSILHarnessCodePaths,sim2ModeToUse,silHarnessNames,...
    preserve_dirty]=tForSubsys.createSILPILHarnessesIfNeeded(options);%#ok<ASGLU>



    idx=silHarnessNames~="";
    subsystemsForWhichSILHarnessWasCreated=subsys(idx);
    correspondingSILHarnessNames=silHarnessNames(idx);


    try
        if useSldv
            [isEquivalenceTestWithSILOrPIL,options]=determineSldvB2BModeSetting(testCaseType,options,subsys,fcnInterface,subModel);
            testCaseId=tForSubsys.createUsingSLDV(options.harnessSrcType,options.recordOutputs,isExcel,...
            options.sldvBackToBackMode&&isEquivalenceTestWithSILOrPIL,correspondingSILHarnessCodePaths);
        else
            if options.recordCurrentState
                testCaseId=tForSubsys.create(options.harnessSrcType);
            else
                testCaseId=tForSubsys.createHarnessOnly();
            end
        end
    catch ME

        if~isempty(subsystemsForWhichSILHarnessWasCreated)
            arrayfun(@(x,y)stm.internal.TestForSubsystem.closeAndDeleteHarness(x,y),subsystemsForWhichSILHarnessWasCreated,correspondingSILHarnessNames);
            clear preserve_dirty;
        end
        set_param(topModel,"Dirty",oldDirtyState);
        testCaseId=zeros(numel(subsys),1);
        if ME.identifier~="stm:TestForSubsystem:TestCreationFailedForAllComponents"
            rethrow(ME);
        end
    end



    if~isempty(subsystemsForWhichSILHarnessWasCreated)
        clear preserve_dirty;
        for i=1:numel(subsystemsForWhichSILHarnessWasCreated)
            silHrns=Simulink.harness.find(subsystemsForWhichSILHarnessWasCreated(i),"Name",correspondingSILHarnessNames(i));
            if~silHrns.saveExternally
                set_param(bdroot(subsystemsForWhichSILHarnessWasCreated(i)),"Dirty","on");
            end
        end
    end
    [result,status]=tForSubsys.configureTestCasesAndBuildResultsArray(testCaseId,silHarnessNames,sim2ModeToUse,options);

    if~isempty(subsystemsForWhichSILHarnessWasCreated)
        tForSubsys.publishWarning('stm:TestForSubsystem:TwoHarnessCreatedInTwoModesWarning',false,strjoin(subsystemsForWhichSILHarnessWasCreated,", "));
    end

    if isUIMode&&isInBatchMode

        rpt=stm.internal.TestForSubsystem.createReport(topModel,testfileLocation,result,subsys,status);
    end
end

function[harnessOpts,parentSuiteID,testfileLocation,subsys,topModel,...
    subModel,numOfComps,fcnInterface,isInBatchMode,isUIMode]=...
    preProcessArgsForUIWorkflow(options,parentSuiteID,testfileLocation,subsys,topModel)

    isUIMode=~isfield(options,'harnessOptions');
    if isUIMode
        harnessOpts={};
    else
        harnessOpts=options.harnessOptions;
    end

    if parentSuiteID==0
        if isempty(testfileLocation)
            testfileLocation=message('stm:TestFromModelComponents:DataFileOptionsStep_TF_DefaultLoc',topModel).getString;
        end
        tf=stm.internal.TestForSubsystem.createTestFile(testfileLocation);
        parentSuiteID=tf.getID;
        testfileLocation=tf.FilePath;
    end


    subsys=string(subsys);
    topModel=string(topModel);
    numOfComps=numel(subsys);
    isInBatchMode=numOfComps>1;








    if~isInBatchMode&&~isUIMode
        subsys=stm.internal.TestForSubsystem.constructFullSSPath(subsys,topModel);
    end

    assert(bdIsLoaded(topModel),"Model not loaded, cannot proceed.");
    subModel=bdroot(subsys);
    fcnInterface=char(options.fcnInterface);
end

function validateTopModelsSimulationSettings(topModel)
    if~any(strcmpi(get_param(topModel,"SimulationMode"),["Normal","Accelerator"]))
        error(message('stm:general:TestForSubsystemInvalidSimulationMode'));
    end
    if isinf(str2double(get_param(topModel,'StopTime')))
        error(message('stm:general:InvalidSimulationStopTime'));
    end
end

function tForSubsys=setTestForSubsystemProperties(tForSubsys,testCaseType,loc1,loc2,options,isExcel,dataLocation,isUIMode)
    tForSubsys.testType=testCaseType;
    tForSubsys.location1=loc1;
    tForSubsys.location2=loc2;
    tForSubsys.sim1Mode=options.sim1Mode;
    tForSubsys.sim2Mode=options.sim2Mode;
    tForSubsys.isExcel=isExcel;
    tForSubsys.dataLocation=dataLocation;
    tForSubsys.fcnInterface=options.fcnInterface;
    tForSubsys.createHarness=options.createHarness;
    tForSubsys.sldvWithSimulation=options.sldvWithSimulation;
    tForSubsys.isUIMode=isUIMode;
end

function[isEquivalenceTestWithSILOrPIL,options]=determineSldvB2BModeSetting(testCaseType,options,subsys,fcnInterface,subModel)
    isEquivalenceTest=testCaseType==sltest.testmanager.TestCaseTypes.Equivalence;
    isSim2ModeSilPil=options.sim2Mode=="Software-in-the-Loop (SIL)"||...
    options.sim2Mode=="Processor-in-the-Loop (PIL)";
    isEquivalenceTestWithSILOrPIL=isEquivalenceTest&&isSim2ModeSilPil;




    checkSldvB2BFromModelSetting=slfeature('STMSldvBackToBackMode')==1&&...
    xor(isEquivalenceTestWithSILOrPIL,options.sldvBackToBackMode);

    isModelSettingEMCDC=false;
    isEmptyRecordOutputs=isempty(options.recordOutputs);


    if isEmptyRecordOutputs||checkSldvB2BFromModelSetting

        if fcnInterface~=""
            Simulink.libcodegen.internal.loadCodeContext(subsys.char,fcnInterface);
        end

        uqSetOfSubModels=unique(subModel);
        hCs=arrayfun(@(x)getActiveConfigSet(x),uqSetOfSubModels,"UniformOutput",true);
        indsOfsubModelsWithDVSettingsAvailable=arrayfun(@(x)~isempty(getComponent(x,'Design Verifier')),hCs,"UniformOutput",true);
        subModelsWithDVSettingsAvailable=uqSetOfSubModels(indsOfsubModelsWithDVSettingsAvailable);
        hCsOfsubModelsWithDVSettingsAvailable=hCs(indsOfsubModelsWithDVSettingsAvailable);
        if~isempty(subModelsWithDVSettingsAvailable)
            if isEmptyRecordOutputs
                options.recordOutputs=any(string(get_param(subModelsWithDVSettingsAvailable,"DVSaveExpectedOutput"))=="on");
            end
            if checkSldvB2BFromModelSetting&&any(string(get_param(subModelsWithDVSettingsAvailable,"DVModelCoverageObjectives"))=="EnhancedMCDC")
                options.sldvBackToBackMode=true;
                isModelSettingEMCDC=true;
            end
        elseif isEmptyRecordOutputs
            options.recordOutputs=false;
        end
    end

    if slfeature('STMSldvBackToBackMode')==1&&options.sldvBackToBackMode&&~isModelSettingEMCDC



        if~isEquivalenceTest

            warning(message('stm:TestForSubsystem:SldvB2BEmcdcModeIgnoredAsNotAnEquivalenceTest'));
        elseif~isSim2ModeSilPil

            warning(message('stm:TestForSubsystem:SldvB2BEmcdcModeIgnoredAsNotSilPil'));
        end
    end
end


