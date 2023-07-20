




classdef ModelChecker<handle
    properties(SetAccess=private)
m_sys
m_DUT
m_Checks
m_is_nontop_dut
m_Latencies
    end

    properties(Constant)
        borrowedChecks=hdlcoder.ModelChecker.hdlBorrowedChecks;
    end

    methods(Static,Access=public)
        function obj=hdlBorrowedChecks()






            obj=containers.Map('KeyType','char','ValueType','char');
            obj('borrowed_runUnconnectedLinesPorts')='mathworks.design.UnconnectedLinesPorts';
            obj('borrowed_runDisabledLibLinks')='mathworks.design.DisabledLibLinks';
            obj('borrowed_runUnresolvedLibLinks')='mathworks.design.UnresolvedLibLinks';
            obj('borrowed_runMismatchedBusParams')='mathworks.design.MismatchedBusParams';
            obj('borrowed_runReplaceZOHDelayByRTB')='mathworks.design.ReplaceZOHDelayByRTB';
            obj('borrowed_runOutputSignalSampleTime')='mathworks.design.OutputSignalSampleTime';
        end


        [reqLatency,minLat,maxLat,flag,msg]=getRequiredLatency(block,globalLatencyStrategy,targetConfigNFP);
    end


    methods(Static,Access=public)
        function rval=Advisor(varargin)
            persistent m_Advisor
            if isempty(m_Advisor)
                m_Advisor=[];
            end
            if nargin>=1
                m_Advisor=varargin{1};
            end
            rval=m_Advisor;
            return
        end

        function setAdvisor(adv)
            hdlcoder.ModelChecker.Advisor(adv);
            return;
        end

        function adv=getAdvisor()
            adv=hdlcoder.ModelChecker.Advisor();
            return;
        end


        function[org,classpath,group_order,fixme]=getOrganization()
            fixme=containers.Map();
            org=containers.Map();
            classpath=containers.Map();
            classpath('default')='hdlcoder.ModelChecker';









            group_order={
            'Block_Level_Checks',...
            'IndustryStandards_Checks',...
            'Model_Level_Checks',...
            'NativeFloatingPoint_Checks',...
            'Subsystem_Level_Checks'};



            org('Model_Level_Checks')={
            'runBalanceDelaysChecks',...
            'runGlobalResetChecks',...
            'runInlineConfigurationsChecks',...
            'runModelParamsChecks',...
            'runVisualizationChecks',...
            'runAlgebraicLoopChecks'};

            org('Subsystem_Level_Checks')={
            'runInvalidDUTChecks'};

            org('Block_Level_Checks')={
            'runBlockSupportChecks',...
            'runHDLRecipChecks',...
            'runMLFcnBlkChecks',...
            'runObsoleteDelaysChecks',...
            'runSampleTimeChecks',...
            'runSignalObjectStorageClassChecks',...
            'runStateflowChartSettingsChecks',...
            'runUnsupportedLUTTrigFunChecks',...
            'runMatrixSizesChecks',...
            'runNFPLatencyChecks',...
            'borrowed_runDisabledLibLinks',...
            'borrowed_runReplaceZOHDelayByRTB',...
            'borrowed_runUnconnectedLinesPorts',...
            'borrowed_runUnresolvedLibLinks'};





            org('NativeFloatingPoint_Checks')={
            'runDoubleDatatypeChecks',...
            'runNFPDTCChecks',...
            'runNFPHDLRecipChecks',...
            'runNFPRelopChecks',...
            'runNFPSuggestionChecks',...
            'runNFPSupportedBlocksChecks',...
            'runNFPULPErrorChecks'};

            org('IndustryStandards_Checks')={
            'runArchitectureNameChecks',...
            'runClockChecks',...
            'runClockResetEnableChecks',...
            'runFileExtensionChecks',...
            'runGenericChecks',...
            'runNameConventionChecks',...
            'runPackageNameChecks',...
            'runPortSignalNameChecks',...
            'runSplitEntityArchitectureChecks',...
            'runSubsystemNameChecks',...
            'runToplevelNameChecks'};



            fixme('runMLFcnBlkChecks')=@hdlcoder.ModelChecker.fixmeMLFcnBlkChecks;
            fixme('runStateflowChartSettingsChecks')=@hdlcoder.ModelChecker.fixmeStateflowChartSettingsChecks;
            fixme('runModelParamsChecks')=@hdlcoder.ModelChecker.fixmeModelParamsChecks;
            fixme('runGlobalResetChecks')=@hdlcoder.ModelChecker.fixmeGlobalResetChecks;
            fixme('runInlineConfigurationsChecks')=@hdlcoder.ModelChecker.fixmeInlineConfigurationsChecks;
            fixme('runVisualizationChecks')=@hdlcoder.ModelChecker.fixmeVisualizationChecks;
            fixme('runSampleTimeChecks')=@hdlcoder.ModelChecker.fixmeSampleTimeChecks;
            fixme('runNFPSuggestionChecks')=@hdlcoder.ModelChecker.fixmeNFPSuggestionChecks;
            fixme('runFileExtensionChecks')=@hdlcoder.ModelChecker.fixmeFileExtensionChecks;
            fixme('runNameConventionChecks')=@hdlcoder.ModelChecker.fixmeNameConventionChecks;
            fixme('runToplevelNameChecks')=@hdlcoder.ModelChecker.fixmeToplevelNameChecks;
            fixme('runSubsystemNameChecks')=@hdlcoder.ModelChecker.fixmeSubsystemNameChecks;
            fixme('runPortSignalNameChecks')=@hdlcoder.ModelChecker.fixmePortSignalNameChecks;
            fixme('runPackageNameChecks')=@hdlcoder.ModelChecker.fixmePackageNameChecks;
            fixme('runGenericChecks')=@hdlcoder.ModelChecker.fixmeGenericChecks;
            fixme('runClockResetEnableChecks')=@hdlcoder.ModelChecker.fixmeClockResetEnableChecks;
            fixme('runArchitectureNameChecks')=@hdlcoder.ModelChecker.fixmeArchitectureNameChecks;
            fixme('runSplitEntityArchitectureChecks')=@hdlcoder.ModelChecker.fixmeSplitEntityArchitectureChecks;
            fixme('runClockChecks')=@hdlcoder.ModelChecker.fixmeClockChecks;
            fixme('runBalanceDelaysChecks')=@hdlcoder.ModelChecker.fixmeBalanceDelaysChecks;
            fixme('runNFPDTCChecks')=@hdlcoder.ModelChecker.fixmeNFPDTCChecks;
            fixme('runNFPHDLRecipChecks')=@hdlcoder.ModelChecker.fixmeNFPHDLRecipChecks;
            fixme('runNFPRelopChecks')=@hdlcoder.ModelChecker.fixmeNFPRelopChecks;
            fixme('runObsoleteDelaysChecks')=@hdlcoder.ModelChecker.fixmeObsoleteDelaysChecks;
            fixme('runSignalObjectStorageClassChecks')=@hdlcoder.ModelChecker.fixmeSignalObjectStorageClassChecks;
            fixme('runHDLRecipChecks')=@hdlcoder.ModelChecker.fixmeHDLRecipChecks;




            assert(isequal(sort(group_order),sort(org.keys)))


















        end

        function reg_tasks=registerTaskAdvisor()
            reg_tasks={};

            mdladvRoot=ModelAdvisor.Root;%#ok<NASGU>

            TAN=ModelAdvisor.Group('com.mathworks.HDL.ModelChecker');
            TAN.DisplayName=DAStudio.message('HDLShared:hdlmodelchecker:cat_Model_Checker');
            TAN.Description=DAStudio.message('HDLShared:hdlmodelchecker:desc_Model_Checker');
            parent_TAN=TAN;
            reg_tasks{end+1}=TAN;

            [org,~,group_names]=hdlcoder.ModelChecker.getOrganization();
            for key_idx=1:length(group_names)
                group_name=group_names{key_idx};

                group_TAN=ModelAdvisor.Group(['com.mathworks.HDL.ModelChecker.Group_',group_name]);
                group_TAN.CSHParameters.MapKey='hdlmodelchecker';
                group_TAN.CSHParameters.TopicID=group_TAN.ID;
                try
                    group_TAN.DisplayName=DAStudio.message(['HDLShared:hdlmodelchecker:cat_',group_name]);
                    group_TAN.Description=DAStudio.message(['HDLShared:hdlmodelchecker:desc_',group_name]);
                catch mEx %#ok<NASGU>
                    group_TAN.DisplayName=group_name;
                    group_TAN.Description=group_name;
                end
                addGroup(parent_TAN,group_TAN);
                reg_tasks{end+1}=group_TAN;%#ok<AGROW>

                check_desc=org(group_name);
                for chk_idx=1:length(check_desc)

                    check_name=check_desc{chk_idx};
                    task_ID=['com.mathworks.HDL.ModelChecker.',check_name];
                    TAN=ModelAdvisor.Task(task_ID);
                    try



                        TAN.DisplayName=DAStudio.message(['HDLShared:hdlmodelchecker:',check_name]);
                        TAN.Description=DAStudio.message(['HDLShared:hdlmodelchecker:desc_',check_name]);
                    catch mEx %#ok<NASGU>
                        if~contains(check_name,'borrowed')
                            TAN.DisplayName=['*FIXME* ',check_name];
                            TAN.Description=['*FIXME* ',check_name];
                        end
                    end
                    TAN.MAC=task_ID;

                    if contains(check_name,'borrowed')
                        if~isKey(hdlcoder.ModelChecker.borrowedChecks,check_name)

                            TAN.DisplayName=['*FIXME* ',check_name];
                        else
                            TAN.MAC=hdlcoder.ModelChecker.borrowedChecks(check_name);
                        end
                    end
                    TAN.EnableReset=true;
                    TAN.Selected=true;
                    TAN.Value=true;
                    addTask(group_TAN,TAN);
                    reg_tasks{end+1}=TAN;%#ok<AGROW>
                end
            end
        end


        function reg_checks=registerCheck_ModelAdvisor()
            reg_checks=hdlcoder.ModelChecker.registerCheckAdvisor('modeladvisor');
        end


        function reg_checks=registerCheck_ModelChecker()
            reg_checks=hdlcoder.ModelChecker.registerCheckAdvisor('modelchecker');
        end


        function reg_checks=registerCheckAdvisor(mode)
            narginchk(1,1);
            reg_checks={};
            inModelCheckerMode=strcmpi(mode,'modelchecker');
            if inModelCheckerMode
                Tag='com.mathworks.HDL.ModelChecker';
            else
                Tag='com.mathworks.HDL.ModelAdvisor';
            end

            mdladvRoot=ModelAdvisor.Root;

            [org,classpath,~,fixme]=hdlcoder.ModelChecker.getOrganization();
            group_names=sort(org.keys);
            for key_idx=1:length(group_names)
                group_name=group_names{key_idx};
                check_desc=org(group_name);
                if classpath.isKey(group_name)
                    class_name=classpath(group_name);
                else
                    class_name=classpath('default');
                end
                for chk_idx=1:length(check_desc)

                    check_name=check_desc{chk_idx};
                    rec=ModelAdvisor.Check([Tag,'.',check_name]);
                    try
                        rec.Title=DAStudio.message(['HDLShared:hdlmodelchecker:',check_name]);
                    catch mEx %#ok<NASGU>
                        rec.Title=['*FIXME* ',check_name];
                    end
                    rec.TitleTips=rec.Title;

                    rec.CallbackHandle=str2func(['@',class_name,'.',check_name]);



                    if strcmp(check_name,'runNFPSuggestionChecks')||strcmp(check_name,'runDoubleDatatypeChecks')||...
                        strcmp(check_name,'runAlgebraicLoopChecks')||strcmp(check_name,'runNFPDTCChecks')||...
                        strcmp(check_name,'runNFPHDLRecipChecks')||strcmp(check_name,'runNFPRelopChecks')||...
                        strcmp(check_name,'runNFPSupportedBlocksChecks')||strcmp(check_name,'runMatrixSizesChecks')||...
                        strcmp(check_name,'runNFPLatencyChecks')||strcmp(check_name,'runNFPULPErrorChecks')
                        rec.CallbackContext='PostCompile';
                        rec.Value=false;
                    else
                        rec.CallbackContext='None';
                        rec.Value=true;
                    end
                    rec.CallbackStyle='StyleThree';
                    rec.SupportExclusion=true;
                    rec.LicenseName={'Simulink_HDL_Coder'};
                    rec.CSHParameters.MapKey='hdlmodelchecker';
                    rec.CSHParameters.TopicID=rec.ID;


                    if isKey(fixme,check_name)
                        check_fixme_fcn=fixme(check_name);
                        modifyAction=ModelAdvisor.Action();
                        modifyAction.setCallbackFcn(check_fixme_fcn);
                        modifyAction.Name=DAStudio.message('HDLShared:hdlmodelchecker:fix_runStandardName');
                        try
                            modifyAction.Description=DAStudio.message(['HDLShared:hdlmodelchecker:fix_',check_name]);
                        catch mEx %#ok<NASGU>
                            modifyAction.Description=DAStudio.message('HDLShared:hdlmodelchecker:fix_runStandardChecks');
                        end
                        modifyAction.Enable=false;
                        setAction(rec,modifyAction);
                    end

                    if inModelCheckerMode
                        reg_checks{end+1}=rec;%#ok<AGROW>
                    else



                        if~contains(check_name,'borrowed')

                            group_name_desc=DAStudio.message(['HDLShared:hdlmodelchecker:cat_',group_name]);
                            mdladvRoot.publish(rec,['HDL Coder|',group_name_desc]);
                        end

                    end
                end
            end
        end
    end


    methods(Static,Access=public)
        checker=getModelChecker(mdlTaskObj,ruleName)

        systems=find_system_MAWrapper(system,varargin);
        repBlks=replace_block_MAWrapper(blockToBeReplaced,replacementBlockType);
        isFloat=port_is_type_MAWrapper(block,IO,portNumber,isTypeFcnHandle)

        candidatePorts=nonzeroEnTrigInitConPorts(sys)
        modelParams=hdlModelParameters()
        candidateBlks=getInfSampleTimeSrcs(sys)
        candidateBlks=getContinuousSampleTimeSrcs(sys)
        candidateBlks=getSrcs(sys,sampleTimeStr)
        ResultDescription=setSampleTime(sampleTimeStr,candidateBlks)
        [candidateBlks,candidateSignals]=getInvalidNames(dut)
        [candidateDUT,candidatePorts]=getInvalidPortAndDutNames(dut)
        [dataType,outDataType]=getNFPBlockDataType(subsystemName,blockHandle)
        type=getNFPBlockTypeBySlType(slOpType)
        msg=addNFPLatencyDelay(subsystemName,srcBlkHandle,latency)
        candidateBlks=getInvalidSubsystemNames(sys)
        [candidatePorts,candidateSignals]=getInvalidPortSignalNames(sys)
        candidateSignals=getInvalidSignalObjectStorageClass(sys)
    end

    methods(Static,Access=public)

        function TAG=getRefTagForModelAdvisorOrCheckerFlow(mdlAdvObj)
            refObj=hdlcoder.ModelChecker.getAdvisor();
            if isequal(mdlAdvObj,refObj)
                TAG='com.mathworks.HDL.ModelChecker';
            else
                TAG='com.mathworks.HDL.ModelAdvisor';
            end
        end


        function ResultDescription=fixmeForModelRule(varargin)
            disp('This is a fixme function');
            ResultDescription='OK';
        end


        ResultDescription=fixmeMLFcnBlkChecks(mdlTaskObj)

        ResultDescription=fixmeEnTrigInitConChecks(mdlTaskObj)

        ResultDescription=fixmeModelParamsChecks(mdlTaskObj)

        ResultDescription=fixmeGlobalResetChecks(mdlTaskObj)

        ResultDescription=fixmeInlineConfigurationsChecks(mdlTaskObj)

        ResultDescription=fixmeVisualizationChecks(mdlTaskObj)

        ResultDescription=fixmeSampleTimeChecks(mdlTaskObj)

        ResultDescription=fixmeStateflowChartSettingsChecks(mdlTaskObj)

        ResultDescription=fixmeNFPSuggestionChecks(mdlTaskObj)

        ResultDescription=fixmeFileExtensionChecks(mdlTaskObj)

        ResultDescription=fixmeNameConventionChecks(mdlTaskObj)

        ResultDescription=fixmeToplevelNameChecks(mdlTaskObj)

        ResultDescription=fixmeSubsystemNameChecks(mdlTaskObj)

        ResultDescription=fixmePortSignalNameChecks(mdlTaskObj)

        ResultDescription=fixmeSignalObjectStorageClassChecks(mdlTaskObj)

        ResultDescription=fixmePackageNameChecks(mdlTaskObj)

        ResultDescription=fixmeGenericChecks(mdlTaskObj)

        ResultDescription=fixmeClockResetEnableChecks(mdlTaskObj)

        ResultDescription=fixmeArchitectureNameChecks(mdlTaskObj)

        ResultDescription=fixmeSplitEntityArchitectureChecks(mdlTaskObj)

        ResultDescription=fixmeClockChecks(mdlTaskObj)

        ResultDescription=fixmeBalanceDelaysChecks(mdlTaskObj)

        ResultDescription=fixmeNFPDTCChecks(mdlTaskObj)

        ResultDescription=fixmeNFPHDLRecipChecks(mdlTaskObj)

        ResultDescription=fixmeNFPRelopChecks(mdlTaskObj)

        ResultDescription=fixmeObsoleteDelaysChecks(mdlTaskObj)


        ResultDescription=fixmeNFPLatencyChecks(mdlTaskObj)

        ResultDescription=fixmeHDLRecipChecks(mdlTaskObj)
    end



    methods(Static,Access=public)

        function[ResultDescription,ResultDetails]=doCheckHelper(DUT,method_name,varargin)
            narginchk(2,inf);

            checker=hdlcoder.ModelChecker(DUT);
            [ResultDescription,ResultDetails,status]=checker.doCheckInvocationHelper(DUT,method_name);
            if(~status)

                refObj=hdlcoder.ModelChecker.getAdvisor();
                mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(DUT);

                if isempty(mdlAdvObj.UserData)
                    mdlAdvObj.UserData=containers.Map();
                end


                if isequal(mdlAdvObj,refObj)
                    TAG='com.mathworks.HDL.ModelChecker';
                else
                    TAG='com.mathworks.HDL.ModelAdvisor';
                end
                fcnStack=dbstack();
                ruleName=strsplit(fcnStack(2).name,'.');
                fullyQualifiedCheckName=[TAG,'.',ruleName{end}];
                partiallyQualifiedCheckName=ruleName{end};
                chk=mdlAdvObj.getCheckObj(fullyQualifiedCheckName);
                if(~isempty(chk.Action))
                    chk.Action.Enable=true;
                    mdlAdvObj.UserData(partiallyQualifiedCheckName)={checker,fullyQualifiedCheckName};
                end
            end
        end



        function[ResultDescription,ResultDetails]=runModelParamsChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkModelParams');
        end


        function[ResultDescription,ResultDetails]=runInvalidDUTChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkInvalidDUT');
        end


        function[ResultDescription,ResultDetails]=runMLFcnBlkChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkMLFcnBlk');
        end


        function[ResultDescription,ResultDetails]=runBlockSupportChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkBlockSupport');
        end


        function[ResultDescription,ResultDetails]=runHDLRecipChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkHDLRecip');
        end


        function[ResultDescription,ResultDetails]=runUnsupportedLUTTrigFunChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkUnsupportedLUTTrigFun');
        end


        function[ResultDescription,ResultDetails]=runSampleTimeChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkSampleTime');

        end


        function[ResultDescription,ResultDetails]=runInitialConditionsChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkInitialConditions');
        end


        function[ResultDescription,ResultDetails]=runEmbeddedSourcesChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkEmbeddedSources');
        end


        function[ResultDescription,ResultDetails]=runMathOperationsChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkMathOperations');
        end


        function[ResultDescription,ResultDetails]=runResourceSharingChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkResourceSharing');
        end


        function[ResultDescription,ResultDetails]=runDelayBalancingChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkDelayBalancing');
        end


        function[ResultDescription,ResultDetails]=runStateflowChartSettingsChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkStateflowChartSettings');
        end

        function[ResultDescription,ResultDetails]=runStateflowAtomicSubchartChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkStateflowAtomicSubchart');
        end



        function[ResultDescription,ResultDetails]=runDistributedPipeliningChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkDistributedPipelining');
        end


        function[ResultDescription,ResultDetails]=runMATLABPersistentVariablesChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkMATLABPersistentVariables');
        end


        function[ResultDescription,ResultDetails]=runGlobalResetChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkGlobalReset');
        end


        function[ResultDescription,ResultDetails]=runInlineConfigurationsChecks(DUT)
            [ResultDescription,ResultDetails]=...
            hdlcoder.ModelChecker.doCheckHelper(DUT,'checkInlineConfigurations');
        end


        function[ResultDescription,ResultDetails]=runAlgebraicLoopChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkAlgebraicLoop');
        end


        function[ResultDescription,ResultDetails]=runVisualizationChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkVisualization');
        end


        function[ResultDescription,ResultDetails]=runBalanceDelaysChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkBalanceDelays');
        end


        function[ResultDescription,ResultDetails]=runDoubleDatatypeChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkDoubleDatatype');
        end



        function[ResultDescription,ResultDetails]=runNFPSuggestionChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPSuggestion');
        end



        function[ResultDescription,ResultDetails]=runNFPDTCChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPDTC');
        end


        function[ResultDescription,ResultDetails]=runNFPHDLRecipChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPHDLRecip');
        end


        function[ResultDescription,ResultDetails]=runNFPRelopChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPRelop');
        end


        function[ResultDescription,ResultDetails]=runNFPSupportedBlocksChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPSupportedBlocks');
        end


        function[ResultDescription,ResultDetails]=runNFPLatencyChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPLatency');
        end


        function[ResultDescription,ResultDetails]=runNFPULPErrorChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNFPULPError');
        end


        function[ResultDescription,ResultDetails]=runFileExtensionChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkFileExtension');
        end


        function[ResultDescription,ResultDetails]=runNameConventionChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkNameConvention');
        end


        function[ResultDescription,ResultDetails]=runToplevelNameChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkToplevelName');
        end


        function[ResultDescription,ResultDetails]=runSubsystemNameChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkSubsystemName');
        end


        function[ResultDescription,ResultDetails]=runPortSignalNameChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkPortSignalName');
        end


        function[ResultDescription,ResultDetails]=runPackageNameChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkPackageName');
        end


        function[ResultDescription,ResultDetails]=runGenericChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkGeneric');
        end


        function[ResultDescription,ResultDetails]=runClockResetEnableChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkClockResetEnable');
        end


        function[ResultDescription,ResultDetails]=runArchitectureNameChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkArchitectureName');
        end


        function[ResultDescription,ResultDetails]=runSplitEntityArchitectureChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkSplitEntityArchitecture');
        end


        function[ResultDescription,ResultDetails]=runClockChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkClock');
        end

        function[ResultDescription,ResultDetails]=runMatrixSizesChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkMatrixSizes');
        end


        function[ResultDescription,ResultDetails]=runObsoleteDelaysChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkObsoleteDelays');
        end


        function[ResultDescription,ResultDetails]=runSignalObjectStorageClassChecks(DUT)
            [ResultDescription,ResultDetails]=hdlcoder.ModelChecker.doCheckHelper(DUT,'checkSignalObjectStorageClass');
        end
    end

    methods

        function this=ModelChecker(DUT)
            while(DUT(end)=='/')
                DUT=DUT(1:end-1);
            end

            parts=strsplit(DUT,'/');
            this.m_sys=parts{1};
            this.m_DUT=DUT;
            this.m_Checks=[];





            hdlcc=gethdlcc(this.m_sys);
            if isempty(hdlcc)
                attachhdlcconfig(this.m_sys);
            end

            this.m_Latencies=[];
            top_level_DUT=all(cellfun(@length,parts))&&length(parts)<=2;
            this.m_is_nontop_dut=~top_level_DUT;
        end

        function[ResultDescription,ResultDetails,status]=doCheckInvocationHelper(obj,DUT,method_name)

            ResultDescription={};
            ResultDetails={};


            if~ismethod(obj,method_name)
                warning('Callback function %s was not found in the object',method_name,class(obj));
            end

            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(DUT);
            flag=obj.(method_name)();
            checks=obj.m_Checks;


            function publish_msgs_for_severity(severity)



                msg_cell=cell(1,length(checks));

                if checks(1).mult_subchecks
                    for i=1:length(checks)
                        msg_cell{i}=checks(i).message;
                    end
                    msg_cell_unique=unique(msg_cell);
                    for i=1:length(msg_cell_unique)


                        topList=ModelAdvisor.List();
                        topList.setType('bulleted');
                        for itr=1:length(checks)
                            if strcmp(checks(itr).message,msg_cell_unique{i})
                                if~strcmpi(checks(itr).level,severity)
                                    continue;
                                end
                                txtObjAndLink=ModelAdvisor.Text(checks(itr).block);
                                as_numeric_string=['char([',num2str(checks(itr).block+0),'])'];
                                txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
                                topList.addItem(txtObjAndLink);
                            end
                        end
                        if~isempty(topList.Items)
                            warning_text=ModelAdvisor.Text(severity,[statusStr,{'Bold'}]);
                            ResultDescription{end+1}=...
                            [ModelAdvisor.Text([warning_text.emitHTML,' : ',msg_cell_unique{i}]),topList];%#ok<AGROW>
                            ResultDetails{end+1}='';%#ok<AGROW>
                        end
                    end
                else

                    topList=ModelAdvisor.List();
                    topList.setType('bulleted');
                    for itr=1:length(checks)
                        if~strcmpi(checks(itr).level,severity)
                            continue;
                        end
                        txtObjAndLink=ModelAdvisor.Text(checks(itr).block);
                        as_numeric_string=['char([',num2str(checks(itr).block+0),'])'];
                        txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
                        if isfield(checks,'message')&&~isempty(checks(1).message)
                            ma_spc=ModelAdvisor.Text(' ');
                            ma_msg_title=ModelAdvisor.Text(checks(itr).message);
                            topList.addItem([ma_spc,ma_msg_title,ma_spc,txtObjAndLink]);
                        else
                            topList.addItem(txtObjAndLink);
                        end
                    end
                    if~isempty(topList.Items)
                        warning_text=ModelAdvisor.Text(severity,[statusStr,{'Bold'}]);
                        ResultDescription{end+1}=[ModelAdvisor.Text([warning_text.emitHTML,' : ',checks(itr).summary]),topList];
                        ResultDetails{end+1}='';
                    end
                end
            end



            if(isempty(checks))

                status=true;
                Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass','Bold'});
                statusText=Passed.emitHTML;
                statusStr={'Pass'};
            else

                status=false;
                Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGWarning'),{'Warn'});
                statusText=Failed.emitHTML;
                statusStr={'Warn'};

                publish_msgs_for_severity('Message');
                publish_msgs_for_severity('Warning');
                publish_msgs_for_severity('Error');
            end

            if strcmp(method_name,'checkNFPLatency')
                status=flag;
            else

                assert(isequal(flag,status))
            end


            check_name=[regexprep(method_name,'check','run'),'Checks'];
            check_name_str=check_name;
            try
                check_name_str=DAStudio.message(['HDLShared:hdlmodelchecker:',check_name]);
            catch mEx
                warning(mEx.identifier,mEx.message);%#ok<MEXCEP>
            end

            ResultDescription={ModelAdvisor.Text([statusText,' : ',check_name_str],{'bold'}),ResultDescription{:}};%#ok<CCAT>
            ResultDetails={ResultDetails{:},''};%#ok<CCAT>

            mdladvObj.setCheckResultStatus(status);
        end


        function dispChecks(this)
            if(length(this.m_Checks)>0)%#ok<ISMT>
                fprintf('Checker found %d issues.\n',length(this.m_Checks))
                fprintf(' # | severity | rule name | S/L block path\n')
                for itr=1:length(this.m_Checks)
                    curr=this.m_Checks(itr);
                    fprintf('%d) %s | %s| %s | %s \n',itr,curr.level,curr.summary,curr.message,curr.block)
                end
            else
                disp('No issues found; all checks passed.')
            end
        end


        function runFixes(this)%#ok<MANU>
            error('NOT IMPL')
        end



        function checks=runSpecificCheck(this,checkName,silently)
            if(nargin<3)
                silently=false;
            end
            this.(checkName)();
            checks=this.m_Checks;

            if(~silently)
                this.dispChecks();
            end
        end




        function checks=runChecks(this,silently)

            if(nargin<2)
                silently=false;
            end







            checkModelParams(this);


            checkSignalObjectStorageClass(this);


            checkInvalidDUT(this);

            this.checkInlineConfigurations;


            checkMLFcnBlk(this);


            checkBlockSupport(this);


            checkMatrixSizes(this);


            checkUnsupportedLUTTrigFun(this);


            checkHDLRecip(this);


            checkSampleTime(this);


            checkInitialConditions(this);


            checkEmbeddedSources(this);



            checkMathOperations(this);


            checkResourceSharing(this);


            checkDelayBalancing(this);


            checkStateflowChartSettings(this);
            checkStateflowAtomicSubchart(this);



            checkDistributedPipelining(this);


            checkMATLABPersistentVariables(this);


            checkDoubleDatatype(this);
            checkNFPSuggestion(this);
            checkNFPDTC(this);
            checkNFPHDLRecip(this);
            checkNFPRelop(this);
            checkNFPSupportedBlocks(this);
            checkNFPLatency(this);
            checkNFPULPError(this);


            checkFileExtension(this);
            checkNameConvention(this);
            checkToplevelName(this);
            checkSubsystemName(this);
            checkPortSignalName(this);


            checkObsoleteDelays(this);

            checks=this.m_Checks;

            if(~silently)
                this.dispChecks();
            end
        end

    end






    methods(Access=public)
        function addCheck(this,level,summary,block,mult_subchecks,varargin)
            narginchk(4,inf);
            if nargin<6
                chk=struct('level',level,'summary',summary,'message',[],'block',block,'mult_subchecks',mult_subchecks);
            else
                chk=struct('level',level,'summary',summary,'message',varargin,'block',block,'mult_subchecks',mult_subchecks);
            end
            this.m_Checks=[this.m_Checks,chk];
        end
    end

    methods(Access=public)
        function setLatency(this,latency)
            this.m_Latencies=[this.m_Latencies,latency];
        end
    end


    methods(Access=public)
        function addCheckForEach(this,blocks,level,message,mult_subchecks)
            for itr=1:length(blocks)
                this.addCheck(level,message,blocks{itr},mult_subchecks);
            end
        end




        function[flag,blocks]=getMatchingHandleAndMaskedBlocks(this,src_list,chk_tag)


            handle_blocks=find_system(this.m_DUT,'LookUnderMasks','all','FollowLinks','On','RegExp','On',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Type','Block','BlockType',src_list);
            mask_blocks=find_system(this.m_DUT,'LookUnderMasks','all','FollowLinks','On','RegExp','On',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Type','Block','MaskType',src_list);

            blocks=[mask_blocks;handle_blocks];
            flag=isempty(blocks);

            this.addCheckForEach(blocks,'warning',chk_tag,0);
        end


        function blockdata=getBlockTypes(this)
            blockdata=struct('types',[],'blocks',[],'total',0,'unique',0);


            blockList=find_system(this.m_sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','On','Type','Block');
            blockTypes={};
            for itr=1:length(blockList)
                if~strcmp(blockList{itr},this.m_sys)
                    blockType=get_param(blockList{itr},'BlockType');
                    maskType=get_param(blockList{itr},'MaskType');
                    blockTypes=union(blockTypes,union(maskType,blockType));
                end
            end
            blockdata.total=length(blockList);
            blockdata.unique=length(blockTypes);
            blockdata.blocks=blockList;
        end


        function retblockList=getSupportedBlocks(this)%#ok<MANU>
            persistent blockList
            if(isempty(blockList))
                coderObj=slhdlcoder.HDLCoder();
                implDB=coderObj.getImplDatabase();
                blockList=implDB.getSupportedBlocks();
            end
            retblockList=blockList;
        end
    end

    methods(Access=public)







        flag=checkModelParams(this)


        flag=checkBlockSupport(this)


        flag=checkHDLRecip(this);


        flag=checkUnsupportedLUTTrigFun(this);


        flag=checkSampleTime(this)


        flag=checkMatrixSizes(this);


        flag=checkInvalidDUT(this)



        flag=checkMLFcnBlkSatInt(this)


        flag=checkInitialConditions(this)





        flag=checkEmbeddedSources(this)


        flag=checkMathOperations(this)


        flag=checkResourceSharing(this)


        flag=checkDelayBalancing(this)


        flag=checkStateflowChartSettings(this)


        flag=checkStateflowAtomicSubchart(this)


        flag=checkDistributedPipelining(this)


        flag=checkDoubleDatatype(this)


        flag=checkNFPSuggestion(this)



        flag=checkNFPDTC(this)


        flag=checkNFPHDLRecip(this)


        flag=checkNFPRelop(this)


        flag=checkNFPSupportedBlocks(this)


        flag=checkNFPLatency(this)


        flag=checkNFPULPError(this)


        flag=checkMATLABPersistentVariables(this)


        flag=checkGlobalReset(this)


        flag=checkInlineConfigurations(this)


        flag=checkAlgebraicLoop(this)


        flag=checkBalanceDelays(this)


        flag=checkObsoleteDelays(this)

    end

end





