


classdef(Sealed)CreatePrjSb<hdlwfsmartbuild.SmartbuildBase


    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=CreatePrjSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end


    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'createPrjSb')
                existObj=hdlWFSbMap('createPrjSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.CreatePrjSb(hDI);

                    hDI.addhdlWFSbMap('createPrjSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.CreatePrjSb(hDI);

                hDI.addhdlWFSbMap('createPrjSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function setExtFileNameTimeMap(this,extFileNameTimeMap)

            [customFile,customTclFile]=this.hDI.hToolDriver.hTool.parseCustomFileStrWithTcl(this.hDI.getCustomHDLFile);
            for i=1:length(customFile)
                fileName=customFile{i};
                timeStamp=this.mySbServe.getFileTimeStamp(fileName);
                extFileNameTimeMap(fileName)=timeStamp;
            end
            for i=1:length(customTclFile)
                fileName=customTclFile{i};
                timeStamp=this.mySbServe.getFileTimeStamp(fileName);
                extFileNameTimeMap(fileName)=timeStamp;
            end
        end





        function setEmbeddedPrjMap(this,embeddedPrjMap)
            embeddedPrjMap('Embedded system tool')=this.hDI.hIP.getEmbeddedTool;
            embeddedPrjMap('Enable IP Cache')=this.hDI.hIP.getUseIPCache;
            embeddedPrjMap('Synthesis Objective')=this.hDI.getObjective;
            embeddedPrjMap('Project folder')=this.hDI.hIP.getEmbeddedToolProjFolder;%#ok<NASGU>
        end

        function depInforStr=getDepInforStr(this)
            if this.hDI.isGenericWorkflow||this.hDI.isTurnkeyWorkflow||this.hDI.isSLRTWorkflow||this.hDI.isIPWorkflow
                if this.hDI.isIPCoreGen
                    embeddedPrjMap=containers.Map('KeyType','char','ValueType','any');
                    this.setEmbeddedPrjMap(embeddedPrjMap);
                    depInforStr=hdlwfsmartbuild.serialize(embeddedPrjMap);
                else
                    extFileNameTimeMap=containers.Map('KeyType','char','ValueType','any');
                    this.setExtFileNameTimeMap(extFileNameTimeMap);
                    depInforStr=hdlwfsmartbuild.serialize(extFileNameTimeMap);
                end
            end
        end



        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='wrapperChecksum';
            if this.hDI.isGenericWorkflow||this.hDI.isTurnkeyWorkflow||this.hDI.isSLRTWorkflow||this.hDI.isIPWorkflow
                if this.hDI.isIPCoreGen
                    depcksbStatusFileFullName=fullfile(this.hDI.hIP.getIPCoreFolder,this.SBSTATUSFILENAME);
                else
                    depcksbStatusFileFullName=fullfile(getProp(this.hDI.hCodeGen.hCHandle.getINI,'codegendir'),this.hDI.hCodeGen.ModelName,this.SBSTATUSFILENAME);
                end
            end
            this.addintoDepCkList(depCKFieldname,depcksbStatusFileFullName);

            ckFieldName='createPrjChecksum';
            if this.hDI.isGenericWorkflow||this.hDI.isTurnkeyWorkflow||this.hDI.isSLRTWorkflow||this.hDI.isIPWorkflow
                if this.hDI.isIPCoreGen
                    cksbStatusFileFullName=fullfile(this.hDI.hIP.getEmbeddedToolProjFolder,this.SBSTATUSFILENAME);
                else
                    cksbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
                end
            end
            this.createMatfileContent(ckFieldName,cksbStatusFileFullName,'createPrjResultLog',cksbStatusFileFullName);

            rebuildDecision=this.sbDecision;
        end

        function postprocessRebuild(this,resultLog)
            this.updateLog(resultLog);
            this.saveNewMatfileContentInFile;
        end

        function[status,result]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            if this.hDI.isIPCoreGen
                taskID='com.mathworks.HDL.EmbeddedProject';
            else
                taskID='com.mathworks.HDL.CreateProject';
            end
            taskName=message('HDLShared:hdldialog:HDLWACreateProject').getString;

            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'createPrjSb',taskID);
            msg=message('hdlcommon:workflow:SmartbuildSkip',taskName,link);
            result=msg.getString;


            if(this.hDI.cmdDisplay)
                hdldisp(msg);
                [tool,link]=this.hDI.getProjectToolLink;
                msg=message('hdlcoder:workflow:PreviousProject',tool,link);
                hdldisp(msg);
            end


            msg=message('hdlcommon:workflow:SmartbuildShowPrevLog');
            result=[result,msg.getString,this.MatfileContent.Log.logValue];

        end
    end

end



