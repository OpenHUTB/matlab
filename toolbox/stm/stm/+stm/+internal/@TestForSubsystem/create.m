function testCaseId=create(obj,harnessSrcType)


















    import stm.internal.TestForSubsystem.publishSpinnerText;
    import stm.internal.TestForSubsystem.publishWarning;
    subs=obj.subs;





    componentName=string(cellfun(@(x)x.getFullName,subs,'UniformOutput',false));



    [outputData,blkPortHdls]=obj.logComponentIO;


    preserve_dirty=arrayfun(@(x)Simulink.PreserveDirtyFlag(get_param(x,'Handle'),'blockDiagram'),obj.subModel);%#ok<NASGU>


    publishSpinnerText(message('stm:general:CreatingHarnessForSubsystemBaseline').getString());


    for i=1:obj.numOfComps
        if obj.proceedToNextStep(i)&&get_param(subs{i}.handle,"Type")~="block_diagram"&&obj.testType==sltest.testmanager.TestCaseTypes.Baseline
            sampleTimes=get_param(subs{i}.handle,'CompiledSampleTime');
            if iscell(sampleTimes)
                sampleTime=sampleTimes{1};
            else
                sampleTime=sampleTimes;
            end
            if sampleTime(1)==0
                publishWarning('stm:general:WarningContinuousTimeForTestFromSubsystem',obj.shouldThrow);
                break;
            end
        end
    end


    if obj.createHarness


        wrnIDs="Simulink:Harness:InvalidParamValueForImplicitLink";
        warning('off',wrnIDs);

        clnObj=onCleanup(@()warning('on',wrnIDs));





        [obj,harnessInfo,harnessName]=createAndConfigureHarness(obj,subs,harnessSrcType);


        subs=obj.subs;
    else
        harnessName="";
        harnessInfo={[]};
    end
    clear preserve_dirty;



    obj.abortIfNoRemainingCUT();



    publishSpinnerText(message('stm:general:StoringLoggedSignals').getString());




    obj.harnessInfo=harnessInfo;
    obj.simOutSaver=cellfun(@(x,y)stm.internal.SimOutSaveHelper(~obj.isExcel,x,obj.isComponentTopModel(y.handle),obj.topModel.char),harnessInfo,subs,'UniformOutput',true);


    try
        updateSignalEditorScenarioInHarness=true;
        emptySigs=obj.flattenSaveSimOut(outputData,updateSignalEditorScenarioInHarness);
    catch ME
        assert(~obj.isInBatchMode,"Simulation output flattening threw in Batch mode.");
        obj.populateErrorContainer(ME,1);
    end

    if~isempty(emptySigs)
        publishWarning('stm:TestForSubsystem:WarningEmptySignalsFoundInTestForSubsystem',obj.shouldThrow,emptySigs.join(', '));
    end


    obj.abortIfNoRemainingCUT();



    publishSpinnerText(message('stm:general:CreatingNewTestCaseForSubsystemBaseline').getString());






    testCaseId=zeros(obj.numOfComps,1);
    for i=1:obj.numOfComps
        try


            if obj.proceedToNextStep(i)
                inpInfo=obj.location1(i);
                if obj.activeScenario(i)~=""
                    inpInfo=obj.activeScenario(i);
                end
                testCaseId(i)=stm.internal.createTestFromSubsystem(...
                obj.parentSuiteID,...
                obj.subModel(i),...
                componentName(i),...
                harnessName(i),...
                inpInfo,...
                obj.location2(i),...
                int32(obj.testType),...
                obj.isExcel,...
                obj.hasInputs(i),...
                obj.hasBaseline(i),...
                obj.isInBatchMode);
            end
        catch me
            obj.populateErrorContainer(me,i);
        end
    end

    function locAddSignalToLoggedDataSet(sigSet,portH)
        parentBlk=get_param(portH,'Parent');
        parentPortNum=get_param(portH,'PortNumber');
        sigSet.addLoggedSignal(parentBlk,parentPortNum);
    end

    if~obj.createHarness&&obj.testType==sltest.testmanager.TestCaseTypes.Baseline
        assert(~obj.isInBatchMode,"Expected this to be hit only in non batch mode.");
        assert(obj.createForTopModel);





        tcObj=sltest.testmanager.TestCase([],testCaseId);
        sigSet=tcObj.addLoggedSignalSet('Name','RootOutputs');
        arrayfun(@(portH)locAddSignalToLoggedDataSet(sigSet,portH),blkPortHdls.OutputDriverPortHandles);

    end

end

function[obj,allHarnessInfo,harnessName]=createAndConfigureHarness(obj,subs,harnessSrcType)
    schedulerOptions={'DriveFcnCallWithTestSequence',false};
    for k=1:obj.numOfComps
        if Simulink.SubsystemType.isBlockDiagram(subs{k}.handle)&&strcmp(get_param(subs{k}.handle,'IsExportFunctionModel'),'on')
            schedulerOptions={'SchedulerBlock','Test Sequence'};
            break;
        end
    end










    origStatus=obj.proceedToNextStep;
    subsysToCreateHrnssFor=obj.subsys(origStatus);
    [harnessInfo,harnessCreationSuccess]=Simulink.harness.internal.createMultipleHarnesses(subsysToCreateHrnssFor,...
    obj.topModel,'Source',harnessSrcType,schedulerOptions{:});


    harnessName=strings(obj.numOfComps,1);
    allHarnessInfo=cell(obj.numOfComps,1);
    j=0;
    for i=1:obj.numOfComps
        if origStatus(i)
            j=j+1;
            subs{i}=get_param(obj.subsys(i),"Object");
            if harnessCreationSuccess(j)
                harnessName(i)=harnessInfo{j}.name;
                Simulink.harness.load(subs{i}.handle,harnessName(i));
                if obj.testType==sltest.testmanager.TestCaseTypes.Baseline
                    obj.setHarnessOutportNames(harnessName(i));
                end
                if~isa(getActiveConfigSet(harnessName(i)),'Simulink.ConfigSetRef')
                    set_param(harnessName(i),'SaveFormat','DataSet');
                    set_param(harnessName(i),'SignalLogging','on');
                end
                allHarnessInfo{i}=Simulink.harness.find(subs{i}.handle,"Name",harnessName(i));
                if allHarnessInfo{i}.saveExternally
                    save_system(harnessName(i));
                end
                close_system(harnessName(i),0);
            else
                obj.populateErrorContainer(harnessInfo{j},i);
            end
        end
    end
end

