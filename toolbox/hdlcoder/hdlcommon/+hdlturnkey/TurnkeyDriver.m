

classdef TurnkeyDriver<handle


    properties

        hBoard=[];
        hTable=[];
        hElab=[];


        hExecMode=[];
        hStream=[];


        hConstrain=[];
        hDeviceTreeGen=[];
        hModelGen=[];
        hHostModelGen=[];
        hScriptGen=[];
        modelgeninfo=[];


        isTurnkeyCodeGenSuccessful=false;
        TimeStamp='';
        TurnkeyFileList={};

    end

    properties


        hD=[];

        hCHandle=[];

    end

    properties(Access=protected)


        hInterfaceList=[];
        hDynamicInterfaceList=[];

        hSoftwareInterfaceList=[];
        hHostInterfaceList=[];



        DefaultBusInterface=[];
    end

    properties(Constant,Hidden=true)

        ImageFolder=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+hdlturnkey','image');
    end

    methods

        function obj=TurnkeyDriver(hDIDriver)


            obj.hD=hDIDriver;
            obj.hTable=hdlturnkey.table.TargetInterfaceTable(obj);
            obj.hExecMode=hdlturnkey.frontend.ExecutionMode(obj);
            obj.hInterfaceList=hdlturnkey.interface.InterfaceList(obj);
            obj.hDynamicInterfaceList=hdlturnkey.interface.InterfaceListBase();
            obj.hSoftwareInterfaceList=hdlturnkey.swinterface.SoftwareInterfaceList(obj);
            obj.hHostInterfaceList=hdlturnkey.swinterface.SoftwareInterfaceList(obj);

            if obj.hD.queryFlowOnly==downstream.queryflowmodesenum.NONE
                obj.hCHandle=obj.hD.hCodeGen.hCHandle;
                obj.hElab=hdlturnkey.elab.BoardElaboration(obj);
                obj.hStream=hdlturnkey.frontend.StreamingDriver(obj);

                obj.hConstrain=hdlturnkey.backend.ConstrainEmitter(obj);
            end

        end

        function initBoardPlugin(obj,hPluginBoard)


            obj.hBoard=hPluginBoard;


            obj.hExecMode.initExecutionMode;

        end

        function initTurnkeyBoardPlugin(obj,hPluginBoard)

            obj.initBoardPlugin(hPluginBoard);

            if obj.hD.queryFlowOnly==downstream.queryflowmodesenum.NONE


                if obj.hBoard.isxPCBoard
                    obj.hModelGen=hdlslrt.backend.ModelGenerationxPC(obj);
                elseif obj.hD.isIPCoreGen


                end
            end


            obj.updateInterfaceList;
        end


        function makehdlturnkey(obj)




            initialMakehdlTurnkey(obj);



            if~obj.hD.isMLHDLC
                genhdlcode=hdlgetparameter('generatehdlcode');
                if~genhdlcode
                    error(message('hdlcommon:workflow:TurnOnGenHDLCode'));
                end

                if~obj.hCHandle.CodeGenSuccessful
                    error(message('hdlcommon:workflow:NeedHDLCodeGen'));
                end
            end


            obj.hD.hCodeGen.getDUTCodeGenInfo;
            obj.hD.hCodeGen.setBackupCgInfo;


            obj.hElab.getDUTCodeGenPIRInfo;




            if obj.hD.isIPCoreGen

                hdlDispWithTimeStamp(message('hdlcommon:hdlturnkey:BeginIPCoreGen'),obj.hD.Verbosity)
            else
                hdldisp(message('hdlcoder:hdldisp:BeginFPGATop'));
            end


            obj.hElab.initNameUniquification;






            if obj.hBoard.isxPCBoard||obj.hD.isIPCoreGen
                oldParam.clockenableoutputname=obj.hCHandle.getParameter('clockenableoutputname');
                obj.hCHandle.setParameter('clockenableoutputname','ce_out_nouse');
            end


            oldParam.oversampling=obj.hCHandle.getParameter('oversampling');
            if oldParam.oversampling>1
                obj.hCHandle.setParameter('oversampling',1);
            end


            oldParam.moduleprefix=obj.hCHandle.getParameter('module_prefix');
            if~isempty(oldParam.moduleprefix)
                obj.hCHandle.setParameter('module_prefix','');
            end


            oldParam.flattenVector=obj.hCHandle.getParameter('axiInterface512BitDataPortFeatureControl');
            obj.hCHandle.setParameter('axiInterface512BitDataPortFeatureControl',true);

            if~obj.hD.isMLHDLC&&hdlwfsmartbuild.isSmartbuildOn(obj.hD.isMLHDLC,obj.hD.hCodeGen.ModelName)&&(obj.hD.isIPCoreGen||obj.hD.isTurnkeyWorkflow||obj.hD.isXPCWorkflow)
                wrapGenSbObj=hdlwfsmartbuild.IPcoreWrapGenSb.getInstance(obj.hD);
                rebuildDecision=wrapGenSbObj.preprocess;
                if rebuildDecision

                    obj.makehdlturnkeycore;
                    result=evalc('wrapGenSbObj.postprocessLog');


                    savedInfoStruct.TurnkeyFileList=obj.TurnkeyFileList;
                    savedInfoStruct.modelgeninfo=obj.modelgeninfo;
                    savedInfoStruct.wrapperTopName=obj.hCHandle.cgInfo.topName;

                    if obj.hD.isIPCoreGen
                        savedInfoStruct.IPEmitterStruct=obj.hD.hIP.hIPEmitter.getIPEmitterStruct;
                    end

                    wrapGenSbObj.postprocessRebuild(result,savedInfoStruct);

                else

                    [status,result,returnedInfoStruct]=wrapGenSbObj.postprocessSkip;%#ok<ASGLU>
                    hdldisp(result);


                    obj.TurnkeyFileList=returnedInfoStruct.TurnkeyFileList;
                    obj.modelgeninfo=returnedInfoStruct.modelgeninfo;
                    obj.hCHandle.cgInfo.topName=returnedInfoStruct.wrapperTopName;
                    if obj.hD.isIPCoreGen
                        obj.hD.hIP.hIPEmitter.loadIPEmitterStruct(returnedInfoStruct.IPEmitterStruct);
                    end
                end
            else

                obj.makehdlturnkeycore;
            end



            if obj.hBoard.isxPCBoard||obj.hD.isIPCoreGen
                obj.hCHandle.setParameter('clockenableoutputname',oldParam.clockenableoutputname);
            end
            if oldParam.oversampling>1
                obj.hCHandle.setParameter('oversampling',oldParam.oversampling);
            end
            if~isempty(oldParam.moduleprefix)
                obj.hCHandle.setParameter('module_prefix',oldParam.moduleprefix);
            end

            obj.hCHandle.setParameter('axiInterface512BitDataPortFeatureControl',oldParam.flattenVector);


            finishMakehdlTurnkey(obj);
        end

        function makehdlturnkeycore(obj)

            initializePir(obj);


            obj.hElab.elaborateBoard;


            obj.populateModelGenInfo;


            obj.hCHandle.makehdlpir(obj.hElab.BoardPirInstance,obj.hD.isMLHDLC);


            obj.TurnkeyFileList=downstream.CodeGenInfo.getCodeGenSrcFileList(obj.hCHandle);


            if obj.hD.isTurnkeyWorkflow
                hClockModule=obj.hD.getClockModule;
                obj.TurnkeyFileList=[obj.TurnkeyFileList,hClockModule.XilinxDCMFiles];
            end


            obj.hConstrain.generateUCF;



            copyInterfaceIPFiles(obj);



            runPostCodeGenPass(obj);


            obj.hElab.verifyNameUniquification;


            finishMakehdlTurnkey(obj);


            if obj.hD.isIPCoreGen



                hdlDispWithTimeStamp(message('hdlcommon:hdlturnkey:BeginIPCorePackage'),obj.hD.Verbosity)

                obj.hD.hIP.generateIPCore;

                if obj.hD.hIP.getIPTestbench


                    obj.hCHandle.setParameter('module_prefix','');

                    obj.hD.hIP.generateIPTestbench;
                end
            end

        end


        function validateCell=validateWrapperCodeGen(obj)

            validateCell={};

            if obj.hD.isBoardEmpty
                error(message('hdlcommon:hdlturnkey:NoTargetBoard'));
            end

            if obj.hTable.isInterfaceTableEmpty
                error(message('hdlcommon:hdlturnkey:NoTargetInterfaceTable'));
            end

            mdlName=obj.hCHandle.ModelName;
            isMLHDLC=obj.hD.isMLHDLC;
            if isMLHDLC

                TCResettable=hdlgetparameter('ResettableTimingController');
                isVHDL=strcmpi(hdlgetparameter('target_language'),'VHDL');
                isResetActiveLow=hdlgetparameter('reset_asserted_level')==0;
                inputPortType=~hdlgetparameter('filter_input_type_std_logic');
                outputPortType=~hdlgetparameter('filter_output_type_std_logic');
                isSingleClock=hdlgetparameter('ClockInputs')==1;
                isMinimizeOn=hdlgetparameter('minimizeclockenables');
                isMinGlobalResetsOn=hdlgetparameter('minimizeglobalresets');
                isScalarizePortsDUTLevel=hdlgetparameter('ScalarizePorts')==2;
                isScalarizePortsOn=hdlgetparameter('ScalarizePorts')==1;
                isRecordGenerationOn=hdlgetparameter('GenerateRecordType')==1;
                isSplitEntityArch=hdlgetparameter('split_entity_arch');
                clockEdgeRising=hdlgetparameter('clockedge')==0;
                isDefaultVHDLExt=strcmpi(hdlgetparameter('vhdl_file_ext'),'.vhd');
                isDefaultVerilogExt=strcmpi(hdlgetparameter('verilog_file_ext'),'.v');
                isRAMWithClockEnable=hdlgetparameter('ramarchitecture')==1;
                isMulticyclePathConstraints=hdlgetparameter('multicyclepathconstraints');
            else



                TCResettable=strcmpi(hdlget_param(mdlName,'TimingControllerArch'),'resettable');
                isVHDL=strcmpi(hdlget_param(mdlName,'TargetLanguage'),'VHDL');
                isResetActiveLow=strcmpi(hdlget_param(mdlName,'ResetAssertedLevel'),'Active-low');
                inputPortType=strcmpi(hdlget_param(mdlName,'InputType'),'signed/unsigned');
                outputPortType=strcmpi(hdlget_param(mdlName,'OutputType'),'signed/unsigned');
                isSingleClock=strcmpi(hdlget_param(mdlName,'ClockInputs'),'Single');
                isMinimizeOn=strcmpi(hdlget_param(mdlName,'MinimizeClockEnables'),'on');
                isMinGlobalResetsOn=strcmp(hdlget_param(mdlName,'MinimizeGlobalResets'),'on');
                isScalarizePortsDUTLevel=strcmpi(hdlget_param(mdlName,'ScalarizePorts'),'dutlevel');
                isScalarizePortsOn=strcmpi(hdlget_param(mdlName,'ScalarizePorts'),'on');
                isSplitEntityArch=strcmpi(hdlget_param(mdlName,'SplitEntityArch'),'on');
                clockEdgeRising=strcmpi(hdlget_param(mdlName,'ClockEdge'),'Rising');
                isDefaultVHDLExt=strcmpi(hdlget_param(mdlName,'VHDLFileExtension'),'.vhd');
                isDefaultVerilogExt=strcmpi(hdlget_param(mdlName,'VerilogFileExtension'),'.v');
                isRAMWithClockEnable=strcmpi(hdlget_param(mdlName,'RAMArchitecture'),'WithClockEnable');
                isMulticyclePathConstraints=strcmpi(hdlget_param(mdlName,'MulticyclePathConstraints'),'on');
                isRecordGenerationOn=strcmpi(hdlget_param(mdlName,'GenerateRecordType'),'on');
            end


            workflowName=obj.hD.get('Workflow');


            if TCResettable==1
                msg=message('hdlcommon:hdlturnkey:ResettableTCUnsupported',...
                workflowName,mdlName);
                error(msg);
            end



            if~isVHDL&&~obj.hD.isIPCoreGen
                if isMLHDLC
                    actionMsgObj=message('hdlcommon:hdlturnkey:VerilogMLHDLWA');
                else
                    actionMsgObj=message('hdlcommon:hdlturnkey:VerilogHDLWA');
                end
                actionMsgStr=actionMsgObj.getString;
                error(message('hdlcommon:hdlturnkey:VerilogUnsupported',workflowName,actionMsgStr));
            end



            if((isVHDL&&~isDefaultVHDLExt)||...
                (~isVHDL&&~isDefaultVerilogExt))&&...
                obj.hD.isIPCoreGen&&obj.hD.isXilinxIP
                if isVHDL
                    extParamMsgObj=message('hdlcommon:hdlturnkey:VHDLExtParam');
                    extDefaultStr='.vhd';
                else
                    extParamMsgObj=message('hdlcommon:hdlturnkey:VerilogExtParam');
                    extDefaultStr='.v';
                end
                extParamMsgStr=extParamMsgObj.getString;
                if isMLHDLC
                    actionMsgObj=message('hdlcommon:hdlturnkey:VHDLExtMLHDLWA',extParamMsgStr);
                else
                    actionMsgObj=message('hdlcommon:hdlturnkey:VHDLExtHDLWA',extParamMsgStr);
                end
                error(message('hdlcommon:hdlturnkey:VHDLExtUnsupported',...
                extParamMsgStr,extDefaultStr,workflowName,...
                obj.hD.get('Tool'),actionMsgObj.getString));
            end


            if~clockEdgeRising
                if isMLHDLC
                    actionMsgObj=message('hdlcommon:hdlturnkey:FallingEdgeMLHDLWA');
                else
                    actionMsgObj=message('hdlcommon:hdlturnkey:FallingEdgeHDLWA');
                end
                actionMsgStr=actionMsgObj.getString;
                error(message('hdlcommon:hdlturnkey:FallingEdgeUnsupported',workflowName,actionMsgStr));
            end


            if isResetActiveLow
                if isMLHDLC
                    actionMsgObj=message('hdlcommon:hdlturnkey:ResetLowMLHDLWA');
                else
                    actionMsgObj=message('hdlcommon:hdlturnkey:ResetLowHDLWA');
                end
                actionMsgStr=actionMsgObj.getString;
                error(message('hdlcommon:hdlturnkey:ResetLowUnsupported',workflowName,actionMsgStr));
            end


            if isVHDL&&(inputPortType||outputPortType)
                if isMLHDLC
                    actionMsgObj=message('hdlcommon:hdlturnkey:SignUnsignedMLHDLWA');
                else
                    actionMsgObj=message('hdlcommon:hdlturnkey:SignUnsignedHDLWA');
                end
                actionMsgStr=actionMsgObj.getString;
                error(message('hdlcommon:hdlturnkey:SignUnsignedUnsupported',workflowName,actionMsgStr));
            end


            if~isSingleClock
                actionMsgObj=message('hdlcommon:hdlturnkey:MultiClockHDLWA');
                actionMsgStr=actionMsgObj.getString;
                error(message('hdlcommon:hdlturnkey:MultiClockUnsupported',workflowName,actionMsgStr));
            end






            if isVHDL&&~isScalarizePortsDUTLevel
                hIOPortList=obj.hTable.hIOPortList;
                hasVectorPort=hIOPortList.hasVectorPort;
                if hasVectorPort
                    msgobj=message('hdlcommon:workflow:SetScalarizePortsAsDutlevel');
                    msgStr=msgobj.getString;
                    turnedonMsgObj=message('hdlcommon:workflow:ScalarizePortsIsSetAsDutlevel',mdlName);
                    turnedonStr=turnedonMsgObj.getString;
                    actionLink=sprintf('<a href="matlab:hdlset_param(''%s'', ''ScalarizePorts'', ''DUTLevel'');warndlg(''%s'', ''Warning'', ''modal'');">%s</a>',...
                    mdlName,turnedonStr,msgStr);
                    if~isScalarizePortsOn

                        error(message('hdlcommon:workflow:TurnkeyScalarizePorts',actionLink));
                    else

                        msgObject=message('hdlcommon:workflow:TurnkeyScalarizePortsOn');
                        validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);
                    end
                end
            end
            if isVHDL&&isRecordGenerationOn
                error(message('hdlcommon:workflow:RecordsAtDut',workflowName));
            end




            if obj.hD.isXPCWorkflow
                if~isMLHDLC&&~strcmpi(hdlget_param(mdlName,'HDLCodingStandard'),'None')
                    CSStruct=hdlget_param(mdlName,'HDLCodingStandardCustomizations');
                    if~isempty(CSStruct)&&...
                        (CSStruct.SignalPortParamNameLength.enable||...
                        CSStruct.ModuleInstanceEntityNameLength.enable)
                        signalMsgObj=message('HDLShared:hdldialog:csoEntityName');
                        entityMsgObj=message('HDLShared:hdldialog:csoSignalName');
                        actionMsgObj=message('hdlcommon:hdlturnkey:CodingStandardHDLWA');
                        error(message('hdlcommon:hdlturnkey:CodingStandardUnsupported',...
                        signalMsgObj.getString,entityMsgObj.getString,...
                        workflowName,actionMsgObj.getString));
                    end
                end
            end




            if obj.hD.isIPCoreGen&&isSplitEntityArch
                actionMsgObj=message('hdlcommon:hdlturnkey:SplitEntityArchHDLWA');
                actionMsgStr=actionMsgObj.getString;
                error(message('hdlcommon:hdlturnkey:SplitEntityArchUnsupported',workflowName,actionMsgStr));
            end


            if~obj.hD.isGenericWorkflow
                if isMinGlobalResetsOn
                    actionMsgObj=message('hdlcommon:hdlturnkey:MinGlobalResetsHDLWA');
                    actionMsgStr=actionMsgObj.getString;
                    error(message('hdlcommon:hdlturnkey:MinGlobalResetsUnsupported',workflowName,actionMsgStr));
                end
            end



            if obj.hD.isIPCoreGen&&~isRAMWithClockEnable
                error(message('hdlcommon:hdlturnkey:RamArchitectureUnsupported',workflowName));
            end


            if obj.hD.isIPCoreGen&&obj.hD.isISE&&isMulticyclePathConstraints
                error(message('HDLShared:hdlshared:mcpIpcoreIseUnsupported'));
            end

        end

        function initializePir(obj)

            gp=pir;

            if obj.hD.isMLHDLC
                ModelOrFunctionName=gp.getTopNetwork.Name;
            else
                ModelOrFunctionName=obj.hCHandle.ModelName;
            end

            gp.destroy;
            obj.hCHandle.createPirObject(ModelOrFunctionName);
            obj.hElab.BoardPirInstance=obj.hCHandle.PirInstance;
        end

        function p=getPirInstance(obj)

            p=obj.hCHandle.PirInstance;
        end

        function copyInterfaceIPFiles(obj)

            interfaceIDList=obj.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.getInterface(interfaceID);


                if~hInterface.isInterfaceInUse(obj)
                    continue;
                end


                hInterface.copyInterfaceIPFiles(obj);
            end
        end

        function runPostCodeGenPass(obj)

            if downstream.plugin.PluginBase.existPluginFile(...
                obj.hBoard.PluginPath,'process_postCodeGen')
                cmdStr=sprintf('%s.%s',obj.hBoard.PluginPackage,'process_postCodeGen(obj)');
                try
                    eval(cmdStr);
                catch me
                    rethrow(me);
                end
            end
        end

        function[result,logTxt]=runPostProgramFilePass(obj)

            result=true;
            logTxt='';
            if downstream.plugin.PluginBase.existPluginFile(...
                obj.hBoard.PluginPath,'process_postProgramFile')
                cmdStr=sprintf('%s.%s',obj.hBoard.PluginPackage,'process_postProgramFile(obj)');
                try
                    [result,logTxt]=eval(cmdStr);
                catch me
                    rethrow(me);
                end
            end
        end

        function[status,result]=runDownloadCmd(obj,scriptOnly)


            if nargin<2

                scriptOnly=false;
            end

            if~isempty(obj.hBoard.hDeviceConfig)

                [status,result]=obj.hBoard.hDeviceConfig.configureFPGA(obj,scriptOnly);
            else

                if downstream.plugin.PluginBase.existPluginFile(...
                    obj.hBoard.PluginPath,'runDownloadCmd')
                    try
                        cmdStr=sprintf('%s.%s',obj.hBoard.PluginPackage,'runDownloadCmd(obj)');
                        [status,result]=eval(cmdStr);
                    catch me
                        rethrow(me);
                    end
                else
                    status=0;
                    result='Program Target Device is not supported for this board.';
                end
            end


            taskName=message('HDLShared:hdldialog:HDLWAProgramTargetDevice').getString;
            fileName=message('HDLShared:hdldialog:HDLWAProgramTargetDeviceENGLISH').getString;
            result=obj.hD.logDisplayToolResult(status,result,taskName,fileName);

        end


        function hProcessingSystem=getProcessingSystem(obj)
            if obj.hD.isIPCoreGen&&obj.hD.hIP.isRDListLoaded

            end

            hRD=obj.hD.hIP.getReferenceDesignPlugin;
            hProcessingSystem=hRD.getProcessingSystem;
        end

        function updateSoftwareInterfaceList(obj)

            obj.hSoftwareInterfaceList.updateInterfaceList;
        end
        function updateHostInterfaceList(obj)

            obj.hHostInterfaceList.updateHostInterfaceList;
        end
        function registerDeviceTreeNames(obj,ipCoreDeviceName)
            obj.hSoftwareInterfaceList.registerDeviceTreeNames(ipCoreDeviceName);
            obj.hHostInterfaceList.registerDeviceTreeNames(ipCoreDeviceName);
        end
        function interfaceIDList=getSoftwareInterfaceIDList(obj)
            interfaceIDList=obj.hSoftwareInterfaceList.getInterfaceIDList;
        end
        function hostInterfaceIDList=getHostInterfaceIDList(obj)

            hostInterfaceIDList=obj.hHostInterfaceList.getInterfaceIDList;
        end
        function hSoftwareInterface=getSoftwareInterface(obj,interfaceID)
            hSoftwareInterface=obj.hSoftwareInterfaceList.getInterface(interfaceID);
        end
        function hHostInterface=getHostInterface(obj,interfaceID)
            hHostInterface=obj.hHostInterfaceList.getInterface(interfaceID);
        end
        function isAll=isAllSoftwareInterfaceEmpty(obj)
            isAll=obj.hSoftwareInterfaceList.isAllInterfaceEmpty;
        end
        function isAll=isAllHostInterfaceEmpty(obj)
            isAll=obj.hHostInterfaceList.isAllInterfaceEmpty;
        end

        function hDeviceTreeGen=constructDeviceTreeGenerationObject(obj)

            hDeviceTreeGen=[];

            hDI=obj.hD;
            if hDI.isProcessingSystemAvailable
                hDeviceTreeGen=hdlturnkey.backend.DeviceTreeGeneration(obj);
            end
        end

        function hModelGen=constructModelGenerationObject(obj)

            hModelGen=[];

            hDI=obj.hD;
            if hDI.isProcessingSystemAvailable&&hDI.isEmbeddedCoderSPInstalled



                if hDI.isXilinxIP
                    if~hdlturnkey.ishdlzynqspinstalled
                        error(message('hdlcommon:workflow:HDLZynqPackageUnavailable'));
                    end

                    hModelGen=hdlturnkey.backend.ModelGenerationZynq(obj);
                elseif hDI.isAlteraIP
                    if~hdlturnkey.ishdlalterasocspinstalled
                        error(message('hdlcommon:workflow:HDLAlteraSoCPackageUnavailable'));
                    end

                    hModelGen=hdlturnkey.backend.ModelGenerationAlteraSoc(obj);
                end
            else




                hModelGen=hdlturnkey.backend.ModelGenerationCustom(obj);
            end
        end

        function hModelGen=constructHostModelGenerationObject(obj)

            hModelGen=[];

            hDI=obj.hD;
            hRD=obj.hD.hIP.getReferenceDesignPlugin;
            hasMATLABAXIMasterConnection=hRD.getJTAGAXIParameterValue||hRD.getEthernetAXIParameterValue;
            if(hasMATLABAXIMasterConnection)

                if hDI.isXilinxIP
                    hModelGen=hdlturnkey.backend.ModelGenerationZynq(obj);
                elseif hDI.isAlteraIP
                    hModelGen=hdlturnkey.backend.ModelGenerationAlteraSoc(obj);
                end
            else




                hModelGen=hdlturnkey.backend.ModelGenerationCustom(obj);
            end
        end

        function hScriptGen=constructScriptGenerationObject(obj)

            hScriptGen=[];






            hDI=obj.hD;
            if hDI.isXilinxIP
                hScriptGen=hdlturnkey.backend.ScriptGenerationZynq(obj);
            elseif hDI.isAlteraIP
                hScriptGen=hdlturnkey.backend.ScriptGenerationAlteraSoc(obj);
            elseif hDI.isMicrochipIP
                hScriptGen=hdlturnkey.backend.ScriptGenerationMicrochip(obj);
            end
        end

        function[status,result,validateCell]=generateDeviceTree(obj)



            if isempty(obj.hDeviceTreeGen)
                obj.hDeviceTreeGen=obj.constructDeviceTreeGenerationObject;
            end


            [status,result,validateCell]=obj.hDeviceTreeGen.generateDeviceTree;
        end

        function[devTree,includeDirs]=getGeneratedIPCoreDeviceTree(obj)


            if obj.hD.hIP.GenerateDeviceTree







                if isempty(obj.hDeviceTreeGen)
                    obj.hDeviceTreeGen=obj.constructDeviceTreeGenerationObject;
                end
                devTree=obj.hDeviceTreeGen.getDeviceTree;
                includeDirs=obj.getDeviceTreeFolder;
            else
                devTree='';
                includeDirs=string.empty;
            end
        end

        function dtFolder=getDeviceTreeFolder(obj)
            dtFolder=fullfile(obj.hD.getProjectFolder,"devicetree");
        end

        function[status,result,validateCell]=generateInterfaceModel(obj)


            obj.validateModelGeneration;







            if isempty(obj.hModelGen)
                obj.hModelGen=obj.constructModelGenerationObject;
            end


            [status,result,validateCell]=obj.hModelGen.generateModel;




            if(obj.isHalfDataTypeInIOPortList)
                msg=message('hdlcommon:interface:AXIStreamHalfTypeSWModelGen');
                validateCell{end+1}=downstream.tool.generateWarningWithStruct(msg,obj.hModelGen.isCommandLineDisplay);
            end
        end

        function[status,result,validateCell]=generateHostInterfaceModel(obj)


            obj.validateModelGeneration;


            if isempty(obj.hHostModelGen)
                obj.hHostModelGen=obj.constructHostModelGenerationObject;
            end


            [status,result,validateCell]=obj.hHostModelGen.generateHostModel;
        end

        function[status,result,validateCell]=generateInterfaceScript(obj)



            if obj.isCoProcessorMode
                optionName=message('hdlcommon:workflow:HDLWASWInterfaceScript').getString;
                error(message('hdlcommon:workflow:UnsupportedScriptGenCop',optionName));
            end


            if isempty(obj.hScriptGen)
                obj.hScriptGen=obj.constructScriptGenerationObject;
            end


            [status,result,validateCell]=obj.hScriptGen.generateScript;
        end

        function validateModelGeneration(obj)

            if obj.hD.isMLHDLC
                error(message('hdlcommon:workflow:UnsupportedModelGenMLHDLC'));
            end





            dutPath=obj.hD.hCodeGen.getDutName;
            if downstream.tool.isDUTLibraryBlock(dutPath)||...
                downstream.tool.isDUTSubsystemReference(dutPath)
                error(message('hdlcommon:workflow:UnsupportedModelGenSubsystem'));
            end
        end

        function isa=isHalfDataTypeInIOPortList(obj)
            isa=false;

            portList=obj.hTable.hIOPortList.InputPortNameList;
            for ii=1:length(portList)
                portName=portList{ii};
                hIOPort=obj.hTable.hIOPortList.getIOPort(portName);
                if(strcmp(hIOPort.SLDataType,'half'))
                    isa=true;
                    return;
                end
            end

            portList=obj.hTable.hIOPortList.OutputPortNameList;
            for ii=1:length(portList)
                portName=portList{ii};
                hIOPort=obj.hTable.hIOPortList.getIOPort(portName);
                if(strcmp(hIOPort.SLDataType,'half'))
                    isa=true;
                    return;
                end
            end
        end


        function populateModelGenInfo(obj)


            validateCell={};


            obj.modelgeninfo.BoardName=obj.hD.get('Board');


            obj.modelgeninfo.ToolName=obj.hD.get('Tool');








            if obj.hD.isIPCoreGen


                hRD=obj.hD.hIP.getReferenceDesignPlugin;
                if~isempty(hRD)


                    obj.modelgeninfo.ReferenceDesignName=obj.hD.hIP.getReferenceDesign;
                    obj.modelgeninfo.ReferenceDesignPath=obj.hD.hIP.getReferenceDesignPath;
                end


                obj.modelgeninfo.IPCoreName=obj.hD.hIP.getIPCoreName;


                hBus=obj.hElab.getDefaultBusInterface;



                if~hBus.isEmptyAXI4SlaveInterface

                    obj.modelgeninfo.BaseAddr=hBus.BaseAddress;


                    hBaseAddr=hBus.hBaseAddr;
                    hAddr=hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.ENABLE);
                    offsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);
                    obj.modelgeninfo.IPEnableOffset=offsetStr;


                    hAddr=hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.RESET);
                    offsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);
                    obj.modelgeninfo.IPResetOffset=offsetStr;


                    hAddr=hBaseAddr.getAddressWithType(hdlturnkey.data.AddrType.TIMESTAMP);
                    offsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);
                    obj.modelgeninfo.TimestampOffset=offsetStr;
                    obj.modelgeninfo.TimestampValue=obj.hD.hIP.getTimestampStr;

                    if obj.isCoProcessorMode

                        hAddr=hBaseAddr.getAddressWithName('cop_in_strobe');
                        offsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);
                        obj.modelgeninfo.CopStrobeOffset=offsetStr;


                        hAddr=hBaseAddr.getAddressWithName('cop_out_ready');
                        offsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(hAddr.AddressStart);
                        obj.modelgeninfo.CopReadyOffset=offsetStr;

                    else
                        obj.modelgeninfo.CopStrobeOffset='';
                        obj.modelgeninfo.CopReadyOffset='';
                    end
                end
            end





            if obj.hD.isIPCoreGen||obj.hD.isSLRTWorkflow

                obj.modelgeninfo.SyncMode=obj.hD.get('ExecutionMode');


                obj.modelgeninfo.PortInfo={};
                inPortList=obj.hTable.hIOPortList.InputPortNameList;
                for ii=1:length(inPortList)
                    portName=inPortList{ii};
                    [portInfo,validateCell]=obj.getPortInfo(portName,validateCell);
                    obj.modelgeninfo.PortInfo{end+1}=portInfo;
                end

                outPortList=obj.hTable.hIOPortList.OutputPortNameList;
                for ii=1:length(outPortList)
                    portName=outPortList{ii};
                    [portInfo,validateCell]=obj.getPortInfo(portName,validateCell);
                    obj.modelgeninfo.PortInfo{end+1}=portInfo;
                end




                obj.modelgeninfo.TunableParamNameList=obj.hTable.hTunableParamPortList.TunableParamNameList;
                obj.modelgeninfo.TunableParamPortMap=obj.hTable.hTunableParamPortList.TunableParamPortMap;
                obj.modelgeninfo.TunableParamSLTypeMap=obj.hTable.hTunableParamPortList.TunableParamSLTypeMap;


                obj.modelgeninfo.validateCell=validateCell;
            end



            if obj.hD.isSLRTWorkflow

            end
        end


        function[portInfo,validateCell]=getPortInfo(obj,portName,validateCell)

            hIOPort=obj.hTable.hIOPortList.getIOPort(portName);
            portInfo.PortName=portName;
            portInfo.PortType=downstream.tool.getPortDirTypeStr(hIOPort.PortType);
            portInfo.DataType=hIOPort.SLDataType;
            portInfo.Dimension=hIOPort.Dimension;
            portInfo.SampleTime=hIOPort.PortRate;


            hInterface=obj.hTable.hTableMap.getInterface(portName);

            bitRangeStr=obj.hTable.hTableMap.getBitRangeStr(portName);
            if hInterface.isAddrBasedInterface
                addrInternal=hdlturnkey.data.Address.convertAddrStrToInternal(bitRangeStr);
                offsetStr=hdlturnkey.data.Address.convertAddrInternalToCStr(addrInternal);
                hAddr=hInterface.hAddrManager.getAddress(addrInternal);

                portInfo.PortOffset=offsetStr;
                portInfo.NeedBitPacking=hAddr.NeedBitPacking;
                portInfo.PackedVectorSize=hAddr.PackedVectorSize;

            else
                portInfo.PortOffset=bitRangeStr;
            end

            interfaceStr=obj.hTable.hTableMap.getInterfaceStr(portName);
            if hInterface.isIPInterface&&hInterface.isAXI4StreamInterface


                if obj.hStream.isAXI4StreamFrameMode

                    if hInterface.HasDMAConnection
                        portInfo.Interface='AXI4-Stream';
                        portInfo.DMABaseAddress=hInterface.DMABaseAddress;
                        portInfo.DMAInterruptNumber=hInterface.getDMAInterruptNumber(portName);
                    else
                        portInfo.Interface='External Port';
                    end
                else

                    portInfo.Interface='External Port';
                end
            elseif hInterface.isIPInterface&&hInterface.isAXI4StreamVideoInterface
                portInfo.Interface='External Port';
            else

                portInfo.Interface=interfaceStr;
            end


            if strcmp(portInfo.DataType,'bus')
                portInfo.BusType=hIOPort.Type;
            end

        end


        function generatexPCInterface(obj)



            obj.hModelGen.generateModel;
        end


        function initialMakehdlTurnkey(obj)

            obj.isTurnkeyCodeGenSuccessful=false;
            obj.TimeStamp='';
        end

        function finishMakehdlTurnkey(obj)

            obj.isTurnkeyCodeGenSuccessful=true;
            obj.TimeStamp=obj.hCHandle.TimeStamp;
        end

        function str=file2str(~,fileName)
            str=fileread(fileName);
        end

        function str2file(~,str,filename)
            fid=fopen(filename,'w');
            if fid==-1
                fprintf(1,'Failed to open file ''%s'' for writing.',filename);
                error(message('hdlcommon:workflow:FailOpenFile',fileName));
            end
            fprintf(fid,'%s',str);
            fclose(fid);
        end



        function isOn=showExecutionMode(obj)
            isOn=obj.hExecMode.showExecutionMode;
        end
        function isMode=isCoProcessorMode(obj)
            isMode=obj.hExecMode.isCoProcessorMode;
        end
        function hOption=getExecutionModeOption(obj)
            hOption=obj.hExecMode.getExecutionModeOption;
        end
        function setExecutionMode(obj,optionValue)
            obj.hExecMode.setExecutionMode(optionValue);
        end












        function hInterfaceList=getInterfaceList(obj)
            hInterfaceList=obj.hInterfaceList;
        end

        function interfaceIDList=getInterfaceIDList(obj)
            interfaceIDList=obj.hInterfaceList.getInterfaceIDList;
        end

        function hInterface=getInterface(obj,interfaceID)
            hInterface=obj.hInterfaceList.getInterface(interfaceID);
        end

        function interfaceIDList=getSupportedInterfaceIDList(obj)
            interfaceIDList=obj.hInterfaceList.getSupportedInterfaceIDList;
        end

        function interfaceIDList=getAssignedInterfaceIDList(obj)
            interfaceIDList=obj.hTable.hTableMap.getAssignedInterfaces;
        end
        function isa=isAssignedInterface(obj,interfaceID)
            isa=obj.hTable.hTableMap.isAssignedInterface(interfaceID);
        end









        function msgList=loadDynamicInterfaceFromModel(obj)





            msgList={};



            if~obj.hD.isGenericIPPlatform
                return;
            end


            if obj.hD.isMLHDLC
                return;
            end


            obj.clearDynamicInterfaceList();

            dutName=obj.hD.hCodeGen.getDutName;
            if~downstream.tool.isDUTTopLevel(dutName)&&~downstream.tool.isDUTModelReference(dutName)

                AdditionalInterfaces=hdlget_param(dutName,'AdditionalTargetInterfaces');


                for ii=1:length(AdditionalInterfaces)
                    interfaceType=AdditionalInterfaces{ii}{1};
                    interfacePVParis=AdditionalInterfaces{ii}(2:end);
                    try
                        obj.addDynamicInterfaceOfType(interfaceType,interfacePVParis{:})
                    catch me
                        msg=MException(message('hdlcommon:workflow:LoadDynamicInterfaceSettingFromModel',interfaceType,me.message));
                        msgList{end+1}=msg;%#ok<AGROW>
                    end
                end
            end
        end
        function saveDynamicInterfaceToModel(obj)





            if~obj.hD.isGenericIPPlatform
                return;
            end


            if obj.hD.isMLHDLC
                return;
            end

            interfaceCell={};
            dutName=obj.hD.hCodeGen.getDutName;
            if~downstream.tool.isDUTTopLevel(dutName)&&~downstream.tool.isDUTModelReference(dutName)&&...
                ~obj.hD.getloadingFromModel

                dynamicInterfaceIDList=obj.getDynamicInterfaceIDList;
                for ii=1:length(dynamicInterfaceIDList)
                    interfaceID=dynamicInterfaceIDList{ii};


                    interfaceType=obj.getDynamicInterfaceProperty(interfaceID,'DefaultInterfaceID');
                    interfaceCell{end+1}={interfaceType,'InterfaceID',interfaceID};%#ok<AGROW>
                end

                hdlset_param(dutName,'AdditionalTargetInterfaces',interfaceCell);
            end
        end


        function interfaceIDList=getDynamicInterfaceIDList(obj)
            interfaceIDList=obj.hDynamicInterfaceList.getInterfaceIDList;
        end
        function hInterface=getDynamicInterface(obj,interfaceID)
            hInterface=obj.hDynamicInterfaceList.getInterface(interfaceID);
        end
        function interfaceOptions=getDynamicInterfaceOptions(obj)







            interfaceOptions={...
            hdlturnkey.interface.AXI4Stream.DefaultInterfaceID,...
            hdlturnkey.interface.AXI4Master.DefaultInterfaceID,...
            };


            if obj.hD.isVivado
                interfaceOptions{end+1}=hdlturnkey.interface.AXI4StreamVideo.DefaultInterfaceID;
            end

        end
        function propVal=getDynamicInterfaceProperty(obj,interfaceID,propName)
            propVal=obj.hDynamicInterfaceList.getInterfaceProperty(interfaceID,propName);
        end


        function clearDynamicInterfaceList(obj)





            obj.hDynamicInterfaceList.clearInterfaceList();
        end
        function addDynamicInterfaceOfType(obj,interfaceType,varargin)




            interfaceOptions=obj.getDynamicInterfaceOptions;
            if~any(strcmpi(interfaceType,interfaceOptions))
                error(message('hdlcommon:workflow:DynamicInterfaceUnsupported',interfaceType,strjoin(interfaceOptions,', ')));
            end

            switch lower(interfaceType)
            case lower(hdlturnkey.interface.AXI4Stream.DefaultInterfaceID)
                obj.addDynamicAXI4StreamInterface(varargin{:});
            case lower(hdlturnkey.interface.AXI4StreamVideo.DefaultInterfaceID)
                obj.addDynamicAXI4StreamVideoInterface(varargin{:});
            case lower(hdlturnkey.interface.AXI4Master.DefaultInterfaceID)
                obj.addDynamicAXI4MasterInterface(varargin{:});
            otherwise
                error(message('hdlcommon:workflow:DynamicInterfaceUnsupported',interfaceType,strjoin(interfaceOptions,', ')));
            end
        end
        function addDynamicAXI4StreamInterface(obj,varargin)

            hInterface=hdlturnkey.interface.AXI4Stream('IsGenericIP',true,varargin{:});
            obj.addDynamicInterface(hInterface);
        end
        function addDynamicAXI4StreamVideoInterface(obj,varargin)

            hInterface=hdlturnkey.interface.AXI4StreamVideo('IsGenericIP',true,varargin{:});
            obj.addDynamicInterface(hInterface);
        end
        function addDynamicAXI4MasterInterface(obj,varargin)

            hInterface=hdlturnkey.interface.AXI4Master('IsGenericIP',true,varargin{:});
            obj.addDynamicInterface(hInterface);
        end
        function addDynamicInterface(obj,hInterface)




            if~obj.hD.isGenericIPPlatform
                return;
            end

            obj.hDynamicInterfaceList.addInterface(hInterface);
        end



        function updateInterfaceList(obj)

            obj.hInterfaceList.updateInterfaceList;
        end


        function msg=updateInterfaceListWithModel(obj)



            msgList={};
            try
                msgList=obj.loadDynamicInterfaceFromModel();
                obj.updateInterfaceList();
            catch me


                msg=MException(message('hdlcommon:workflow:LoadDynamicInterfaceListFromModel',me.message));
                msgList{end+1}=msg;
            end



            msg=[];
            if~isempty(msgList)

                obj.clearDynamicInterfaceList();
                obj.updateInterfaceList();


                msg=MException(message('hdlcommon:workflow:ApplyDynamicInterfaceSettingFromModel'));
                for ii=1:length(msgList)
                    msg=msg.addCause(msgList{ii});
                end
            end
        end


        function refreshTableInterface(obj)

            obj.hInterfaceList.refreshTableInterface;
        end


        function setDefaultBusInterface(obj,hInterface)
            if~hInterface.isAddrBasedInterface
                error(message('hdlcommon:workflow:InvalidDefaultBusInterface',...
                hInterface.InterfaceID));
            end
            obj.DefaultBusInterface=hInterface;
        end
        function hDefaultBusInterface=getDefaultBusInterface(obj)



            obj.resolveDefaultBusInterface;
            hDefaultBusInterface=obj.DefaultBusInterface;
        end
        function isa=isDefaultBusInterface(obj,hInterface)
            isa=isequal(getDefaultBusInterface(obj),hInterface);
        end
        function ret=isDefaultBusInterfaceEmpty(obj)
            ret=isempty(obj.DefaultBusInterface);
        end
        function resolveDefaultBusInterface(obj)








            if obj.isDefaultBusInterfaceEmpty


                if(obj.hD.isIPCoreGen&&~obj.hExecMode.isCoProcessorMode)
                    if~obj.hD.hIP.getAXI4SlaveEnable

                        obj.DefaultBusInterface=obj.getAXI4SlaveEmptyInterface();
                        return;
                    end
                end

                interfaceIDList=obj.getSupportedInterfaceIDList;
                for ii=1:length(interfaceIDList)
                    interfaceID=interfaceIDList{ii};
                    hInterface=obj.getInterface(interfaceID);
                    if hInterface.isAddrBasedInterface
                        obj.DefaultBusInterface=hInterface;
                        break;
                    end
                end
            end
        end
        function interface=getAXI4SlaveEmptyInterface(obj)
            interfaceIDList=obj.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.getInterface(interfaceID);
                if hInterface.isEmptyAXI4SlaveInterface
                    interface=hInterface;
                    return;
                end
            end
        end
        function refreshDefaultBusInterface(obj)


            if~obj.isDefaultBusInterfaceEmpty
                interfaceIDList=obj.getSupportedInterfaceIDList;
                for ii=1:length(interfaceIDList)
                    interfaceID=interfaceIDList{ii};
                    hInterface=obj.getInterface(interfaceID);


                    if hInterface.isAddrBasedInterface&&...
                        obj.isAssignedInterface(interfaceID)
                        return;
                    end
                end


                obj.clearDefaultBusInterface;
            end
        end
        function clearDefaultBusInterface(obj)

            obj.DefaultBusInterface=[];
        end
        function registerDefaultBusAddress(obj)




            obj.hElab.registerDefaultBusAddress;
        end


        function hPCI=getPCIInterface(obj)

            hPCI=[];
            interfaceIDList=obj.getSupportedInterfaceIDList;
            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.getInterface(interfaceID);
                if hInterface.isPCIInterface
                    hPCI=hInterface;
                    return;
                end
            end
        end

        function path=getBitstreamPath(obj)
            topLevelName=obj.hElab.TopNetName;
            path=sprintf('%s.bit',topLevelName);
        end

        function isa=isVersalPlatform(obj)




            isa=contains(obj.hD.get('Family'),'Versal',IgnoreCase=true);
        end

    end
end







