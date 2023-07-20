classdef TestForSubsystem<handle









    properties











        subsys string;
        subModel string;
        topModel string;

        testfileLocation string;
        parentSuiteID;
        testType sltest.testmanager.TestCaseTypes=sltest.testmanager.TestCaseTypes.Baseline;
        shouldThrow logical=true;








        location1="";
        location2="";
        dataLocation="";
        sim1Mode="";
        sim2Mode="";
        isExcel logical=false;

        fcnInterface='';

        createHarness logical=true;

        createForTopModel logical;
        harnessOptions cell={};

        sldvWithSimulation logical=false;

        isUIMode logical=false;
    end

    properties(Constant)




        BlockTypesReqTempHrns="CCaller";
    end

    properties(Dependent=true,SetAccess='private',GetAccess='public')
        subs cell;
    end

    properties(SetAccess='private',GetAccess='public')

        portHandlesToRevert;

        sigHierInfo;

        resetStruct;

        customSigNameMap;
        customSigNameModeMap;

        dataStoreLoggingInfo;

        sigObjToRevert;

        outSigNameMap;

        simOutSaver;
        outputPortMap;

        hasInputs;
        hasBaseline;

        activeScenario;

        isInBatchMode;

        numOfComps;

        MExTracker;

        proceedToNextStep;

        sigNameBlkInfoMap;

        harnessInfo;
        sigObjLoggingNameRevert=[];
    end




    methods
        function init(obj)
            obj.portHandlesToRevert=[];
            obj.sigObjToRevert=[];
            obj.dataStoreLoggingInfo=containers.Map;
            obj.sigHierInfo=containers.Map;
            obj.customSigNameMap=containers.Map('KeyType','double','ValueType','char');
            obj.customSigNameModeMap=containers.Map('KeyType','double','ValueType','char');
            obj.outSigNameMap=containers.Map('KeyType','double','ValueType','char');
            obj.sigNameBlkInfoMap=containers.Map;
        end

        function obj=TestForSubsystem(subsys,topModel,testfileLocation,...
            parentSuiteID,shouldThrow,createForTopModel,harnessOpts)
            obj.init();













            subsys=string(subsys);
            topModel=string(topModel);
            numOfComps=numel(subsys);


            assert(numOfComps>0,"At least one component expected.");
            assert(~xor(createForTopModel,any(topModel==subsys)),"Create for top model setting not as expected.");
            assert(all(subsys~="")&&topModel~="","Empty strings found in Component &/or TopModel input.");


            obj.subsys=subsys;
            obj.createForTopModel=createForTopModel;
            obj.topModel=topModel;
            obj.numOfComps=numOfComps;
            obj.isInBatchMode=numOfComps>1;
            if obj.isInBatchMode
                obj.createHarness=true;
            end
            obj.MExTracker=cell(numOfComps,1);
            obj.proceedToNextStep=true(numOfComps,1);
            obj.testfileLocation=string(testfileLocation);
            obj.parentSuiteID=parentSuiteID;
            obj.shouldThrow=shouldThrow;
            obj.harnessOptions=harnessOpts;
            obj.subModel=bdroot(obj.subsys);
        end
    end




    methods

        function s=get.subs(obj)
            s=get_param(obj.subsys,"Object");
            if~obj.isInBatchMode
                s={s};
            end
        end


        validateMsgPortsNHrnss(obj,isLoggingWorkflow);


        [correspondingSILHarnessCodePaths,sim2ModeToUse,silHarnessNames,preserve_dirty]=createSILPILHarnessesIfNeeded(obj,options);


        testCaseId=createUsingSLDV(obj,harnessSource,recordOutputs,excelFilePath,sldvBackToBackMode,correspondingSILHarnessCodePath);


        testCaseId=create(obj,hrnsSrcType);


        testCaseId=createHarnessOnly(obj,harnessSource);


        [result,status]=configureTestCasesAndBuildResultsArray(obj,testCaseId,silHarnessNames,sim2ModeToUse,options);

    end

    methods(Access=private)

        outputData=simulateModel(obj,subModel);


        resolveFilePaths(obj,testfileFolder,createDirForExcel);
        resolveFilePathsForBatch(obj);


        [dataLoggingName,wasAlreadyLoggedByUs]=setTempLoggingNames(obj,sigHdl,indx,tmpName,cutIndex);


        msg=setInputTempLoggingNames(obj,sigObjs,portType);
        setOutputTempLoggingNames(obj,sigHdls,tmpName);


        errSig=setDSMTempLogging(obj,dsmInfo,cutInd);


        revertSigNamesAndLogging(obj,subModel);



        outputData=flattenSaveSimOut(obj,outputData,updateScenario);


        setHarnessOutportNames(obj,harnessName);


        [outputData,blkPortHdls]=logComponentIO(obj);



        cacheBlkStructInMap(obj,dataLoggingName,datasetType,portType,gotoname,inputBlkName,options);


        isTopModel=isComponentTopModel(obj,comp);



        abortIfNoRemainingCUT(obj);


        populateErrorContainer(obj,mExObject,compIndex);

        cacheDsmConnectivityInfo(obj,dStoreLoggingName,dsmBlkUserType,cutInd,dataStoreName);
    end

    methods(Static)

        [subModel,topModel,subs]=validateSupportedSpecsForSubsystem(subsys,topModelName,parentSuiteID,createForTopModel);
        validateSupportedSpecsForSubsystemHelper(subModel,createForTopModel,recordCurrentState,subsysH,topModel);



        [subModel,topModel]=getSubsystemInfo(subsys,topModel);



        dsmInfo=getDSMInfo(blockH);



        [useTempHrnsForTestGen,hasEnhancedMCDCEnabled]=checkSldvCompatibility(subsystem,topModel,fcnInterfaceName,createForTopModel);


        closeAndDeleteHarness(subsys,hrnsName);


        fcnIntList=getFunctionInterfaces(libModel,subsys);


        obj=createTestFile(filepath);


        srcPortHandle=returnSourceBlockOutportHandle(blkPortHdl);


        subsys=constructFullSSPath(subsys,topModel);


        function publishSpinnerText(str)
            virtualChannel='TestForSubsystem/Generate/Progress';
            payload=[str,message('stm:general:WaitForCompletion').getString()];
            payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',payload);
            message.publish('/stm/messaging',payloadStruct);
        end


        function publishWarning(warningID,shouldThrow,varargin)

            if nargin>2
                warningStr=getString(message(warningID,varargin{1}));
            else
                warningStr=message(warningID).getString();
            end

            if(shouldThrow)
                warning(warningID,warningStr);
            else
                virtualChannel='TestForSubsystem/Generate/Warning';
                payload=warningStr;
                payloadStruct=struct('VirtualChannel',virtualChannel,'Payload',payload);
                message.publish('/stm/messaging',payloadStruct);
            end
        end

        cutName=getComponentName(fullPath);


        tree=getModelHierarchy(rootLevelBD);

        res=findAllUserDefinedFcnBlks(hndl);
        res=findAllSubsysBlks(hndl);
        res=findAllModelBlks(hndl);
        res=findAllSFBlks(hndl);



        selectedBlks=findAllCurrentlySelectedBlksOfMdlHierarchy(topMdl);


        [comps,isInBatchMode]=validateAndConvertSubsystemInputToStrings(subsys,isInUIMode);
        throwInvSimulinkObjError(invalidInds);
        throwInvBlkErrorForUI(invalidBlockPaths);
        [topModel,createForTopModel]=validateTopModelInput(topModel,unparsedSubsys,isInBatchMode,subsys);
        validateSimulinkObjsAndMRHierarchy(topModel,subsys,isInUIMode);
        validateWizardCUTStepInput(components,topModelName,isInBatchMode)



        rpt=createReport(topModel,testfileLocation,result,subsys,status);


        ans=isTopModelLibrary(mdl);

    end
end


