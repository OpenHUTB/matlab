classdef StateflowTargetQuery<dependencies.internal.analysis.simulink.queries.AdvancedQuery




    properties(GetAccess=public,SetAccess=immutable)
        Parameter(1,:)char;
    end

    properties(Constant,Access=private)
        NumExpMatches=2;
    end

    methods
        function queries=StateflowTargetQuery(parameter)
            queries.Parameter=parameter;
        end

        function[loadSaveQuery,numMatches]=createLoadSaveQueries(this)
            parameterQuery=Simulink.loadsave.Query(['/Stateflow//target[',this.Parameter,'=* and name=*]/',this.Parameter]);
            nameQuery=Simulink.loadsave.Query(['/Stateflow//target[',this.Parameter,'=* and name=*]/name']);
            loadSaveQuery={[parameterQuery;nameQuery]};
            numMatches=this.NumExpMatches;
        end

        function match=createMatch(~,~,~,rawMatches)
            match.Value={rawMatches{1}.Value};
            match.Configset={rawMatches{2}.Value};
        end

    end

end

