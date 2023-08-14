


classdef(Sealed)ImplementationSb<hdlwfsmartbuild.SmartbuildBase


    properties(Constant,Hidden=true)
        SBSTATUSFILENAME='hdlwfbuildstatus.mat';
    end
    properties(Access=protected)
        hDI;
    end

    methods(Access=private)
        function obj=ImplementationSb(hDIhandle)
            obj=obj@hdlwfsmartbuild.SmartbuildBase;
            obj.hDI=hDIhandle;
        end
    end

    methods(Static)
        function singleObj=getInstance(hDI)
            hdlWFSbMap=hDI.gethdlWFSbMap;
            if isKey(hdlWFSbMap,'implSb')
                existObj=hdlWFSbMap('implSb');
                if isempty(existObj)||~isvalid(existObj)

                    singleObj=hdlwfsmartbuild.ImplementationSb(hDI);

                    hDI.addhdlWFSbMap('implSb',singleObj);
                else

                    singleObj=existObj;
                end
            else

                singleObj=hdlwfsmartbuild.ImplementationSb(hDI);

                hDI.addhdlWFSbMap('implSb',singleObj);
            end
        end
    end


    methods(Access=public)

        function depInforStr=getDepInforStr(this)%#ok<MANU>
            depInforStr='';
        end


        function rebuildDecision=preprocess(this)
            this.DepCkList=struct('ChecksumName',{},'FileName',{});
            depCKFieldname='vivadoSynthesisChecksum';
            sbStatusFileFullName=fullfile(this.hDI.getProjectPath,this.SBSTATUSFILENAME);
            this.addintoDepCkList(depCKFieldname,sbStatusFileFullName);

            ckFieldName='implChecksum';
            this.createMatfileContent(ckFieldName,sbStatusFileFullName,'implResultLog',sbStatusFileFullName);

            rebuildDecision=this.sbDecision;
        end

        function postprocessRebuild(this,resultLog)
            this.updateLog(resultLog);
            this.saveNewMatfileContentInFile;
        end

        function[status,result]=postprocessSkip(this)
            status=true;
            this.saveNewMatfileContentInFile;
            taskID='com.mathworks.HDL.RunImplementation';
            taskName=message('HDLShared:hdldialog:HDLWAVivadoImplementation').getString;


            link=sprintf('<a href="matlab:hdlwfsmartbuild.forceRebuild(''%s'',''%s'',''%s'',''%s'',''%s'')">here</a>',this.hDI.hCodeGen.ModelName,this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'implSb',taskID);

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



