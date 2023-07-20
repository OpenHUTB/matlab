classdef MaskParameterQuery<dependencies.internal.analysis.simulink.queries.AdvancedQuery





    properties(Access=public)
        Parameter(1,1)string;
    end

    methods(Access=public)

        function this=MaskParameterQuery(parameter)
            this.Parameter=parameter;
        end

        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)

            [p12b,b12b]=i_create("//System/Block/Object[PropName=""MaskObject""]//"+this.Parameter);
            [pi12b,bi12b]=i_create("//System/Block/InstanceData/Object[PropName=""MaskObject""]//"+this.Parameter);


            [p17b,b17b]=i_create("//System/Block/Mask//"+this.Parameter);
            [pi17b,bi17b]=i_create("//System/Block/InstanceData/Mask//"+this.Parameter);

            loadSaveQuery=...
            {[p17b;pi17b;b17b;bi17b;p12b;pi12b;b12b;bi12b;p12b;pi12b;b12b;bi12b],...
            {'slx';'slx';'slx';'slx';'slx';'slx';'slx';'slx';'mdl';'mdl';'mdl';'mdl'},...
            [9.0;9.0;9.0;9.0;0.0;0.0;0.0;0.0;0.0;0.0;0.0;0.0],...
            [Inf;Inf;Inf;Inf;8.9;8.9;8.9;8.9;Inf;Inf;Inf;Inf]};
            numMatches=4;
        end

        function matches=createMatch(~,~,~,rawMatches)
            values={rawMatches{1}.Value,rawMatches{2}.Value};
            blockPaths={rawMatches{3}.Value,rawMatches{4}.Value};

            matches=struct("Value",{},"BlockPath",{});
            for n=1:numel(values)
                if~isempty(values{n})
                    matches(end+1).Value=string(values{n});%#ok<AGROW> 
                    matches(end).BlockPath=string(blockPaths{n});
                end
            end
        end

    end
end


function[value,path]=i_create(query)
    value=Simulink.loadsave.Query(query);
    path=Simulink.loadsave.Query(query);
    path.Modifier=Simulink.loadsave.Modifier.BlockPath;
end
