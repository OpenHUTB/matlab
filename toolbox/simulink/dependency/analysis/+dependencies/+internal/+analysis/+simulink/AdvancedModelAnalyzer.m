classdef(Abstract)AdvancedModelAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer





    properties(Access=private)
        QueryData=cell(0,3);
    end

    methods

        function deps=analyze(this,handler,node,matches)
            idx=1;
            for n=1:size(this.QueryData,1)

                name=this.QueryData{n,1};
                exp=this.QueryData{n,2};
                matchCreator=this.QueryData{n,3};

                ownedMatches=matches(idx:idx+(exp-1));

                idx=idx+exp;

                match.(name)=matchCreator(handler,node,ownedMatches);

            end
            deps=this.analyzeMatches(handler,node,match);

        end


    end

    methods(Access=protected)
        function addQueries(this,queries)
            names=fieldnames(queries);
            newQueries=cell(length(names),3);
            for n=1:length(names)
                name=names{n};
                [loadSaveQuery,numExpMatches]=queries.(name).createLoadSaveQueries();
                addQueries@dependencies.internal.analysis.simulink.ModelAnalyzer(this,loadSaveQuery{:});
                queryObj=queries.(name);
                newQueries(n,:)={name,numExpMatches,@queryObj.createMatch};
            end
            this.QueryData=[this.QueryData;newQueries];
        end
    end

end
