classdef PluginQuery<dependencies.internal.analysis.simulink.queries.AdvancedQuery




    properties(GetAccess=public,SetAccess=immutable)
        Plugin(1,1)string;
        Parameter(1,1)string;
    end

    methods
        function this=PluginQuery(plugin,parameter)
            this.Plugin=plugin;
            this.Parameter=parameter;
        end

        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)
            query=sprintf("/%s/%s",this.Plugin,this.Parameter);
            loadSaveQuery={Simulink.loadsave.Query(query)};
            numMatches=1;
        end

        function match=createMatch(~,~,~,rawMatches)
            match.Value=string({rawMatches{1}.Value});
        end
    end

end

