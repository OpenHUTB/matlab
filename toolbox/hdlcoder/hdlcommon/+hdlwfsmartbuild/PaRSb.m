


classdef(Sealed)PaRSb<hdlwfsmartbuild.SmartbuildBase


    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=PaRSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end

    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'parSb')
                existObj=hdlWFSbMap('parSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.PaRSb(hDI);

                    hDI.addhdlWFSbMap('parSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.PaRSb(hDI);

                hDI.addhdlWFSbMap('parSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)%#ok<MANU>
            depInforStr='';
        end


        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='mappingChecksum';
            sbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
            this.addintoDepCkList(depCKFieldname,sbStatusFileFullName);

            ckFieldName='parChecksum';
            this.createMatfileContent(ckFieldName,sbStatusFileFullName,'parResultLog',sbStatusFileFullName);

            rebuildDecision=this.sbDecision;
        end

        function postprocessRebuild(this,resultLog)
            this.updateLog(resultLog);
            this.saveNewMatfileContentInFile;
        end

        function[status,result]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            taskID='com.mathworks.HDL.RunPandR';
            taskName=message('HDLShared:hdldialog:HDLWAPerformPlaceAndRoute').getString;

            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'parSb',taskID);

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



