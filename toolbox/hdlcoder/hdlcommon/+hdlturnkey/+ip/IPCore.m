




classdef IPCore<handle





    properties(SetAccess=protected)
        DUTName='';
    end

    properties(Access=protected)
        hAddrList=[];

        hTable=[];







        DefaultBusInterface=[];
    end


    properties(Access=protected)
        hIPDriver=[];
    end

    properties(Dependent,Access=protected)
hIPEmitter
hD
    end


    properties(Access=protected)

        IPName='';
        IPVer='';
        IPFolder='';
        DefaultCheckpointfolder='';

        AXI4ReadbackEn=false;
        AXI4SlaveEn=true;
        AXI4SlaveEnGUIEnable=true;
        DUTClockEnPort=false;
        DUTClockEnPGUI=false;
        DUTCEOutPort=false;
        AXI4SlavePortToPipelineRegisterRatio='auto';
        IPTimestamp=datenum(0);
        IPTestbench=false;
        IPDataCaptureBufferSize='128';
        IPDataCaptureSequenceDepth='1';
        IncludeDataCaptureControlLogicEnable=false;
        IDWidthValue='12';
        IDWidthEn=true;
        IDAdjust=false;


        IPCustomFile={};
        IPCustomFileStr='';


        IPTopCustomFile={};
        IPTopCustomFileStr='';
    end

    properties(Constant,Access=protected)
        IPCoreFolderStr='ipcore';
        DefaultCheckpointFolderStr='checkpoint/system_routed.dcp';
    end


    methods
        function obj=IPCore(hIPD,dutName)


            obj.hIPDriver=hIPD;
            obj.DUTName=dutName;

            obj.hTable=hdlturnkey.table.TargetInterfaceTable(obj);



        end
    end


    methods
        function hIPE=get.hIPEmitter(obj)
            hIPE=obj.hIPDriver.hIPEmitter;
        end

        function hDI=get.hD(obj)
            hDI=obj.hIPDriver.hD;
        end
    end

    methods
        function initIPParameter(obj)



            obj.IPName=obj.hIPEmitter.getDefaultIPCoreName;
            obj.IPVer=obj.hIPEmitter.getDefaultIPCoreVer;
            updateIPFolder(obj);





























        end
    end



    methods

        function setIPCoreName(obj,name)

            obj.hIPEmitter.validateIPCoreName(name);
            obj.IPName=name;
            updateIPFolder(obj);
            obj.hD.saveIpCoreNameToModel(obj.hD.hCodeGen.getDutName,name);
        end
        function name=getIPCoreName(obj)
            name=obj.IPName;
        end


        function setIPCoreVersion(obj,ver)

            obj.hIPEmitter.validateIPCoreVerShared(ver);
            obj.hIPEmitter.validateIPCoreVer(ver);
            obj.IPVer=ver;
            updateIPFolder(obj);
            obj.hD.saveIpCoreVersionToModel(obj.hD.hCodeGen.getDutName,ver);
        end
        function ver=getIPCoreVersion(obj)
            ver=obj.IPVer;
        end


        function setTimestamp(obj)
            obj.IPTimestamp=now;
        end
        function ts=getTimestamp(obj)
            ts=obj.IPTimestamp;
        end
        function tsNum=getTimestampNum(obj)
            tsNum=str2double(obj.getTimestampStr);
        end
        function tsStr=getTimestampStr(obj)
            tsStr=datestr(obj.IPTimestamp,'yymmddHHMM');
        end


        function folder=getIPCoreFolder(obj)


            updateIPFolder(obj);
            folder=obj.IPFolder;

        end


        function defaultCheckpointfolder=getDefaultCheckpointFolder(obj)
            updateDefaultCheckpointFolder(obj);
            defaultCheckpointfolder=obj.DefaultCheckpointfolder;
        end


        function value=getIPCoreCustomFile(obj)
            value=obj.IPCustomFileStr;
        end
        function setIPCoreCustomFile(obj,value)

            if~strcmp(obj.IPCustomFileStr,value)

                ipCustomFileMsg=message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFilesStr');
                downstream.tool.checkNonASCII(value,ipCustomFileMsg.getString);
                [customFile,outFileStr]=obj.hIPEmitter.parseCustomFileStr(value);
                obj.IPCustomFile=customFile;
                obj.IPCustomFileStr=outFileStr;
            end
            obj.hD.saveIpCoreAdditionalSourceFileToModel(obj.hD.hCodeGen.getDutName,value);
        end
        function value=getIPCustomFileList(obj)
            value=obj.IPCustomFile;
        end


        function setIPTopCustomFile(obj,value)

            if~strcmp(obj.IPTopCustomFileStr,value)

                ipCustomFileMsg=message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFilesStr');
                downstream.tool.checkNonASCII(value,ipCustomFileMsg.getString);
                [customFile,outFileStr]=obj.hIPEmitter.parseCustomFileStr(value);
                obj.IPTopCustomFile=customFile;
                obj.IPTopCustomFileStr=outFileStr;
            end
        end
        function value=getIPTopCustomFileList(obj)
            value=obj.IPTopCustomFile;
        end
        function hasTopFile=hasCustomIPTopHDLFile(obj)
            hasTopFile=~isempty(obj.IPTopCustomFile);
        end











        function setAXI4ReadbackEnable(obj,AXI4ReadbackEnableOn)
            obj.AXI4ReadbackEn=AXI4ReadbackEnableOn;
            obj.hD.saveIpCoreAXI4RegisterReadbackToModel(obj.hD.hCodeGen.getDutName,AXI4ReadbackEnableOn);
        end
        function AXI4ReadbackEnableOn=getAXI4ReadbackEnable(obj)
            AXI4ReadbackEnableOn=obj.AXI4ReadbackEn;
        end



        function setIDWidth(obj,value)
            obj.validateIDWidth(value);
            if(obj.hD.isIPCoreGen)
                if(obj.hD.isGenericIPPlatform)
                    interfaceIDList=obj.hD.hTurnkey.getAssignedInterfaceIDList;
                    for ii=1:length(interfaceIDList)
                        interfaceID=interfaceIDList{ii};
                        hInterface=obj.hD.hTurnkey.getInterface(interfaceID);
                        if(~isempty(hInterface))
                            if hInterface.isAXI4Interface
                                IDWidthNumber=str2double(value);
                                hInterface.IDWidth=IDWidthNumber;
                                obj.hD.saveIpAXISlaveIDWidthToModel(obj.hD.hCodeGen.getDutName,value);
                                break
                            else
                                obj.IDWidthValue=(value);
                            end
                        end
                    end
                end
            end
        end

        function AXIIDWidth=getIDWidth(obj)
            AXIIDWidth='12';
            if(obj.hD.isIPCoreGen)
                interfaceIDList=obj.hD.hTurnkey.getAssignedInterfaceIDList;
                for ii=1:length(interfaceIDList)
                    interfaceID=interfaceIDList{ii};
                    hInterface=obj.hD.hTurnkey.getInterface(interfaceID);
                    if(~isempty(hInterface))
                        if hInterface.isAXI4Interface
                            AXIIDWidthNum=hInterface.IDWidth;
                            AXIIDWidth=num2str(AXIIDWidthNum);
                            break
                        else
                            AXIIDWidth=obj.IDWidthValue;
                        end
                    end
                end
            end
        end

        function validateCell=adjustIDWidthBoxGUI(obj)
            validateCell={};
            if(obj.hD.isIPCoreGen)
                if(~obj.hD.isGenericIPPlatform)
                    obj.IDWidthEn=false;
                    AXIIDWidth=obj.getIDWidth;
                else
                    obj.IDWidthEn=true;
                    interfaceIDList=obj.hD.hTurnkey.getAssignedInterfaceIDList;
                    for ii=1:length(interfaceIDList)
                        interfaceID=interfaceIDList{ii};
                        hInterface=obj.hD.hTurnkey.getInterface(interfaceID);
                        if(~isempty(hInterface))
                            if~hInterface.isAXI4Interface
                                obj.IDWidthEn=false;
                                AXIIDWidth='';
                            else
                                obj.IDWidthEn=true;
                                AXIIDWidth=obj.getIDWidth;
                                break
                            end
                        end
                    end
                end
                obj.hD.saveIpAXISlaveIDWidthToModel(obj.hD.hCodeGen.getDutName,AXIIDWidth);
                if obj.IDAdjust
                    obj.IDWidthEn=true;
                    msgObject=message('hdlcommon:workflow:IDWidthAdjusted',...
                    DAStudio.message('HDLShared:hdldialog:HDLWAAXI4SlaveIDWidth'));
                    validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);
                end
            end
        end
        function enablIDWidthEnboxGUI=getIDWidthEnboxGUI(obj)
            enablIDWidthEnboxGUI=obj.IDWidthEn;
        end



        function adjustIDWidthValue(obj)
            if(obj.hD.isIPCoreGen)
                MPSoCAdjust=false;
                if obj.hD.isVivado||obj.hD.isQuartus||obj.hD.isQuartusPro
                    interfaceIDList=obj.hD.hTurnkey.getAssignedInterfaceIDList;


                    for ii=1:length(interfaceIDList)
                        interfaceID=interfaceIDList{ii};
                        hInterface=obj.hD.hTurnkey.getInterface(interfaceID);
                        if(~isempty(hInterface))
                            if hInterface.isAXI4Interface
                                RD=obj.hD.hIP.getReferenceDesignPlugin;
                                if~isempty(RD)
                                    MstraddrSpace=RD.getAXISlaveMasterAddressSpace;
                                    BaseIDWidth=RD.getAXISlaveIDWidth;
                                    isInsertJTAGAXIMasterSelected=RD.getJTAGAXIParameterValue;




                                    if isInsertJTAGAXIMasterSelected
                                        if iscell(MstraddrSpace)
                                            AXIMasterCount=length(MstraddrSpace);
                                            MPSocMatch=regexp(MstraddrSpace,'zynq_ultra_ps_e');
                                            if~(isempty(MPSocMatch))
                                                if find(cellfun('length',MPSocMatch))
                                                    IDWidthAdjusted=16+ceil(log2(AXIMasterCount));
                                                    MPSoCAdjust=true;
                                                end
                                            end
                                            if~MPSoCAdjust
                                                IDWidthAdjusted=12+ceil(log2(AXIMasterCount+1));
                                            end
                                            if BaseIDWidth~=IDWidthAdjusted
                                                AXI4_IDWidth=IDWidthAdjusted;
                                                obj.IDAdjust=true;
                                            else
                                                AXI4_IDWidth=BaseIDWidth;
                                            end
                                            obj.IDWidthEn=true;
                                        else
                                            MPSocMatch=regexp(MstraddrSpace,'zynq_ultra_ps_e');
                                            if~(isempty(MPSocMatch))
                                                if find(cellfun('length',MPSocMatch))
                                                    IDWidthAdjusted=16+1;
                                                    MPSoCAdjust=true;
                                                end
                                            end
                                            if~MPSoCAdjust
                                                IDWidthAdjusted=12+1;
                                            end
                                            if BaseIDWidth~=IDWidthAdjusted
                                                AXI4_IDWidth=IDWidthAdjusted;
                                                obj.IDAdjust=true;
                                            else
                                                AXI4_IDWidth=BaseIDWidth;
                                            end
                                            obj.IDWidthEn=true;
                                        end
                                    else
                                        if iscell(MstraddrSpace)
                                            AXIMasterCount=length(MstraddrSpace);
                                            MPSocMatch=regexp(MstraddrSpace,'zynq_ultra_ps_e');
                                            if~(isempty(MPSocMatch))
                                                if find(cellfun('length',MPSocMatch))
                                                    IDWidthAdjusted=16+ceil(log2(AXIMasterCount));
                                                    MPSoCAdjust=true;
                                                end
                                            end
                                            if~MPSoCAdjust
                                                IDWidthAdjusted=12+ceil(log2(AXIMasterCount));
                                            end
                                            if BaseIDWidth~=IDWidthAdjusted
                                                AXI4_IDWidth=IDWidthAdjusted;
                                                obj.IDAdjust=true;
                                            else
                                                AXI4_IDWidth=BaseIDWidth;
                                            end
                                            obj.IDWidthEn=true;
                                        else
                                            MPSocMatch=regexp(MstraddrSpace,'zynq_ultra_ps_e');
                                            if~(isempty(MPSocMatch))
                                                if find(cellfun('length',MPSocMatch))
                                                    IDWidthAdjusted=16;
                                                    MPSoCAdjust=true;
                                                end
                                            end
                                            if~MPSoCAdjust
                                                IDWidthAdjusted=12;
                                            end
                                            if BaseIDWidth~=IDWidthAdjusted
                                                AXI4_IDWidth=IDWidthAdjusted;
                                                obj.IDAdjust=true;
                                            else
                                                AXI4_IDWidth=BaseIDWidth;
                                            end
                                            obj.IDWidthEn=true;
                                        end
                                    end
                                    hInterface.IDWidth=AXI4_IDWidth;
                                    IDWidth=num2str(AXI4_IDWidth);
                                    obj.hD.saveIpAXISlaveIDWidthToModel(obj.hD.hCodeGen.getDutName,IDWidth);
                                end
                            end
                        end
                    end
                end
            end
        end



        function validateCell=adjustAXI4SlaveEnable(obj)
            validateCell={};
            if(obj.hD.isIPCoreGen)
                if(obj.hD.isGenericIPPlatform)
                    hBus=obj.hD.hTurnkey.getDefaultBusInterface;
                    if(hBus.hIPCoreAddr.isAnyAddressAssigned||obj.hD.hTurnkey.isCoProcessorMode)
                        if(~obj.AXI4SlaveEn)
                            msgObject=message('hdlcommon:workflow:NoAXI4SlaveGenericWarn',...
                            DAStudio.message('HDLShared:hdldialog:HDLWAGenerateAXI4Slave'));
                            validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);
                            obj.AXI4SlaveEn=true;
                        end
                    end
                else
                    if(obj.hD.hIP.isRDListLoaded)



                        RD=obj.hD.hIP.getReferenceDesignPlugin;
                        isInsertJTAGAXI=RD.getJTAGAXIParameterValue;
                        if isInsertJTAGAXI
                            obj.AXI4SlaveEn=true;
                        end


                        if(~obj.AXI4SlaveEn&&RD.isAXI4SlaveInterfaceInUse)
                            msgObject=message('hdlcommon:workflow:NoAXI4SlaveRefDesignWarn2',...
                            DAStudio.message('HDLShared:hdldialog:HDLWAGenerateAXI4Slave'));
                            validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);

                        elseif(obj.AXI4SlaveEn&&~RD.isAXI4SlaveInterfaceInUse)
                            msgObject=message('hdlcommon:workflow:NoAXI4SlaveRefDesignWarn1',...
                            DAStudio.message('HDLShared:hdldialog:HDLWAGenerateAXI4Slave'));
                            validateCell{end+1}=hdlvalidatestruct('Warning',msgObject);
                        end
                        obj.AXI4SlaveEn=RD.isAXI4SlaveInterfaceInUse;
                    end
                end
            end
            obj.hD.saveIpCoreAXI4SlaveEnableToModel(obj.hD.hCodeGen.getDutName,obj.AXI4SlaveEn);

            if(obj.AXI4SlaveEn)

                obj.setDUTClockEnable(~obj.AXI4SlaveEn);
            end
            obj.setDUTClockEnableGUI(~obj.AXI4SlaveEn);

            obj.hD.saveIpCoreDUTClockEnableToModel(obj.hD.hCodeGen.getDutName,obj.DUTClockEnPort);
        end
        function setAXI4SlaveEnable(obj,enableAXI4Slave)
            obj.AXI4SlaveEn=enableAXI4Slave;
            obj.hD.saveIpCoreAXI4SlaveEnableToModel(obj.hD.hCodeGen.getDutName,enableAXI4Slave);

            if(obj.AXI4SlaveEn)

                obj.setDUTClockEnable(~obj.AXI4SlaveEn);
            end
            obj.setDUTClockEnableGUI(~obj.AXI4SlaveEn);

            obj.hD.saveIpCoreDUTClockEnableToModel(obj.hD.hCodeGen.getDutName,obj.DUTClockEnPort);
        end
        function enableAXI4Slave=getAXI4SlaveEnable(obj)
            enableAXI4Slave=obj.AXI4SlaveEn;
        end

        function adjustAXI4SlaveEnableGUI(obj)



            if(obj.hD.isIPCoreGen)
                if(obj.hD.isGenericIPPlatform)
                    hBus=obj.hD.hTurnkey.getDefaultBusInterface;
                    if(hBus.hIPCoreAddr.isAnyAddressAssigned||obj.hD.hTurnkey.isCoProcessorMode)
                        obj.AXI4SlaveEnGUIEnable=false;
                    else
                        obj.AXI4SlaveEnGUIEnable=true;
                    end
                else
                    obj.AXI4SlaveEnGUIEnable=false;
                end
            end
        end
        function enableAXI4SlaveGUI=getAXI4SlaveEnableGUI(obj)
            enableAXI4SlaveGUI=obj.AXI4SlaveEnGUIEnable;
        end

        function setDUTClockEnable(obj,DUTClockEnPort)
            obj.DUTClockEnPort=DUTClockEnPort;
            obj.hD.saveIpCoreDUTClockEnableToModel(obj.hD.hCodeGen.getDutName,DUTClockEnPort);
        end
        function DUTClockEnPort=getDUTClockEnable(obj)
            DUTClockEnPort=obj.DUTClockEnPort;
        end
        function setDUTClockEnableGUI(obj,DUTClockEnPGUI)
            obj.DUTClockEnPGUI=DUTClockEnPGUI;
        end
        function DUTClockEnPGUI=getDUTClockEnableGUI(obj)
            DUTClockEnPGUI=obj.DUTClockEnPGUI;
        end

        function setDUTCEOut(obj,DUTCEOutPort)
            obj.DUTCEOutPort=DUTCEOutPort;
            obj.hD.saveIpCoreDUTClockEnableToModel(obj.hD.hCodeGen.getDutName,DUTCEOutPort);
        end
        function DUTCEOutPort=getDUTCEOut(obj)
            DUTCEOutPort=obj.DUTCEOutPort;
        end

        function setInsertAXI4PipelineRegisterEnable(obj,AXI4SlavePortToPipelineRegisterRatioOn)
            obj.AXI4SlavePortToPipelineRegisterRatio=AXI4SlavePortToPipelineRegisterRatioOn;
            obj.hD.saveAXI4SlavePortToPipelineRegisterRatioToModel(obj.hD.hCodeGen.getDutName,AXI4SlavePortToPipelineRegisterRatioOn);
        end
        function AXI4SlavePortToPipelineRegisterRatioOn=getInsertAXI4PipelineRegisterEnable(obj)
            AXI4SlavePortToPipelineRegisterRatioOn=obj.AXI4SlavePortToPipelineRegisterRatio;
        end


        function setIPDataCaptureBufferSize(obj,value)
            obj.IPDataCaptureBufferSize=value;
            obj.hD.saveIpCoreDataCaptureBufferSizeToModel(obj.hD.hCodeGen.getDutName,value);
        end
        function value=getIPDataCaptureBufferSize(obj)
            value=obj.IPDataCaptureBufferSize;
        end
        function setIPDataCaptureSequenceDepth(obj,value)
            obj.IPDataCaptureSequenceDepth=value;
            obj.hD.saveIpCoreDataCaptureSequenceDepthToModel(obj.hD.hCodeGen.getDutName,value);
        end
        function value=getIPDataCaptureSequenceDepth(obj)
            value=obj.IPDataCaptureSequenceDepth;
        end
        function setIncludeDataCaptureControlLogicEnable(obj,value)
            obj.IncludeDataCaptureControlLogicEnable=value;
            obj.hD.saveIpCoreDataCaptureIncludeCaptureControlToModel(obj.hD.hCodeGen.getDutName,value);
        end
        function value=getIncludeDataCaptureControlLogicEnable(obj)
            value=obj.IncludeDataCaptureControlLogicEnable;
        end


        function reportPath=getIPCoreReportPath(obj)
            reportFolder=fullfile(obj.getIPCoreFolder,obj.hIPEmitter.ReportFolder);
            reportPath=fullfile(reportFolder,obj.hIPEmitter.getReportFileName);
        end



        function setIPTestbench(obj,ison)

            obj.IPTestbench=ison;
        end
        function ison=getIPTestbench(obj)
            ison=obj.IPTestbench;
        end
    end


    methods(Access=protected)
        function updateIPFolder(obj)
            ipFolderName=obj.hIPEmitter.getIPCoreFolderName;
            obj.IPFolder=fullfile(obj.hD.getProjectFolder,...
            obj.IPCoreFolderStr,ipFolderName);
        end

        function updateDefaultCheckpointFolder(obj)
            obj.DefaultCheckpointfolder=fullfile(obj.hD.getProjectFolder,...
            obj.DefaultCheckpointFolderStr);
        end

        function validateIDWidth(obj,value)


            input=str2double(value);
            if(~isempty(value))

                if isempty(regexp(value,'\d*','all'))
                    error(message('hdlcommon:plugin:NotNumeric'));
                end
                if(input<=0)||(input>128)
                    error(message('hdlcommon:workflow:IntegerIDValue'));
                end
                verCell=regexp(value,'\.','split');
                if length(verCell)>1
                    error(message('hdlcommon:workflow:IntegerIDValue'));
                end
            end
        end
    end
end
