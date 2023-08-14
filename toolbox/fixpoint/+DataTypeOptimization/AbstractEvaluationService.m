classdef AbstractEvaluationService<handle






    properties(SetAccess=protected)
problemPrototype
environmentProxy
baselineRunID
baselineSimOut
    end

    methods(Abstract)
        solution=evaluateSolutions(this,solution)
    end

    methods(Hidden)
        initializeParameters(this,parsedResults)
    end

    methods(Sealed)
        function initialize(this,varargin)
            p=this.createInputParser();

            p.parse(varargin{:});

            this.initializeParameters(p.Results);

        end
    end

    methods(Hidden,Sealed)
        function p=createInputParser(~)
            p=inputParser();
            p.KeepUnmatched=true;
            p.addParameter('BaselineSimOut',[]);
            p.addParameter('BaselineRunID',[]);
            p.addParameter('OptimizationOptions',[]);
            p.addParameter('ProblemPrototype',[]);
            p.addParameter('EnvironmentProxy',[]);
            p.addParameter('SimulationInputEntriesMap',[]);
            p.addParameter('PreprocessingInput',[]);

        end

    end

end
