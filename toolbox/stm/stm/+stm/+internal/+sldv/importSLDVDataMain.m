


function[testHarnessName,testFileName,testCaseObj]=importSLDVDataMain(sldvDataInfo,param)

    sldvData=sldvDataInfo.Data;
    sldvDataFilePath=sldvDataInfo.FilePath;

    harnessToDelete=param.harnessToDelete;
    model=param.Model;
    ownerPath=param.ownerPath;

    bFromSTMTopOff=isfield(param,'FromSTMTopOff');
    excelFilePath='';
    if isfield(param,'excelFilePath')
        excelFilePath=param.excelFilePath;
    end

    simIndexToUse=1;
    if bFromSTMTopOff
        simIndexToUse=param.SimulationIndex;
    end

    if isfield(sldvData,'TestCases')
        hasExpOutputs=isfield(sldvData.TestCases,'expectedOutput');
    else
        hasExpOutputs=isfield(sldvData.CounterExamples,'expectedOutput');
    end


    if~param.CreateHarness


        hList=Simulink.harness.find(ownerPath,'Name',param.TestHarnessName,'SearchDepth',0);
        if isempty(hList)
            error(message('Simulink:Harness:TestHarnessNotFound',param.TestHarnessName,ownerPath));
        end
        if~hList.isOpen
            Simulink.harness.load(ownerPath,param.TestHarnessName);
            c=onCleanup(@()sltest.harness.close(get_param(ownerPath,'Handle'),param.TestHarnessName));
        end
        param.TestHarnessSource=hList.origSrc;
    end

    if param.CreateHarness
        if~isempty(harnessToDelete)
            Simulink.harness.delete(harnessToDelete.ownerHandle,harnessToDelete.name);
        end
        sldvshareprivate('create_sltest_harness_using_sldvdata',sldvData,model,...
        ownerPath,param.TestHarnessName,param.TestHarnessSource,param.ExtractedModelPath);
    else
        if strcmp(param.TestHarnessSource,'Inport')
            numInportReq=length(sldvData.AnalysisInformation.InputPortInfo);
            numInportsInHarness=Simulink.harness.internal.getNumRootInports(get_param(model,'Handle'),...
            param.TestHarnessName,...
            get_param(ownerPath,'Handle'));
            if numInportReq~=numInportsInHarness
                error(message('Simulink:Harness:MismatchNumRootInports',...
                param.TestHarnessName,...
                numInportsInHarness,...
                numInportReq));
            end
        elseif strcmp(param.TestHarnessSource,'Signal Builder')||strcmp(param.TestHarnessSource,'Signal Editor')
            isSignalBuilderSrc=strcmp(param.TestHarnessSource,'Signal Builder');
            numOutportReq=stm.internal.sldv.computeNumSignals(sldvData.AnalysisInformation.InputPortInfo,isSignalBuilderSrc);


            if isSignalBuilderSrc




                sigBlk=stm.internal.blocks.SignalBuilderBlock(param.TestHarnessName);
                if isempty(sigBlk.handle)
                    sigBlk=stm.internal.blocks.SignalEditorBlock(param.TestHarnessName);
                    isSignalBuilderSrc=false;
                end
            else
                sigBlk=stm.internal.blocks.SignalEditorBlock(param.TestHarnessName);
            end

            harnessH=get_param(param.TestHarnessName,'Handle');
            sigBlkH=get_param(sigBlk.getHandle(),'Handle');
            if iscell(sigBlkH)
                sigBlkH=cell2mat(sigBlkH);
            end
            if length(sigBlkH)~=1
                error(message('Simulink:Harness:ImportSLDVData_UndefinedSB'));
            end
            numSBOutputs=length(getfield(get_param(sigBlkH,'PortHandles'),'Outport'));
            if numOutportReq~=numSBOutputs
                error(message('Simulink:Harness:ImportSLDVData_SBNumberOutportMismatch',numSBOutputs,numOutportReq));
            end

            fundts=getTimeStep(sldvData.AnalysisInformation.SampleTimes);

            harnessName=param.TestHarnessName;
            appendMode=true;


            stopTime=sldvshareprivate('createSourceBlockSignals',sigBlkH,harnessName,sldvData,fundts,isSignalBuilderSrc,appendMode);


            if~isa(getActiveConfigSet(harnessName),'Simulink.ConfigSetRef')
                stopTime=max(stopTime,str2double(get_param(harnessH,'StopTime')));
                set_param(harnessH,'StopTime',stm.internal.util.SimulinkModel.formatSimTime(stopTime));
            end

            if Simulink.harness.internal.isSavedIndependently(model)
                save_system(param.TestHarnessName);
            end
        else
            error(message('Simulink:Harness:ImportSLDVData_InvalidHarness'));
        end
    end



    fileToUse=which(sldvDataFilePath);
    if isempty(fileToUse)
        fileToUse=sldvDataFilePath;
    end

    hStruct=sltest.harness.find(model,'Name',param.TestHarnessName);
    testHarnessName=param.TestHarnessName;

    if isempty(param.TestCase)




        bNewFileCreated=false;
        if~isfile(param.TestFileName)

            tf=sltest.testmanager.TestFile(param.TestFileName,false);
            ts=tf.getTestSuites;
            testCaseObj=ts.getTestCases;

            if(bFromSTMTopOff)
                if(~strcmp(param.TestType,'baseline'))
                    testCaseObj.remove();
                    testCaseObj=ts.createTestCase(param.TestType);
                end
            end


            if(bFromSTMTopOff)
                try
                    stm.internal.CoverageTopOff.setupCoverageSettings(tf,param.CovResult);
                catch



                    setupCoverageSettings(tf,model,sldvData.AnalysisInformation.Options);
                end
            else
                setupCoverageSettings(tf,model,sldvData.AnalysisInformation.Options);
            end
            bNewFileCreated=true;
        else

            tf=sltest.testmanager.TestFile(param.TestFileName,false);
            ts=tf.createTestSuite;
            testCaseObj=ts.createTestCase;

            if(bFromSTMTopOff)
                if(~strcmp(param.TestType,'baseline'))
                    testCaseObj.remove();
                    testCaseObj=ts.createTestCase(param.TestType);
                end
            end
        end


        stm.internal.setupTestCase(testCaseObj,model,hStruct,fileToUse,simIndexToUse,excelFilePath);

        if hasExpOutputs
            testCaseObj.setProperty('OVERRIDEMODELOUTPUTSETTINGS',true,...
            'SAVEOUTPUT',true);
        end

        if Sldv.DataUtils.isXilSldvData(sldvData)
            testCaseObj.setProperty('SimulationMode','Software-in-the-Loop (SIL)');
        end

        if(bFromSTMTopOff)
            if(bNewFileCreated)
                tf.saveToFile;
            end
        else
            tf.saveToFile;
        end
    else





        testCaseObj=param.TestCase;
        param.TestType=testCaseObj.TestType;


        if~isfield(param,'SimulatonIndex')&&strcmp(param.TestType,'equivalence')
            simIndexToUse=[1,2];
        end
        if isempty(testCaseObj.getIterations)
            stm.internal.CoverageTopOff.addIterationWithActiveSettings(testCaseObj);
        end

        stm.internal.setupTestCase(testCaseObj,model,hStruct,fileToUse,simIndexToUse,excelFilePath);
        if bFromSTMTopOff&&testCaseObj.getProperty('isTestDataReferenced')&&~isempty(testCaseObj.getProperty('TestDataPath'))

            testFileName=testCaseObj.TestFile.FilePath;
            return
        end
        if hasExpOutputs
            testCaseObj.setProperty('OVERRIDEMODELOUTPUTSETTINGS',true,...
            'SAVEOUTPUT',true);
        end



        stm.internal.CoverageTopOff.deActivateTestOverrides(testCaseObj);
    end




    if~strcmp(sldvData.AnalysisInformation.Options.TestgenTarget,'Model')&&...
        ~isfield(sldvData.ModelInformation,'SubsystemPath')
        testCaseObj.setProperty('FastRestart',true);
    end

    testFileName=testCaseObj.TestFile.FilePath;

end

function ts=getTimeStep(sampleTimes)
    ts=sampleTimes(find(sampleTimes,1));
end

function setupCoverageSettings(tf,model,sldvOptions)
    cs=tf.getCoverageSettings;

    cs.RecordCoverage=true;

    cs.MdlRefCoverage=true;

    cs.MetricSettings=get_param(model,'CovMetricSettings');

    objectives=stm.internal.sldv.getModelCovObjectives(sldvOptions.ModelCoverageObjectives);
    cs.MetricSettings=[cs.MetricSettings,objectives];

    if sldvOptions.CovFilter=="on"
        cs.CoverageFilterFilename(end+1)=sldvOptions.CovFilterFileName;
    end
end


