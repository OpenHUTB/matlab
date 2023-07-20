


classdef ServerSmartbuild<handle


    properties(Constant,Hidden=true)
        NOREBUILD=0;
        REBUILD=1;
    end

    properties(Access=protected)
        OldChecksum='';
        NewChecksum='';
        RebuildDecision;
    end


    methods(Access=public)

        function obj=ServerSmartbuild()
            obj.RebuildDecision=obj.REBUILD;
        end

        function rtl=getOldChecksum(this)
            rtl=this.OldChecksum;
        end

        function setOldChecksum(this,oldChecksumIn)
            this.OldChecksum=oldChecksumIn;
        end

        function rtl=getNewChecksum(this)
            rtl=this.NewChecksum;
        end

        function setNewChecksum(this,newChecksumIn)
            this.NewChecksum=newChecksumIn;
        end

        function rtl=getRebuildDecision(this)
            rtl=this.RebuildDecision;
        end

        function setRebuildDecision(this,rebuildDecisionIn)
            this.RebuildDecision=rebuildDecisionIn;
        end


        function checksumCmpRlt=compareChecksum(this)
            checksumCmpRlt=strcmp(this.OldChecksum,this.NewChecksum);
        end
    end

    methods(Static)

        function checksumRlt=getChecksumFile(filein)
            tempStruct=load(filein);
            str=hdlwfsmartbuild.serialize(tempStruct);
            checksumRlt=rptgen.hash(str);
        end

        function checksumRlt=getDUTChecksumFile(filein,modelName)
            tempStruct=load(filein);








            modelGenStatus=tempStruct.ModelGenStatus;
            modelGenStatus=rmfield(modelGenStatus,'ModelTopLevelHDLParams');
            executeCmd=sprintf('hdlsaveparams(''%s'')',modelName);
            modelGenStatus.hdlsaveparams=evalc(executeCmd);
            tempStruct.ModelGenStatus=modelGenStatus;

            str=hdlwfsmartbuild.serialize(tempStruct);
            checksumRlt=rptgen.hash(str);
        end

        function checksumRlt=getChecksumStr(strin)
            checksumRlt=rptgen.hash(strin);
        end



        function saveVarToFile(fileName,varName,varValue)%#ok<INUSD,> %save the checksum variable into .mat file

            v=genvarname(varName);
            evalc([v,'= varValue']);

            if exist(fileName,'file')
                save(fileName,varName,'-append');
            else
                [pathstr,~,~]=fileparts(fileName);
                if exist(pathstr,'dir')
                    save(fileName,varName);
                else
                    return;
                end
            end
        end


        function varValue=loadVarFromFile(fileName,varName)
            if exist(fileName,'file')
                tempStruct=load(fileName);
                v=genvarname(varName);
                if isfield(tempStruct,varName)
                    varValue=tempStruct.(v);
                else
                    varValue='';
                end
            else
                varValue='';
            end
        end


        function fileTimeStamp=getFileTimeStamp(dirName)
            fileInfor=dir(dirName);
            if isempty(fileInfor)
                dirFullPathName=which(dirName);
                fileInfor=dir(dirFullPathName);
            end
            fileTimeStamp=fileInfor(1).date;
        end

    end
end

