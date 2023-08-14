


classdef(Sealed)IPcoreWrapGenSb<hdlwfsmartbuild.WrapGenBase



    methods(Access=private)
        function obj=IPcoreWrapGenSb(hDI)
            obj=obj@hdlwfsmartbuild.WrapGenBase(hDI);
        end
    end

    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'ipcoreWrapGenSb')
                existObj=hdlWFSbMap('ipcoreWrapGenSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.IPcoreWrapGenSb(hDI);

                    hDI.addhdlWFSbMap('ipcoreWrapGenSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.IPcoreWrapGenSb(hDI);

                hDI.addhdlWFSbMap('ipcoreWrapGenSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)
            targetMap=containers.Map('KeyType','char','ValueType','any');
            this.setTargetMap(targetMap);
            depInforStr=hdlwfsmartbuild.serialize(targetMap);
            targetInterfaceMap=containers.Map('KeyType','char','ValueType','any');
            this.setTargetInterfaceMap(targetInterfaceMap);
            depInforStr=[depInforStr,';',hdlwfsmartbuild.serialize(targetInterfaceMap)];
            if this.hDI.isIPWorkflow||this.hDI.isSLRTWorkflow
                executionMode=this.setExecutionMode;
                depInforStr=[depInforStr,';','executionMode.',executionMode];
            end
            if this.hDI.isIPCoreGen
                ipcoreParamMap=containers.Map('KeyType','char','ValueType','any');
                this.setIPcoreParamMap(ipcoreParamMap);
                depInforStr=[depInforStr,';',hdlwfsmartbuild.serialize(ipcoreParamMap)];
                extFileNameTimeMap=containers.Map('KeyType','char','ValueType','any');
                this.setExtFileNameTimeMap(extFileNameTimeMap);
                depInforStr=[depInforStr,';',hdlwfsmartbuild.serialize(extFileNameTimeMap)];
                embeddedPrjMap=containers.Map('KeyType','char','ValueType','any');
                this.setEmbeddedPrjMap(embeddedPrjMap);
                depInforStr=[depInforStr,';',hdlwfsmartbuild.serialize(embeddedPrjMap)];
            else
                targetFreq=this.setTargetFreq;
                depInforStr=[depInforStr,';','Target Frequency.',targetFreq];
            end
        end

        function setEmbeddedPrjMap(this,embeddedPrjMap)
            embeddedPrjMap('Reference design')=this.hDI.hIP.getReferenceDesign;
            embeddedPrjMap('Reference design path')=this.hDI.hIP.getReferenceDesignPath;%#ok<NASGU>
        end

        function setExtFileNameTimeMap(this,extFileNameTimeMap)

            customFile=this.hDI.hIP.getIPCustomFileList;
            for i=1:length(customFile)
                fileName=customFile{i};
                timeStamp=this.mySbServe.getFileTimeStamp(fileName);
                extFileNameTimeMap(fileName)=timeStamp;
            end
        end

        function setTargetInterfaceMap(this,targetInterfaceMap)
            hTable=this.hDI.hTurnkey.hTable;
            inputPortNameList=hTable.hIOPortList.InputPortNameList;
            outputPortNameList=hTable.hIOPortList.OutputPortNameList;
            for ii=1:length(inputPortNameList)
                portName=inputPortNameList{ii};
                portInfoMap=containers.Map('KeyType','char','ValueType','any');
                this.getPortInfo(hTable,portName,portInfoMap);
                targetInterfaceMap(portName)=portInfoMap;
            end
            for ii=1:length(outputPortNameList)
                portName=outputPortNameList{ii};
                portInfoMap=containers.Map('KeyType','char','ValueType','any');
                this.getPortInfo(hTable,portName,portInfoMap);
                targetInterfaceMap(portName)=portInfoMap;
            end
        end

        function getPortInfo(this,hTable,portName,portInfoMap)%#ok<INUSL>
            hIOPort=hTable.hIOPortList.getIOPort(portName);
            portNameStr=portName;
            portInfoMap('Port Name')=portNameStr;
            portTypeStr=hIOPort.getPortTypeStr;
            portInfoMap('Port Type')=portTypeStr;
            portDataType=hIOPort.DispDataType;
            portInfoMap('Data Type')=portDataType;
            interfaceStr=hTable.hTableMap.getInterfaceStr(portName);
            portInfoMap('Target Platform Interfaces')=interfaceStr;
            bitrangeStr=hTable.hTableMap.getBitRangeStr(portName);
            portInfoMap('Bit Range')=bitrangeStr;%#ok<NASGU>
        end

        function executionMode=setExecutionMode(this)
            executionMode=this.hDI.get('ExecutionMode');
        end

        function targetFreq=setTargetFreq(this)
            targetFreqnum=this.hDI.getTargetFrequency;
            targetFreq=num2str(targetFreqnum,'%16.15g');
        end

        function setIPcoreParamMap(this,ipcoreParamMap)
            ipcoreParamMap('IP core name')=this.hDI.hIP.getIPCoreName;
            ipcoreParamMap('IP core version')=this.hDI.hIP.getIPCoreVersion;
            ipcoreParamMap('IP core folder')=this.hDI.hIP.getIPCoreFolder;
            ipcoreParamMap('Generate IP core report')=this.hDI.hIP.getIPCoreReportStatus;%#ok<NASGU>
            ipcoreParamMap('Generate AXI4 slave write register readback')=this.hDI.hIP.getAXI4ReadbackEnable;
        end


        function rebuildDecision=preprocess(this)

            this.cmpsaveDUTChecksum;

            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='dutChecksum';
            depcksbStatusFileFullName=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,this.SBSTATUSFILENAME);
            this.addintoDepCkList(depCKFieldname,depcksbStatusFileFullName);

            ckFieldName='wrapperChecksum';
            if this.hDI.isIPCoreGen
                cksbStatusFileFullName=fullfile(this.hDI.hIP.getIPCoreFolder,this.SBSTATUSFILENAME);
            else
                cksbStatusFileFullName=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,this.SBSTATUSFILENAME);
            end
            this.createMatfileContent(ckFieldName,cksbStatusFileFullName,'wrapperGenLog',cksbStatusFileFullName,'savedInfoStruct',cksbStatusFileFullName);

            rebuildDecision=this.sbDecision;
        end

        function postprocessRebuild(this,resultLog,savedInfoStruct)
            this.updateLog(resultLog,savedInfoStruct);
            this.saveNewMatfileContentInFile;
        end

        function postprocessLog(this)

            wrapFileList=this.hDI.hTurnkey.TurnkeyFileList;
            if strcmp(hdlget_param(this.hDI.hCodeGen.ModelName,'TargetLanguage'),'VHDL')
                disiredFileExt=hdlget_param(this.hDI.hCodeGen.ModelName,'VHDLFileExtension');
            else
                disiredFileExt=hdlget_param(this.hDI.hCodeGen.ModelName,'VerilogFileExtension');
            end
            eleNum=numel(wrapFileList);
            hdldisp(message('hdlcommon:workflow:SmartbuildWrapList'));
            for eleindex=1:eleNum
                ele=wrapFileList{eleindex};
                [pathstr,name,ext]=fileparts(ele);%#ok<ASGLU>
                ele=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,ele);
                if strcmp(ext,disiredFileExt)
                    link=sprintf('<a href="matlab:edit(''%s'')">%s</a>',ele,ele);
                    hdldisp(link);
                end
            end


            if this.hDI.isIPCoreGen&&this.hDI.hIP.getIPCoreReportStatus
                hdldisp(message('hdlcommon:workflow:SmartbuildIPReport'));
                filepath=this.hDI.hIP.hIPEmitter.hReport.ReportFilePath;
                filename=this.hDI.hIP.hIPEmitter.hReport.ReportFileName;
                link=sprintf('<a href="matlab:web(''%s'')">%s</a>',filepath,filename);
                hdldisp(link);
            end
        end

        function[status,result,savedInfoStruct]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            if this.hDI.isIPCoreGen
                taskID='com.mathworks.HDL.GenerateIPCore';
                taskName=message('HDLShared:hdldialog:HDLWAGenerateIPCore').getString;
            else
                taskID='com.mathworks.HDL.GenerateHDLCodeAndReport';
                taskName=message('HDLShared:hdldialog:HDLWAGenerateRTLCodeAndTestbench').getString;
            end

            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'ipcoreWrapGenSb',taskID);
            msg=message('hdlcommon:workflow:SmartbuildSkip',taskName,link);
            result=[msg.getString,char(10),this.MatfileContent.Log.logValue];

            savedInfoStruct=this.MatfileContent.additionInfor.inforValue;
        end

    end

end


