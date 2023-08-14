classdef(Hidden=true)SqlDbBlob<handle










    properties(Access=private,Constant=true)
        SQLDB_BLOB_OPEN=10;
        SQLDB_BLOB_CLOSE=11;
        SQLDB_BLOB_BYTES=12;
        SQLDB_BLOB_READ=13;
        SQLDB_BLOB_WRITE=14;
    end

    properties(SetAccess=private,GetAccess=public,Hidden=true)
blob
    end

    properties(Access=private)
lh
    end

    methods(Access=public)



        function this=SqlDbBlob(db_obj,dbName,tblName,colName,rowId,flags)
            this.blob=sqldb_mex(polyspace.internal.database.SqlDbBlob.SQLDB_BLOB_OPEN,db_obj.db,dbName,tblName,colName,rowId,flags);
            this.lh=addlistener(db_obj,'onClose',@(varargin)this.close());
        end




        function delete(this)
            this.close();
        end




        function close(this)
            if~isempty(this.blob)
                sqldb_mex(polyspace.internal.database.SqlDbBlob.SQLDB_BLOB_CLOSE,this.blob);
                this.blob=[];
                delete(this.lh)
            end
        end




        function res=bytes(this)
            res=sqldb_mex(polyspace.internal.database.SqlDbBlob.SQLDB_BLOB_BYTES,this.blob);
        end




        function res=read(this,varargin)
            res=sqldb_mex(polyspace.internal.database.SqlDbBlob.SQLDB_BLOB_READ,this.blob,varargin{:});
        end




        function write(this,varargin)
            sqldb_mex(polyspace.internal.database.SqlDbBlob.SQLDB_BLOB_WRITE,this.blob,varargin{:});
        end
    end
end
