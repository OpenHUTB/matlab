classdef HeuristicsScheduler<handle









    properties
heuristics
iterationCount
heuristicsSchedule

    end

    properties(Constant)
        initialFrequency=5;

    end

    methods
        function this=HeuristicsScheduler(heuristics)
            this.heuristics=heuristics;
            this.initializeSchedule();

        end

        function heuristic=getHeuristic(this)

            heuristicIndex=find(this.heuristicsSchedule>mod(this.iterationCount,max(this.heuristicsSchedule)),1);


            heuristic=this.heuristics{heuristicIndex};


            this.iterationCount=this.iterationCount+1;
        end
    end

    methods(Hidden)
        function initializeSchedule(this)
            this.iterationCount=0;





            this.heuristicsSchedule=cumsum(this.initialFrequency*ones(1,numel(this.heuristics)));

        end

    end

end