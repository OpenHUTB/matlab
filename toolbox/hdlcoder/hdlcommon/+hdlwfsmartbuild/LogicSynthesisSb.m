


classdef(Sealed)LogicSynthesisSb<hdlwfsmartbuild.SmartbuildBase


    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=LogicSynthesisSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end


    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'logicSynthesisSb')
                existObj=hdlWFSbMap('logicSynthesisSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.LogicSynthesisSb(hDI);

                    hDI.addhdlWFSbMap('logicSynthesisSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.LogicSynthesisSb(hDI);

                hDI.addhdlWFSbMap('logicSynthesisSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)
            synthToolVer=this.hDI.hToolDriver.getToolVersion;
            depInforStr=['SynthesisToolVersion.',synthToolVer];
        end


        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='createPrjChecksum';
            if this.hDI.isGenericWorkflow||this.hDI.isTurnkeyWorkflow||this.hDI.isSLRTWorkflow||this.hDI.isIPWorkflow
                if this.hDI.isIPCoreGen
                    sbStatusFileFullName=fullfile(this.hDI.hIP.getEmbeddedToolProjFolder,this.SBSTATUSFILENAME);
                else
                    sbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
                end
            end
            this.addintoDepCkList(depCKFieldname,sbStatusFileFullName);

            ckFieldName='logicSynthesisChecksum';
            this.createMatfileContent(ckFieldName,sbStatusFileFullName,'logicSynthesisResultLog',sbStatusFileFullName);

            if this.hDI.isIPCoreGen
                if this.hDI.hIP.getEmbeddedExternalBuild
                    this.clearMatfileContentInFile;
                    rebuildDecision=this.mySbServe.REBUILD;
                    this.mySbServe.setRebuildDecision(this.mySbServe.REBUILD);
                    return;
                end
            end
            rebuildDecision=this.sbDecision;

        end

        function postprocessRebuild(this,resultLog)
            if this.hDI.isIPCoreGen
                if this.hDI.hIP.getEmbeddedExternalBuild
                    return;
                end
            end

            this.updateLog(resultLog);
            this.saveNewMatfileContentInFile;

        end

        function[status,result]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            if this.hDI.isIPCoreGen
                taskID='com.mathworks.HDL.EmbeddedSystemBuild';
                taskName=message('HDLShared:hdldialog:HDLWAEmbeddedSystemBuild').getString;
            else
                taskID='com.mathworks.HDL.RunLogicSynthesis';
                taskName=message('HDLShared:hdldialog:HDLWAPerformLogicSynthesis').getString;
            end
            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'logicSynthesisSb',taskID);
            msg=message('hdlcommon:workflow:SmartbuildSkip',taskName,link);
            result=msg.getString;


            if(this.hDI.cmdDisplay)
                hdldisp(msg);
            end

            msg=message('hdlcommon:workflow:SmartbuildShowPrevLog');
            result=[result,msg.getString,this.MatfileContent.Log.logValue];
        end

    end

end



