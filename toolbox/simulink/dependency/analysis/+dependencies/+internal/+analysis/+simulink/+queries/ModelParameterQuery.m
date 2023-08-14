classdef ModelParameterQuery<dependencies.internal.analysis.simulink.queries.AdvancedQuery




    properties(Constant,Access=private)
        NumExpMatches=3;
    end

    properties(GetAccess=public,SetAccess=immutable)
        Parameter(1,1)string;
    end


    methods
        function query=ModelParameterQuery(parameter)
            query.Parameter=parameter;
        end

        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)
            loadSaveQuery={[Simulink.loadsave.Query(strcat('//Model/',this.Parameter)),...
            Simulink.loadsave.Query(strcat('//Library/',this.Parameter)),...
            Simulink.loadsave.Query(strcat('//Subsystem/',this.Parameter))]};
            numMatches=this.NumExpMatches;
        end

        function match=createMatch(~,~,~,rawMatches)
            match.Value=string({rawMatches{1}.Value,rawMatches{2}.Value,rawMatches{3}.Value});
        end
    end
end

