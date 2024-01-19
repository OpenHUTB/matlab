classdef CodeInfoDataDictionary<sldv.code.internal.CodeInfoFile

    properties(Constant=true,Access=protected)
        RootDataGroupName='Other'
    end


    properties(Access=protected)
Connection
    end


    methods(Access=public)

        function this=CodeInfoDataDictionary(fileName,fileInfo)
            this@sldv.code.internal.CodeInfoFile(fileName,fileInfo);

            if isfile(fileName)
                this.Connection=Simulink.dd.open(fileName);
            else
                this.Connection=Simulink.dd.create(fileName);
            end
        end


        function close(this)
            this.Connection.close();
        end


        function hasInfo=readDb(this)
            path=[this.RootDataGroupName,'.',this.getDataMemberName()];

            if this.Connection.entryExists(path,false)
                instanceDb=this.Connection.getEntry(path);
                if isa(instanceDb,this.FileInfo.getClassName())
                    this.CodeDb=instanceDb;
                    hasInfo=true;
                else
                    msg=message('sldv_sfcn:sldv_sfcn:unexpectedDataDictionaryEntry',path,this.FileName);
                    throw(MException('sldv_sfcn:unexpectedDataDictionaryEntry',msg.getString()));
                end
            else
                this.CodeDb=this.FileInfo.createCodeDb();
                hasInfo=false;
            end
        end


        function writeDb(this)
            this.beginTransaction();
            path=[this.RootDataGroupName,'.',this.getDataMemberName()];
            if this.Connection.entryExists(path,false)
                this.Connection.setEntry(path,this.CodeDb);
            else
                this.Connection.insertEntry(this.RootDataGroupName,this.getDataMemberName(),this.CodeDb);
            end

            this.commitTransaction();
            this.saveChanges();
        end
    end


    methods(Access=protected)

        function beginTransaction(this)
            this.Connection.beginTransaction();
        end


        function commitTransaction(this)
            this.Connection.commitTransaction();
        end


        function saveChanges(this)
            this.Connection.saveChanges();
        end


        function out=getDataMemberName(this)
            out=this.FileInfo.getDataMemberName();
        end


        function out=getInstanceDbClassName(this)
            out=this.FileInfo.getClassName();
        end
    end
end


