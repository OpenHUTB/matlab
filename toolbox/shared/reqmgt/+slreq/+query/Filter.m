classdef(Abstract)Filter<matlab.mixin.Heterogeneous&handle


    properties
        query='';
    end

    properties(Transient)
        scopeObject=[];
        queryResult=[];
        lastErrors=struct([]);
    end

    methods(Access=protected)
        function rs=finalFilter(this,items)
            rs=items;
        end
    end

    methods(Abstract)

        apply(this,scopeObj)
        findAll(this)
    end

    methods
        function this=Filter()
        end

        function delete(this)
        end

        function tf=isValid(this)
            tf=true;
        end

        function setQuery(this,varargin)
            this.query=varargin{:};
        end

        function q=getQuery(this)
            q=this.query;
        end

        function r=getQueryResult(this)
            r=this.queryResult;
        end
    end

    methods(Access=protected)
        function items=evalQueryAsFunction(this)
            try
                tmpName=[tempname,'.m'];
                fileID=fopen(tmpName,'w');
                fwrite(fileID,this.query);
                fclose(fileID);
                delFile=onCleanup(@()delete(tmpName));

                func=builtin('_GetFunctionHandleForFullpath',tmpName);

                items=feval(func);
            catch E
                err.id=E.identifier;
                err.message=E.message;
                this.lastErrors{end+1}=err;
            end
        end

        function items=evalQueryAsStatements(this)
            items=[];
            try

                items=eval(this.query);
            catch E
                err.id=E.identifier;
                err.message=E.message;
                this.lastErrors{end+1}=err;
            end
        end

        function items=evalQueryAsCellArray(this)
            items=[];
            try
                if ischar(this.query)
                    eval(this.query);
                    args=ans;
                elseif iscell(this.query)
                    args=this.query;
                else

                end


                if isempty(args)
                    items=this.findAll();
                    return;
                end
            catch E
                ferr.id='Slvnv:slreq:FilterParseError';
                if isa(this,'slreq.query.ReqFilter')
                    t=getString(message('Slvnv:slreq:Requirements'));
                else
                    t=getString(message('Slvnv:slreq:Links'));
                end
                ferr.message=getString(message('Slvnv:slreq:FilterParseError',t,E.message));
                this.lastErrors{end+1}=ferr;
                return;
            end

            try
                queryTypes={};

                if~strcmpi(args{1},'type')
                    if isempty(this.scopeObject)
                        if isa(this,"slreq.query.ReqFilter")
                            queryTypes={'Requirement','Reference','Justification'};
                        else
                            queryTypes={'Link'};
                        end
                    elseif isa(this.scopeObject,"slreq.ReqSet")
                        cs=this.scopeObject.children;
                        if~isempty(cs)&&isa(cs(1),"slreq.Reference")
                            queryTypes={'Reference'};
                        else
                            queryTypes={'Requirement'};
                        end
                    else
                        queryTypes={'Link'};
                    end
                end

                if isempty(queryTypes)
                    if isempty(this.scopeObject)
                        items=slreq.find(args{:});
                    else
                        items=scopeObj.find(args{:});
                    end
                else
                    for i=1:numel(queryTypes)
                        if isempty(this.scopeObject)
                            items=[items,slreq.find('type',queryTypes{i},args{:})];
                        else
                            items=[items,scopeObj.find('type',queryTypes{i},args{:})];
                        end
                    end
                end

            catch E
                ferr.id='Slvnv:slreq:FilterApplicationError';
                if isa(this,'slreq.query.ReqFilter')
                    t=getString(message('Slvnv:slreq:Requirements'));
                else
                    t=getString(message('Slvnv:slreq:Links'));
                end
                ferr.message=getString(message('Slvnv:slreq:FilterApplicationError',t,E.message));
                this.lastErrors{end+1}=ferr;
                return;
            end
        end

        function tf=isQueryInFunctionForm(this)
            tf=false;

            lines=split(this.query,newline);
            for i=1:numel(lines)
                line=lines{i};
                s=regexp(line,'\w','once');
                if isempty(s)||line(s)=='%'
                    continue;
                else
                    tf=startsWith(line(s:end),'function ');
                    break;
                end
            end
        end
    end
end
