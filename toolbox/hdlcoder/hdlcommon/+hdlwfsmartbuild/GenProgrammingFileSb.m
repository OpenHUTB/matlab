


classdef(Sealed)GenProgrammingFileSb<hdlwfsmartbuild.SmartbuildBase

    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=GenProgrammingFileSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end

    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'genProgrammingFileSb')
                existObj=hdlWFSbMap('genProgrammingFileSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.GenProgrammingFileSb(hDI);

                    hDI.addhdlWFSbMap('genProgrammingFileSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.GenProgrammingFileSb(hDI);

                hDI.addhdlWFSbMap('genProgrammingFileSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)%#ok<MANU>
            depInforStr='';
        end


        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='parChecksum';
            sbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
            this.addintoDepCkList(depCKFieldname,sbStatusFileFullName);

            ckFieldName='genProgramFileChecksum';
            this.createMatfileContent(ckFieldName,sbStatusFileFullName,'genProgramFileLog',sbStatusFileFullName);

            rebuildDecision=this.sbDecision;
        end

        function postprocessRebuild(this,resultLog)
            this.updateLog(resultLog);
            this.saveNewMatfileContentInFile;
        end

        function[status,result]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            taskID='com.mathworks.HDL.GenerateBitstream';
            taskName=message('HDLShared:hdldialog:HDLWAGenerateProgrammingFile').getString;

            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'genProgrammingFileSb',taskID);

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



