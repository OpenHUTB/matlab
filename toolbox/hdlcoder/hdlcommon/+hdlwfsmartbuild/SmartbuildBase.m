


classdef SmartbuildBase<handle


    properties(Access=public)
        DepCkList=struct('ChecksumName',{},'FileName',{});
        MatfileContent;

        mySbServe;
    end


    methods(Abstract,Access=public)
        depInforStr=getDepInforStr(this);
    end



    methods(Access=public)
        function obj=SmartbuildBase()
            obj.mySbServe=hdlwfsmartbuild.ServerSmartbuild;
        end



        function addintoDepCkList(this,checksumName,fileName)
            ele.ChecksumName=checksumName;
            ele.FileName=fileName;
            this.DepCkList(end+1)=ele;
        end

        function createMatfileContent(this,checksumName,fileName,logName,logFileName,varargin)
            ChecksumSubSt.checksumName=checksumName;
            ChecksumSubSt.fileName=fileName;
            ChecksumSubSt.value='';
            LogSubSt.logName=logName;
            LogSubSt.logFileName=logFileName;
            LogSubSt.logValue='';
            this.MatfileContent.Checksum=ChecksumSubSt;
            this.MatfileContent.Log=LogSubSt;
            if numel(varargin)~=0
                if(numel(varargin)==2)
                    additionInforSubSt.inforName=varargin{1};
                    additionInforSubSt.inforfileName=varargin{2};
                    additionInforSubSt.inforValue={};
                    this.MatfileContent.additionInfor=additionInforSubSt;
                else
                    error('Please pass in the pair of field name and filename used to store the additional information.');
                end
            end
        end

        function updateLog(this,newLog,varargin)
            this.MatfileContent.Log.logValue=newLog;
            if numel(varargin)~=0
                if(numel(varargin)==1)
                    this.MatfileContent.additionInfor.inforValue=varargin{1};
                else
                    error('Please collect all the additional information as one cell array or struct');
                end
            end
        end



        function calculateNewChecksum(this)
            depCkStr=this.getdepCkStr;
            if isempty(depCkStr)
                this.mySbServe.setNewChecksum('');
                return;
            end
            depInforStr=this.getDepInforStr;
            newStr=[depCkStr,';',depInforStr];
            newChecksum=this.mySbServe.getChecksumStr(newStr);
            this.mySbServe.setNewChecksum(newChecksum);
        end

        function depCkStr=getdepCkStr(this)
            str='';
            eleNum=length(this.DepCkList);
            for eleindex=1:eleNum
                ele=this.DepCkList(eleindex);
                fieldName=ele.ChecksumName;
                fileName=ele.FileName;
                str=[str,',',fieldName,'.'];%#ok<AGROW>

                depChecksum=this.mySbServe.loadVarFromFile(fileName,fieldName);
                if isempty(depChecksum)
                    depCkStr='';
                    return;
                end
                str=[str,depChecksum];%#ok<AGROW>
            end
            depCkStr=str;
        end

        function loadOldMatfileContent(this)
            ckFieldName=this.MatfileContent.Checksum.checksumName;
            ckFileName=this.MatfileContent.Checksum.fileName;
            this.MatfileContent.Checksum.value=this.mySbServe.loadVarFromFile(ckFileName,ckFieldName);
            logFieldName=this.MatfileContent.Log.logName;
            logFileName=this.MatfileContent.Log.logFileName;
            this.MatfileContent.Log.logValue=this.mySbServe.loadVarFromFile(logFileName,logFieldName);
            this.mySbServe.setOldChecksum(this.MatfileContent.Checksum.value);

            if isfield(this.MatfileContent,'additionInfor')
                inforFieldName=this.MatfileContent.additionInfor.inforName;
                inforFileName=this.MatfileContent.additionInfor.inforfileName;
                this.MatfileContent.additionInfor.inforValue=this.mySbServe.loadVarFromFile(inforFileName,inforFieldName);
            end
        end



        function rebuild=sbDecision(this)
            this.mySbServe.setRebuildDecision(this.mySbServe.REBUILD);

            this.calculateNewChecksum;
            if isempty(this.mySbServe.getNewChecksum)
                rebuild=this.mySbServe.REBUILD;
                return;
            end

            this.loadOldMatfileContent;
            this.clearMatfileContentInFile;

            if(isempty(this.mySbServe.getOldChecksum))
                rebuild=this.mySbServe.REBUILD;
            else
                if this.mySbServe.compareChecksum
                    rebuild=this.mySbServe.NOREBUILD;
                else
                    rebuild=this.mySbServe.REBUILD;
                end
            end

            this.mySbServe.setRebuildDecision(rebuild);
        end

        function clearMatfileContentInFile(this)
            if exist(this.MatfileContent.Checksum.fileName,'file')
                this.mySbServe.saveVarToFile(this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,'');
            end
        end

        function saveNewMatfileContentInFile(this)


            if isempty(this.mySbServe.getNewChecksum)
                return;
            end

            this.MatfileContent.Checksum.value=this.mySbServe.getNewChecksum;

            this.mySbServe.saveVarToFile(this.MatfileContent.Checksum.fileName,this.MatfileContent.Checksum.checksumName,this.MatfileContent.Checksum.value);
            this.mySbServe.saveVarToFile(this.MatfileContent.Log.logFileName,this.MatfileContent.Log.logName,this.MatfileContent.Log.logValue);

            if isfield(this.MatfileContent,'additionInfor')
                this.mySbServe.saveVarToFile(this.MatfileContent.additionInfor.inforfileName,this.MatfileContent.additionInfor.inforName,this.MatfileContent.additionInfor.inforValue);
            end
        end

    end


end


