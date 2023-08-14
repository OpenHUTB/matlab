classdef(Hidden=true)SqlDb<handle










    properties(Access=private,Constant=true)
        SQLDB_OPEN=1;
        SQLDB_CLOSE=2;
        SQLDB_EXEC=7;
        SQLDB_EXEC_HASH_STRINGS=8;
        SQLDB_LAST_INSERT_ROWID=9;
        SQLDB_CHANGES=15;
        SQLDB_BEGIN_TRANSACTION=16;
        SQLDB_COMMIT_TRANSACTION=17;
    end

    properties(SetAccess=private,GetAccess=public,Hidden=true)
db
    end

    properties(Access=private)
        isDbHandleOwner=true;
    end

    events
onClose
    end

    methods(Access=public)



        function this=SqlDb(dbFileOrHandle,mustExistOrTakeDbHandleOwnership,vfs)
            if nargin>=1
                if nargin<2
                    mustExistOrTakeDbHandleOwnership=false;
                end
                if nargin<3
                    vfs=[];
                end
                if isstruct(dbFileOrHandle)
                    this.db=dbFileOrHandle;
                    this.isDbHandleOwner=mustExistOrTakeDbHandleOwnership;
                else
                    this.open(dbFileOrHandle,mustExistOrTakeDbHandleOwnership,vfs);
                end
            end
        end




        function delete(this)
            this.close();
        end




        function open(this,dbFileOrHandle,mustExistOrTakeDbHandleOwnership,vfs)
            if nargin<3
                mustExistOrTakeDbHandleOwnership=false;
            end
            if nargin<4
                vfs=[];
            end
            this.close();
            if isstruct(dbFileOrHandle)
                this.db=dbFileOrHandle;
                this.isDbHandleOwner=mustExistOrTakeDbHandleOwnership;
            else
                this.db=sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_OPEN,dbFileOrHandle,mustExistOrTakeDbHandleOwnership,vfs);
                this.isDbHandleOwner=true;
            end
        end




        function close(this)
            if~isempty(this.db)
                notify(this,'onClose');
                if this.isDbHandleOwner
                    sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_CLOSE,this.db);
                end
                this.db=[];
            end
        end




        function stmt=prepare(this,sqlQuery)
            stmt=polyspace.internal.database.SqlDbStatement(this,sqlQuery);
        end




        function varargout=exec(this,sqlQuery,iHashedStrings)
            if nargin<3
                varargout{1}=sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_EXEC,this.db,sqlQuery);
            else
                [res,strs]=sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_EXEC_HASH_STRINGS,...
                this.db,sqlQuery,iHashedStrings);
                if nargout==2
                    varargout{1}=res;
                    varargout{2}=strs;
                elseif nargout>0
                    if iscell(res)
                        res(:,iHashedStrings)=strs(cell2mat(res(:,iHashedStrings)));
                        varargout{1}=res;
                    else
                        res2=cell(size(res));
                        res2(:,~iHashedStrings)=polyspace.internal.num2cell_mex(res(:,~iHashedStrings));
                        res2(:,iHashedStrings)=strs(res(:,iHashedStrings));
                        varargout{1}=res2;
                    end
                end
            end
        end




        function rowid=lastInsertRowId(this)
            rowid=sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_LAST_INSERT_ROWID,this.db);
        end




        function n=changes(this)
            n=sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_CHANGES,this.db);
        end




        function res=tableExists(this,dbName,tblName)
            if isempty(dbName)
                dbName='main';
            end
            res=~isempty(this.exec(sprintf('pragma %s.table_info(%s)',dbName,tblName)));
        end




        function res=indexExists(this,dbName,idxName)
            if isempty(dbName)
                dbName='main';
            end
            res=~isempty(this.exec(sprintf('pragma %s.index_info(%s)',dbName,idxName)));
        end




        function res=columnExists(this,dbName,tblName,colName)
            if isempty(dbName)
                dbName='main';
            end
            try
                this.exec(sprintf('SELECT %s FROM %s.%s LIMIT 0',colName,dbName,tblName));
                res=true;
            catch ME
                if~strncmp(ME.message,'no such column: ',16)
                    rethrow(ME);
                end
                res=false;
            end
        end




        function beginTransaction(this,varargin)
            sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_BEGIN_TRANSACTION,...
            this.db,varargin{:});
        end




        function commitTransaction(this)
            sqldb_mex(polyspace.internal.database.SqlDb.SQLDB_COMMIT_TRANSACTION,...
            this.db);
        end




        function blob=blobOpen(this,dbName,tblName,colName,rowId,flags)
            if isempty(dbName)
                dbName='main';
            end
            if nargin<6
                flags=0;
            end
            blob=polyspace.internal.database.SqlDbBlob(this,dbName,tblName,colName,int64(rowId),flags);
        end




        function explainQueryPlan(this,sql_query)
            fprintf(1,'SQL query: %s\n',sql_query);
            fprintf(1,'Query plan:\n');
            fprintf(1,'-----------\n');
            fprintf(1,'| selectid | order | from |                       detail\n');
            fprintf(1,'|----------|-------|------|----------------------------------------------------------\n');
            tab=this.exec(['EXPLAIN QUERY PLAN ',sql_query]);
            for ii=1:size(tab,1)
                row=tab(ii,:);
                fprintf(1,'| %8d | %5d | %4d | %s\n',row{1},row{2},row{3},row{4});
            end
            fprintf(1,'\n');
        end




        function dbList=saveobj(this)
            if isempty(this.db)
                dbList=[];
            else
                dbList=this.exec('pragma database_list');
                dbList(:,1)=[];
                dbList(strcmp(dbList(:,1),'temp'),:)=[];
            end
        end
    end

    methods(Static=true)



        function this=loadobj(dbList,clsName)
            if nargin<2
                clsName='polyspace.internal.database.SqlDb';
            end
            if isempty(dbList)
                this=feval(clsName);
            else
                idx=strcmp(dbList(:,1),'main');
                this=feval(clsName,dbList{idx,2});
                dbList(idx,:)=[];
                for ii=1:size(dbList,1)
                    this.exec(sprintf('ATTACH DATABASE ''%s'' AS %s',dbList{ii,2},dbList{ii,1}));
                end
            end
        end
    end
end
