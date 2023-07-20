classdef MF0Query<dependencies.internal.analysis.simulink.queries.AdvancedQuery




    properties(GetAccess=public,SetAccess=immutable)
        Property(1,:)string;
    end

    methods
        function this=MF0Query(property,varargin)
            this.Property=[property,varargin];
        end

        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)
            query=sprintf("/%s",["MF0",this.Property]);
            loadSaveQuery={Simulink.loadsave.Query(query)};
            numMatches=1;
        end

        function match=createMatch(~,~,~,rawMatches)
            match.Names=string({rawMatches{1}.Value});
        end
    end

end

