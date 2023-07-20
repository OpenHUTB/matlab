classdef BlockParameterQuery<dependencies.internal.analysis.simulink.queries.AdvancedQuery





    properties(GetAccess=public,SetAccess=immutable)
        Parameter(1,1)string;
        Predicates(1,:)string;
    end

    properties(GetAccess=private,SetAccess=immutable)
        LoadSaveQueries;
    end

    properties(Constant,Access=private)
        NumExpMatches=2;
    end

    methods(Static)

        function query=createParameterQuery(param,varargin)
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery;
            [value,path]=i_createQueries("//System/Block",param,varargin);
            query=BlockParameterQuery(param,varargin,{[value;path]});
        end

        function query=createSystemParameterQuery(param,varargin)
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery;
            [value,path]=i_createQueries("//System",param,varargin);
            query=BlockParameterQuery(param,varargin,{[value;path]});
        end

        function query=createInstanceDataParameterQuery(param,varargin)
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery;

            predicates=[{'BlockType','Reference'},varargin];
            [oldValue,oldPath]=i_createQueries("//System/Block",param,predicates);
            [newValue,newPath]=i_createQueries("//System/Block",sprintf("InstanceData/%s",param),predicates);

            data={...
            [oldValue;oldPath;oldValue;oldPath;newValue;newPath],...
            {'mdl';'mdl';'slx';'slx';'slx';'slx'},...
            [0;0;0;0;8.6;8.6],...
            [Inf;Inf;8.5;8.5;Inf;Inf]};

            query=BlockParameterQuery(param,predicates,data);
        end

        function query=createAnnotationParameterQuery(param,varargin)
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery;
            import Simulink.loadsave.Modifier;
            [value,path]=i_createQueries("//System/Annotation",param,varargin,Modifier.AnnotationPath);
            query=BlockParameterQuery(param,varargin,{[value;path]});
        end

        function query=createPortParameterQuery(param,varargin)
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery;

            oldParam=replace(param,"Index","PortNumber");
            oldPredicates=cellstr(replace(string(varargin),"Index","PortNumber"));

            [oldValue,oldPath]=i_createQueries("//System/Block/Port",oldParam,oldPredicates);
            [newValue,newPath]=i_createQueries("//System/Block/PortProperties/Port",param,varargin);

            data={...
            [oldValue;oldPath;newValue;newPath],...
            {'any';'any';'any';'any'},...
            [0;0;10.6;10.6],...
            [10.5;10.5;Inf;Inf]};

            query=BlockParameterQuery(param,varargin,data);
        end

    end

    methods(Access=private)
        function query=BlockParameterQuery(param,predicates,queries)
            query.Parameter=param;
            query.Predicates=predicates;
            query.LoadSaveQueries=queries;
        end
    end

    methods
        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)
            loadSaveQuery=this.LoadSaveQueries;
            numMatches=this.NumExpMatches;
        end

        function match=createMatch(~,~,~,rawMatches)
            match.Value={rawMatches{1}.Value};
            match.BlockPath={rawMatches{2}.Value};
        end
    end

end


function[value,path]=i_createQueries(root,parameter,predicates,modifier)

    if nargin<4
        modifier=Simulink.loadsave.Modifier.BlockPath;
    end

    predicate='';
    if length(predicates)>=2
        predicate=sprintf('%s="%s" and ',predicates{:});
        predicate=sprintf('[%s]',predicate(1:end-5));
    end

    query=sprintf('%s%s/%s',root,predicate,parameter);

    value=Simulink.loadsave.Query(query);
    path=Simulink.loadsave.Query(query);
    path.Modifier=modifier;

end
