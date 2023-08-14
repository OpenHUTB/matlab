classdef(Hidden=true)SqlDbStatement<handle










    properties(Access=private,Constant=true)
        SQLDB_PREPARE=3;
        SQLDB_FINALIZE=4;
        SQLDB_BIND_AND_EXEC=5;
        SQLDB_BIND_AND_EXEC_HASH_STRINGS=6;
    end

    properties(SetAccess=private,GetAccess=public,Hidden=true)
stmt
    end

    properties(Access=private)
lh
    end

    methods(Access=public)



        function this=SqlDbStatement(db_obj,sqlQuery)
            this.stmt=sqldb_mex(polyspace.internal.database.SqlDbStatement.SQLDB_PREPARE,db_obj.db,sqlQuery);
            this.lh=addlistener(db_obj,'onClose',@(varargin)this.finalize());
        end




        function delete(this)
            this.finalize();
        end




        function finalize(this)
            if~isempty(this.stmt)
                sqldb_mex(polyspace.internal.database.SqlDbStatement.SQLDB_FINALIZE,this.stmt);
                this.stmt=[];
                delete(this.lh);
            end
        end




        function res=exec(this,varargin)
            res=sqldb_mex(polyspace.internal.database.SqlDbStatement.SQLDB_BIND_AND_EXEC,this.stmt,varargin{:});
        end




        function varargout=exech(this,iHashedStrings,varargin)
            [res,strs]=sqldb_mex(polyspace.internal.database.SqlDbStatement.SQLDB_BIND_AND_EXEC_HASH_STRINGS,...
            this.stmt,iHashedStrings,varargin{:});
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
end
