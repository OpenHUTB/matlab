


classdef(Sealed)VivadoSynthesisSb<hdlwfsmartbuild.SmartbuildBase


    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=VivadoSynthesisSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end


    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'vivadoSynthesisSb')
                existObj=hdlWFSbMap('vivadoSynthesisSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.VivadoSynthesisSb(hDI);

                    hDI.addhdlWFSbMap('vivadoSynthesisSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.VivadoSynthesisSb(hDI);

                hDI.addhdlWFSbMap('vivadoSynthesisSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)
            hWorkflow=this.hDI.getWorkflow('PostMapTiming');
            if(hWorkflow.Skipped)
                PostMapTimingoption='1';
            else
                PostMapTimingoption='0';
            end
            depInforStr=['PostMapTiming.',PostMapTimingoption];

            synthToolVer=this.hDI.hToolDriver.getToolVersion;
            depInforStr=[depInforStr,';','SynthesisToolVersion.',synthToolVer];
        end


        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='createPrjChecksum';
            if this.hDI.isGenericWorkflow||this.hDI.isTurnkeyWorkflow||this.hDI.isXPCWorkflow||this.hDI.isIPWorkflow
                if this.hDI.isIPCoreGen
                    sbStatusFileFullName=fullfile(this.hDI.hIP.getEmbeddedToolProjFolder,this.SBSTATUSFILENAME);
                else
                    sbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
                end
            end
            this.addintoDepCkList(depCKFieldname,sbStatusFileFullName);

            ckFieldName='vivadoSynthesisChecksum';
            this.createMatfileContent(ckFieldName,sbStatusFileFullName,'vivadoSynthesisResultLog',sbStatusFileFullName);

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
                taskName=message('HDLShared:hdldialog:HDLWAGenerateIPCore').getString;
            else
                taskID='com.mathworks.HDL.RunVivadoSynthesis';
                taskName=message('HDLShared:hdldialog:HDLWAVivadoSynthesis').getString;
            end
            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'vivadoSynthesisSb',taskID);

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



