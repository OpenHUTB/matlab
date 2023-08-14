



classdef IPDriver<hdlturnkey.ip.HDLTargetDriverBase


    properties

        hIPEmitter=[];
        hIPTestbench=[];

    end

    properties(GetAccess=public,SetAccess=protected)


        isGenericIPPlatform=false;

    end

    properties(Access=protected)


        hETool=[];
        hIPCoreList=[];
        IPCoreDeviceName=[];


        WorkflowEnum=hdlcoder.Workflow.IPCoreGeneration;



        IPRepository='';



        IPReport=false;


        EmbeddedToolName='';
        ExternalBuild=false;
        DesignCheckpoint=false;
        ReportTimingOption=hdlcoder.ReportTiming.Error;
        ReportTimingFailureToleranceOption=0;

    end


    properties(Hidden)

        GenerateDeviceTree=true;


        GenerateHostInterfaceModel=false;


        GenerateSoftwareInterfaceModel=true;


        GenerateHostInterfaceScript=true;


        HostTargetInterfaceOptions={};
        HostTargetInterface='';


        HostTargetEthernetIPAddress='';
        HostTargetEthernetPortAddress='';
    end

    properties(Access=protected)

        EnableGenerateSoftwareInterfaceModel=true;
    end

    properties(Dependent,Access=protected)

        EnableHostTargetInterfaceOptions;


        EnableGenerateHostInterfaceModel;


        EnableGenerateHostInterfaceScript;
    end

    methods
        function genModel=get.GenerateSoftwareInterfaceModel(obj)
            genModel=obj.GenerateSoftwareInterfaceModel;


            if~obj.EnableGenerateSoftwareInterfaceModel
                genModel=false;
            end
        end

        function genModel=get.GenerateHostInterfaceModel(obj)
            genModel=obj.GenerateHostInterfaceModel;


            if~obj.EnableGenerateHostInterfaceModel
                genModel=false;
            end
        end

        function genScript=get.GenerateHostInterfaceScript(obj)
            genScript=obj.GenerateHostInterfaceScript;


            if~obj.EnableGenerateHostInterfaceScript
                genScript=false;
            end
        end

        function isEnabled=get.EnableHostTargetInterfaceOptions(obj)


            isEnabled=~isempty(obj.HostTargetInterfaceOptions);
        end

        function isEnabled=get.EnableGenerateHostInterfaceModel(obj)



            isEnabled=~isempty(obj.HostTargetInterfaceOptions)&&...
            (strcmp(obj.HostTargetInterface,'JTAG AXI Manager (HDL Verifier)')||...
            strcmp(obj.HostTargetInterface,'Ethernet AXI Manager (HDL Verifier)'))&&...
            any(strcmp(obj.HostTargetInterface,obj.HostTargetInterfaceOptions));


        end

        function isEnabled=get.EnableGenerateHostInterfaceScript(obj)


            isEnabled=~isempty(obj.HostTargetInterfaceOptions);
        end
    end

    methods

        function obj=IPDriver(hDIDriver,workflowEnum)




            if nargin<2
                workflowEnum=hdlcoder.Workflow.IPCoreGeneration;
            end


            obj=obj@hdlturnkey.ip.HDLTargetDriverBase(hDIDriver);

            obj.WorkflowEnum=workflowEnum;



            switch workflowEnum
            case hdlcoder.Workflow.IPCoreGeneration
                obj.setIPPlatformList(hdlturnkey.plugin.IPBoardList);
            case hdlcoder.Workflow.DeepLearningProcessor
                obj.setIPPlatformList(hdlturnkey.plugin.DLBoardList);
            otherwise
                error(message('hdlcommon:workflow:UnsupportedIPWorkflow',...
                hdlcoder.Workflow.getWorkflowName(workflowEnum)));
            end


            obj.hIPCoreList=hdlturnkey.ip.IPCoreList(obj);


            dutList={obj.hD.hCodeGen.getDutName()};
            for ii=1:length(dutList)
                dutName=dutList{ii};
                obj.addIPCore(dutName);
            end
        end

    end

    methods(Access=private)

        function initEToolParameter(obj)




            obj.EmbeddedToolName=obj.hETool.getEmbeddedTool;



            obj.ExternalBuild=~obj.hD.isSLRTWorkflow;


            obj.hETool.loadECoderSPSettings;


            obj.hETool.refreshProgrammingMethod;

        end

    end

    methods


        function initIPPlatform(obj)




            toolName=obj.hD.get('Tool');
            if strcmpi(toolName,'Xilinx ISE')
                obj.hIPEmitter=hdlturnkey.ip.IPEmitterEDK(obj);
            elseif strcmpi(toolName,'Xilinx Vivado')
                obj.hIPEmitter=hdlturnkey.ip.IPEmitterVivado(obj);
            elseif strcmpi(toolName,'Altera QUARTUS II')
                obj.hIPEmitter=hdlturnkey.ip.IPEmitterQsys(obj);
            elseif strcmpi(toolName,'Intel Quartus Pro')
                obj.hIPEmitter=hdlturnkey.ip.IPEmitterQsys(obj);
            elseif strcmpi(toolName,'Microchip Libero SoC')
                obj.hIPEmitter=hdlturnkey.ip.IPEmitterLibero(obj);
            else
                error(message('hdlcommon:workflow:UnsupportedTool',toolName));
            end


            dutList=obj.getIPCoreDUTList;
            for ii=1:length(dutList)
                dutName=dutList{ii};
                hIPCore=obj.getIPCore(dutName);

                hIPCore.initIPParameter;
            end


            obj.IPReport=true;



            obj.IPRepository='';


            obj.ReportTimingOption=hdlcoder.ReportTiming.Error;


            obj.ReportTimingFailureToleranceOption=0;


            hTurnkey=getTurnkeyObject(obj);


            obj.isGenericIPPlatform=obj.getBoardObject.isGenericIPPlatform;




            obj.hRDList=hdlturnkey.plugin.ReferenceDesignList(obj);
            if~obj.isGenericIPPlatform
                obj.hRDList.buildRDList;
            end


            if obj.isGenericIPPlatform



                obj.hETool=[];
                obj.hRDList=[];





                hTurnkey.updateInterfaceListWithModel;

            else



                if strcmpi(toolName,'Xilinx ISE')
                    obj.hETool=hdlturnkey.tool.EmbeddedToolDriverEDK(obj);
                elseif strcmpi(toolName,'Xilinx Vivado')
                    obj.hETool=hdlturnkey.tool.EmbeddedToolDriverVivado(obj);
                elseif strcmpi(toolName,'Altera QUARTUS II')
                    obj.hETool=hdlturnkey.tool.EmbeddedToolDriverQsys(obj);
                elseif strcmpi(toolName,'Intel Quartus Pro')
                    obj.hETool=hdlturnkey.tool.EmbeddedToolDriverQsys(obj);
                elseif strcmpi(toolName,'Microchip Libero SoC')
                    obj.hETool=hdlturnkey.tool.EmbeddedToolDriverLibero(obj);
                else
                    error(message('hdlcommon:workflow:UnsupportedTool',toolName));
                end


                obj.initEToolParameter;



                obj.hRDList.setDefaultReferenceDesign;

            end



            if(~obj.hD.isMLHDLC)
                obj.hIPTestbench=hdlturnkey.iptestbench.IPTestbench(obj);
            end


            lockCurrentDir(obj);
        end


        function generateIPCore(obj)
            obj.hIPEmitter.generateIPCore;
        end


        function generateIPTestbench(obj)
            obj.hIPTestbench.generateIPTestbench;
        end


        function[status,result]=createEmbeddedProject(obj)

            validateGenericIPPlatform(obj);


            [status,result]=obj.hETool.runCreateProject;


            if status
                [status2,log2]=hdlturnkey.plugin.runCallbackPostCreateProject(obj.hD);
                status=status&&status2;
                result=sprintf('%s\n%s\n',result,log2);
            end


            taskName=message('HDLShared:hdldialog:HDLWACreateProject').getString;
            fileName=message('HDLShared:hdldialog:HDLWACreateProjectENGLISH').getString;
            result=obj.hD.logDisplayToolResult(status,result,taskName,fileName);
        end

        function hostTargetOptions=getHostTargetInterfaceOptions(obj)
            hostTargetOptions=obj.HostTargetInterfaceOptions;





            if isempty(hostTargetOptions)
                hostTargetOptions={''};
            end
        end

        function enableHostTargetOptions=getEnableHostInterfaceOptions(obj)
            enableHostTargetOptions=obj.EnableHostTargetInterfaceOptions;
        end

        function setHostTargetInterfaceOptions(obj,enableJTAGOption,enableEthernetAXIModelOption,enableEthernetOption)

            obj.HostTargetInterfaceOptions={};
            if(enableJTAGOption)

                obj.HostTargetInterfaceOptions{end+1}='JTAG AXI Manager (HDL Verifier)';
            end
            if(enableEthernetAXIModelOption)

                obj.HostTargetInterfaceOptions{end+1}='Ethernet AXI Manager (HDL Verifier)';
            end
            if(enableEthernetOption)

                obj.HostTargetInterfaceOptions{end+1}='Ethernet';
            end


            switch length(obj.HostTargetInterfaceOptions)
            case 0

                obj.HostTargetInterface='';
            case 1

                obj.HostTargetInterface=obj.HostTargetInterfaceOptions{1};
            otherwise


                if isempty(obj.HostTargetInterface)
                    obj.HostTargetInterface='Ethernet';
                end
            end
        end

        function HostEthernetIPAddress=getHostTargetEthernetIPAddress(obj)
            HostEthernetIPAddress=obj.HostTargetEthernetIPAddress;
        end

        function setHostTargetEthernetIPAddress(obj,hostEthernetIPAddress)
            obj.HostTargetEthernetIPAddress=hostEthernetIPAddress;
        end

        function HostEthernetPortAddress=getHostTargetEthernetPortAddress(obj)
            HostEthernetPortAddress=obj.HostTargetEthernetPortAddress;
        end

        function setHostTargetEthernetPortAddress(obj,hostEthernetPortAddress)
            obj.HostTargetEthernetPortAddress=hostEthernetPortAddress;
        end

        function isEnabled=getGenerateSoftwareInterfaceModelEnable(obj)
            isEnabled=obj.EnableGenerateSoftwareInterfaceModel;
        end

        function setGenerateSoftwareInterfaceModelEnable(obj,enable)
            obj.EnableGenerateSoftwareInterfaceModel=enable;
        end

        function isEnabled=getGenerateHostInterfaceModelEnable(obj)
            isEnabled=obj.EnableGenerateHostInterfaceModel;
        end

        function isEnabled=getGenerateHostInterfaceScriptEnable(obj)
            isEnabled=obj.EnableGenerateHostInterfaceScript;
        end

        function hostInterface=getHostTargetInterface(obj)
            hostInterface=obj.HostTargetInterface;
        end

        function[status,result,validateCell]=runSWInterfaceGen(obj)



            validateGenericIPPlatform(obj);

            hTurnkey=getTurnkeyObject(obj);



            hTurnkey.updateSoftwareInterfaceList;


            hTurnkey.updateHostInterfaceList;

            status=true;
            result='';
            validateCell={};


            if obj.GenerateDeviceTree







                nodeLabel="mwipcore0";
                obj.IPCoreDeviceName=nodeLabel;
                hTurnkey.registerDeviceTreeNames(obj.IPCoreDeviceName);
                [status2,result2,validateCell2]=hTurnkey.generateDeviceTree;
                status=status&&status2;
                result=sprintf('%s\n%s\n',result,result2);
                validateCell=[validateCell,validateCell2];
            end


            if obj.GenerateSoftwareInterfaceModel
                [status2,result2,validateCell2]=hTurnkey.generateInterfaceModel;
                status=status&&status2;
                result=sprintf('%s\n%s\n',result,result2);
                validateCell=[validateCell,validateCell2];
            end


            if obj.GenerateHostInterfaceScript
                [status2,result2,validateCell2]=hTurnkey.generateInterfaceScript;
                status=status&&status2;
                result=sprintf('%s\n%s\n',result,result2);
                validateCell=[validateCell,validateCell2];
            end


            if obj.GenerateHostInterfaceModel
                [status1,result1,validateCell1]=hTurnkey.generateHostInterfaceModel;
                status=status&&status1;
                result=sprintf('%s\n%s\n',result,result1);
                validateCell=[validateCell,validateCell1];
            end

        end

        function[status,result,validateCell]=runEmbeddedSystemBuild(obj)

            validateGenericIPPlatform(obj);


            hRD=obj.getReferenceDesignPlugin;
            if~isempty(hRD)
                if~isempty(hRD.PostBuildBitstreamFcn)
                    if obj.getEmbeddedExternalBuild
                        error(message('hdlcommon:workflow:ExternalBuildNotSupported'));
                    end
                end
            end


            [status,result,validateCell]=obj.hETool.runEmbeddedSystemBuild;


            if status
                [status2,log2]=hdlturnkey.plugin.runCallbackPostBuildBitstream(obj.hD);
                status=status&&status2;
                result=sprintf('%s\n%s\n',result,log2);
            end


            if obj.hD.cmdDisplay&&obj.getEmbeddedExternalBuild

                hdldisp(result);

                downstream.tool.displayValidateCell(validateCell);
            else
                taskName=message('HDLShared:hdldialog:HDLWAEmbeddedSystemBuild').getString;
                fileName=message('HDLShared:hdldialog:HDLWAEmbeddedSystemBuildENGLISH').getString;
                result=obj.hD.logDisplayToolResult(status,result,taskName,fileName,false,validateCell);
            end
        end

        function[status,result,validateCell]=runEmbeddedDownloadBitstream(obj)

            validateGenericIPPlatform(obj);

            [status,result,validateCell]=obj.hETool.runEmbeddedDownloadBitstream;


            taskName=message('HDLShared:hdldialog:HDLWAProgramTargetDevice').getString;
            fileName=message('HDLShared:hdldialog:HDLWAProgramTargetDeviceENGLISH').getString;
            result=obj.hD.logDisplayToolResult(status,result,taskName,fileName,false,validateCell);
        end


        function validateIPCoreWorkflow(obj)






            if~obj.hD.isMLHDLC&&~obj.hD.isMDS
                dutName=obj.hD.hCodeGen.getDutName;
                if~downstream.tool.isDUTTopLevel(dutName)&&...
                    ~downstream.tool.isDUTModelReference(dutName)&&...
                    ~strcmp(get_param(dutName,'TreatAsAtomicUnit'),'on')


                    msgobj=message('hdlcommon:workflow:AtomicSubsystemTurnOn');
                    msgStr=msgobj.getString;
                    taskID='com.mathworks.HDL.SetTargetDevice';
                    actionLink=sprintf('<a href="matlab:set_param(%s,''TreatAsAtomicUnit'',''on'');hdlturnkey.resetHDLWATask(''%s'');">%s</a>',...
                    cleanBlockNameForQuotedDisp(dutName),taskID,msgStr);
                    error(message('hdlcommon:workflow:AtomicSubsystem',dutName,actionLink,dutName));
                end
                modelName=obj.hD.hCodeGen.getModelName;
                if(strcmp(hdlget_param(modelName,'FrameToSampleConversion'),'on')&&...
                    hdlget_param(modelName,'SamplesPerCycle')>1)
                    error(message('hdlcommon:workflow:FramesSamplesPerCycle'));
                end
            end





            lockCurrentDir(obj);
        end
        function ret=isEToolClassExist(obj)%#ok<MANU>
            ret=exist('hdlturnkey.tool.EmbeddedToolDriver','class');
        end
        function validateGenericIPPlatform(obj)
            if obj.isGenericIPPlatform
                error(message('hdlcommon:workflow:NotWithGenericIP'));
            end
        end
        function ret=isIPPlatformLoaded(obj)
            ret=~isempty(obj.hIPEmitter);
        end
        function validateIPPlatformLoaded(obj)
            if~obj.isIPPlatformLoaded||obj.hD.isBoardEmpty
                error(message('hdlcommon:workflow:NotWithUninitIP'));
            end
        end
        function ret=isEmbeddedToolLoaded(obj)
            ret=~isempty(obj.hETool);
        end

        function workflowEnum=getworklfowEnum(obj)
            workflowEnum=obj.WorkflowEnum;
        end

    end



    methods




        function setIPCoreName(obj,name)
            validateIPPlatformLoaded(obj);

            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPCoreName(name);
        end
        function name=getIPCoreName(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            name=hIPCore.getIPCoreName;
        end
        function name=getIPCoreDeviceName(obj)
            name=obj.IPCoreDeviceName;
        end


        function setIPCoreVersion(obj,ver)
            validateIPPlatformLoaded(obj);

            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPCoreVersion(ver);
        end
        function ver=getIPCoreVersion(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            ver=hIPCore.getIPCoreVersion;
        end


        function setTimestamp(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setTimestamp;
        end
        function ts=getTimestamp(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            ts=hIPCore.getTimestamp;
        end
        function tsNum=getTimestampNum(obj)
            tsNum=str2double(obj.getTimestampStr);
        end
        function tsStr=getTimestampStr(obj)
            tsStr=datestr(obj.getTimestamp,'yymmddHHMM');
        end


        function folder=getIPCoreFolder(obj)
            folder='';
            if obj.isIPPlatformLoaded
                hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
                folder=hIPCore.getIPCoreFolder;
            end
        end


        function defaultCheckpointfolder=getIPCoreDesignCheckpointFile(obj)
            defaultCheckpointfolder='';
            if obj.isIPPlatformLoaded
                hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
                defaultCheckpointfolder=hIPCore.getDefaultCheckpointFolder;
            end
        end


        function value=getIPCoreCustomFile(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            value=hIPCore.getIPCoreCustomFile;
        end
        function setIPCoreCustomFile(obj,value)
            validateIPPlatformLoaded(obj);

            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPCoreCustomFile(value);
        end
        function value=getIPCustomFileList(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            value=hIPCore.getIPCustomFileList;
        end


        function setIPTopCustomFile(obj,value)
            validateIPPlatformLoaded(obj);

            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPTopCustomFile(value);
        end
        function value=getIPTopCustomFileList(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            value=hIPCore.getIPTopCustomFileList;
        end
        function hasTopFile=hasCustomIPTopHDLFile(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hasTopFile=hIPCore.hasCustomIPTopHDLFile;
        end


        function setAXI4ReadbackEnable(obj,AXI4ReadbackEnableOn)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setAXI4ReadbackEnable(AXI4ReadbackEnableOn);
        end
        function AXI4ReadbackEnableOn=getAXI4ReadbackEnable(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            AXI4ReadbackEnableOn=hIPCore.getAXI4ReadbackEnable;
        end



        function setIDWidth(obj,value)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIDWidth(value);
        end

        function AXIIDWidth=getIDWidth(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            AXIIDWidth=hIPCore.getIDWidth;
        end

        function validateCell=adjustIDWidthBoxGUI(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            validateCell=hIPCore.adjustIDWidthBoxGUI;
        end
        function enablIDWidthEnboxGUI=getIDWidthEnboxGUI(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            enablIDWidthEnboxGUI=hIPCore.getIDWidthEnboxGUI;
        end



        function adjustIDWidthValue(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.adjustIDWidthValue;
        end



        function validateCell=adjustAXI4SlaveEnable(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            validateCell=hIPCore.adjustAXI4SlaveEnable;
        end
        function setAXI4SlaveEnable(obj,enableAXI4Slave)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setAXI4SlaveEnable(enableAXI4Slave);
        end
        function enableAXI4Slave=getAXI4SlaveEnable(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            enableAXI4Slave=hIPCore.getAXI4SlaveEnable;
        end

        function adjustAXI4SlaveEnableGUI(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.adjustAXI4SlaveEnableGUI;
        end
        function enableAXI4SlaveGUI=getAXI4SlaveEnableGUI(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            enableAXI4SlaveGUI=hIPCore.getAXI4SlaveEnableGUI;
        end


        function exposeDUTClockEnab=getDUTClockEnable(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            exposeDUTClockEnab=hIPCore.getDUTClockEnable;
        end
        function setDUTClockEnable(obj,exposeDUTClockenab)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setDUTClockEnable(exposeDUTClockenab);
        end

        function enableDUTClockenab=getDUTClockEnableGUI(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            enableDUTClockenab=hIPCore.getDUTClockEnableGUI;
        end


        function exposeDUTCEOut=getDUTCEOut(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            exposeDUTCEOut=hIPCore.getDUTCEOut;
        end
        function setDUTCEOut(obj,exposeDUTCEOut)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setDUTCEOut(exposeDUTCEOut);
        end

        function setInsertAXI4PipelineRegisterEnable(obj,AXI4SlavePortToPipelineRegisterRatioOn)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setInsertAXI4PipelineRegisterEnable(AXI4SlavePortToPipelineRegisterRatioOn);
        end
        function AXI4SlavePortToPipelineRegisterRatioOn=getInsertAXI4PipelineRegisterEnable(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            AXI4SlavePortToPipelineRegisterRatioOn=hIPCore.getInsertAXI4PipelineRegisterEnable;
        end



        function setIPDataCaptureBufferSize(obj,value)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPDataCaptureBufferSize(value);
        end
        function value=getIPDataCaptureBufferSize(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            value=hIPCore.getIPDataCaptureBufferSize;
        end


        function setIPDataCaptureSequenceDepth(obj,value)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPDataCaptureSequenceDepth(value);
        end
        function value=getIPDataCaptureSequenceDepth(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            value=hIPCore.getIPDataCaptureSequenceDepth;
        end


        function setIncludeDataCaptureControlLogicEnable(obj,value)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIncludeDataCaptureControlLogicEnable(value);
        end
        function value=getIncludeDataCaptureControlLogicEnable(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            value=hIPCore.getIncludeDataCaptureControlLogicEnable;
        end



        function reportPath=getIPCoreReportPath(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            reportPath=hIPCore.getIPCoreReportPath;
        end



        function setIPTestbench(obj,ison)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            hIPCore.setIPTestbench(ison);
        end
        function ison=getIPTestbench(obj)
            hIPCore=obj.getIPCore(obj.hD.hCodeGen.getDutName);
            ison=hIPCore.getIPTestbench;
        end



        function setIPCoreReportStatus(obj,ison)

            obj.IPReport=ison;
        end
        function ison=getIPCoreReportStatus(obj)
            ison=obj.IPReport;
        end


        function validateCell=validateTargetReferenceDesign(obj)

            validateCell={};

            if obj.hD.isIPCoreGen&&~obj.hD.isGenericIPPlatform



                validateCellReloadRD=obj.reloadReferenceDesignPlugin;
                validateCell=[validateCell,validateCellReloadRD];

                if obj.hD.isDLWorkflow

                    hRD=obj.getReferenceDesignPlugin;
                    hRD.validateReferenceDesignForDeepLearning;
                end


                validateCellRDP=obj.validateRDPlugin;
                validateCell=[validateCell,validateCellRDP];


                validateCellCallback=hdlturnkey.plugin.runCallbackPostTargetReferenceDesign(obj.hD);
                validateCell=[validateCell,validateCellCallback];


                validateCellNoAXI=obj.adjustAXI4SlaveEnable;
                validateCell=[validateCell,validateCellNoAXI];
                validateCellRDOptionalAXIMstr=obj.hdlverifierIPcheck;
                validateCell=[validateCell,validateCellRDOptionalAXIMstr];
                obj.adjustAXI4SlaveEnableGUI;
            end
        end
        function validateCell=reloadReferenceDesignPlugin(obj)
            if obj.isRDListLoaded



                validateCell=obj.hRDList.reloadRDPlugin;



                ExecMode=obj.hD.get('ExecutionMode');
                IPCacheValue=obj.getUseIPCache;
                ProgrammingMethod=obj.getProgrammingMethod;



                obj.hRDList.refreshReferenceDesign;




                hTurnkey=obj.getTurnkeyObject;
                ExecMode_New=obj.hD.get('ExecutionMode');



                if~strcmp(ExecMode,ExecMode_New)
                    hTurnkey.hExecMode.setExecutionMode(ExecMode);
                end
                obj.setUseIPCache(IPCacheValue);
                obj.setProgrammingMethod(ProgrammingMethod);
            end
        end


        function validateCell=hdlverifierIPcheck(obj)
            validateCell={};
            hRD=obj.hD.hIP.getReferenceDesignPlugin;
            if hRD.hashdlverifierIP
                msgObject=message('hdlcommon:workflow:TurnoffAddJTAGMATLABasAXIWarn',...
                DAStudio.message('HDLShared:hdldialog:HDLWAInsertJTAGMATLABasAXI'));
                validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);
            end

        end

        function setIPRepository(obj,iprep)
            validateIPPlatformLoaded(obj);
            if~isempty(iprep)

                ipRepFolderMsg=message('HDLShared:hdldialog:HDLWAIPRepositoryStr');
                downstream.tool.validateFolder(iprep,ipRepFolderMsg.getString);
                downstream.tool.validatePathWhiteSpace(iprep,ipRepFolderMsg.getString);
            end
            obj.IPRepository=iprep;
        end
        function iprep=getIPRepository(obj)
            iprep=obj.IPRepository;
        end




        function tool=getEmbeddedTool(obj)
            tool=obj.EmbeddedToolName;
        end

        function folder=getEmbeddedToolProjFolder(obj)
            folder='';
            if obj.isEmbeddedToolLoaded
                folder=obj.hETool.getToolProjectFolder;
            end
        end
        function projectLink=getEmbeddedToolProjectLink(obj)
            projectLink='';
            if obj.isEmbeddedToolLoaded
                projectLink=obj.hETool.getOpenProjectLink;
            end

        end
        function project=getToolProjectFileName(obj)
            project='';
            if obj.isEmbeddedToolLoaded
                project=obj.hETool.getToolProjectFileName;
            end
        end

        function setEmbeddedExternalBuild(obj,ison)
            obj.ExternalBuild=ison;
        end
        function ison=getEmbeddedExternalBuild(obj)
            ison=obj.ExternalBuild;
        end

        function os=getOperatingSystem(obj)
            os='';
            if obj.isEmbeddedToolLoaded
                os=obj.hETool.getOperatingSystem;
            end
        end
        function setOperatingSystem(obj,os)
            if obj.isEmbeddedToolLoaded
                obj.hETool.setOperatingSystem(os);
            end
        end
        function oslist=getOperatingSystemAll(obj)
            oslist={''};
            if obj.isEmbeddedToolLoaded
                oslist=obj.hETool.getOperatingSystemAll;
            end
        end

        function program=getProgrammingMethod(obj)
            program=hdlcoder.ProgrammingMethod.JTAG;
            if obj.isEmbeddedToolLoaded
                program=obj.hETool.getProgrammingMethod;
            end
        end
        function setProgrammingMethod(obj,program)
            if obj.isEmbeddedToolLoaded
                obj.hETool.setProgrammingMethod(program);
            end
        end
        function programlist=getProgrammingMethodAll(obj)
            programlist=hdlcoder.ProgrammingMethod.JTAG;
            if obj.isEmbeddedToolLoaded
                programlist=obj.hETool.getProgrammingMethodAll;
            end
        end
        function refreshProgrammingMethod(obj)
            obj.hETool.refreshProgrammingMethod;
        end
        function ret=enableProgrammingMethod(obj)


            programValue=obj.getProgrammingMethod;
            programList=obj.getProgrammingMethodAll;

            if programValue==hdlcoder.ProgrammingMethod.Custom||length(programList)==1
                ret=false;
            else
                ret=true;
            end
        end

        function val=getUseIPCache(obj)
            val=false;
            if obj.isEmbeddedToolLoaded
                val=obj.hETool.getUseIPCache;
            end
        end
        function msg=checkUseIPCache(obj,val)

            msg=[];
            if obj.isEmbeddedToolLoaded
                msg=obj.hETool.checkUseIPCache(val);
            end
        end
        function setUseIPCache(obj,val)

            if obj.isEmbeddedToolLoaded
                obj.hETool.setUseIPCache(val);
            end
        end
        function ret=enableUseIPCache(obj)

            ret=true;
            if obj.isEmbeddedToolLoaded
                ret=obj.hETool.enableUseIPCache;
            end
        end
        function ret=enableObjective(obj)
            ret=true;
            if obj.isEmbeddedToolLoaded
                ret=obj.hETool.enableObjective;
            end
        end
        function refreshDefaultUseIPCache(obj)

            val=false;
            if obj.isEmbeddedToolLoaded
                val=obj.hETool.getDefaultUseIPCache;
            end
            obj.setUseIPCache(val);
        end

        function setReportTimingFailure(obj,ReportTimingFailure)
            obj.ReportTimingOption=ReportTimingFailure;
        end
        function ReportTimingFailure=getReportTimingFailure(obj)
            ReportTimingFailure=obj.ReportTimingOption;
        end
        function setReportTimingFailureTolerance(obj,ReportTimingFailureTolerance)
            obj.ReportTimingFailureToleranceOption=ReportTimingFailureTolerance;
        end
        function ReportTimingFailureTolerance=getReportTimingFailureTolerance(obj)
            ReportTimingFailureTolerance=obj.ReportTimingFailureToleranceOption;
        end


        function hBoardParams=getSSHBoardParams(obj)
            try
                if obj.hD.isAlteraIP
                    hBoardParams=codertarget.hdlcintel.internal.BoardParameters;
                elseif obj.hD.isXilinxIP
                    hBoardParams=codertarget.hdlcxilinx.internal.BoardParameters;
                else
                    error('Board vendor must be either ''Xilinx'' or ''Altera''.');
                end
            catch


                hBoardParams=[];
            end
        end


        function ipAddr=getIPAddress(obj)
            hBoardParams=obj.getSSHBoardParams;
            if isempty(hBoardParams)
                ipAddr='';
            else
                ipAddr=hBoardParams.getParam('ipaddress');
            end
        end
        function setIPAddress(obj,ipAddr)
            hBoardParams=obj.getSSHBoardParams;
            if~isempty(hBoardParams)
                downstream.tool.validateIPAddress(ipAddr);
                hBoardParams.setParam('ipaddress',ipAddr);
            end
        end

        function username=getSSHUsername(obj)
            hBoardParams=obj.getSSHBoardParams;
            if isempty(hBoardParams)
                username='';
            else
                username=hBoardParams.getParam('username');
            end
        end
        function setSSHUsername(obj,username)
            hBoardParams=obj.getSSHBoardParams;
            if~isempty(hBoardParams)
                hBoardParams.setParam('username',username);
            end
        end

        function password=getSSHPassword(obj)
            hBoardParams=obj.getSSHBoardParams;
            if isempty(hBoardParams)
                password='';
            else
                password=hBoardParams.getParam('password');
            end
        end
        function password=getSSHPasswordForDisplay(obj)

            password=obj.getSSHPassword;
            password=repmat('*',size(password));
        end
        function setSSHPassword(obj,password)
            hBoardParams=obj.getSSHBoardParams;
            if~isempty(hBoardParams)
                hBoardParams.setParam('password',password);
            end
        end
    end


    methods
        function bitStream=getBitstreamPath(obj)
            bitStream=obj.hETool.getBitstreamPath;
        end
    end

    methods(Access=protected)
        function dutNameList=getIPCoreDUTList(obj)
            dutNameList=obj.hIPCoreList.getDUTNameList;
        end

        function hIPCore=getIPCore(obj,dutName)
            hIPCore=obj.hIPCoreList.getIPCore(dutName);
        end

        function hIPCore=addIPCore(obj,dutName)
            hIPCore=obj.hIPCoreList.addIPCoreForDUT(dutName);
        end
    end
end





