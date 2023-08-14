


classdef(Sealed)MappingSb<hdlwfsmartbuild.SmartbuildBase


    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=MappingSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end

    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'mappingSb')
                existObj=hdlWFSbMap('mappingSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.MappingSb(hDI);

                    hDI.addhdlWFSbMap('mappingSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.MappingSb(hDI);

                hDI.addhdlWFSbMap('mappingSb',singleObj);
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
        end


        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='logicSynthesisChecksum';
            sbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
            this.addintoDepCkList(depCKFieldname,sbStatusFileFullName);

            ckFieldName='mappingChecksum';
            this.createMatfileContent(ckFieldName,sbStatusFileFullName,'mappingResultLog',sbStatusFileFullName);

            rebuildDecision=this.sbDecision;
        end

        function postprocessRebuild(this,resultLog)
            this.updateLog(resultLog);
            this.saveNewMatfileContentInFile;
        end

        function[status,result]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            taskID='com.mathworks.HDL.RunMapping';
            taskName=message('HDLShared:hdldialog:HDLWAPerformMapping').getString;

            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'mappingSb',taskID);

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



