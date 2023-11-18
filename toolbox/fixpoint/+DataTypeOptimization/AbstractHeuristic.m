classdef(Abstract)AbstractHeuristic<handle
    properties
problemPrototype
tracer
    end

    methods(Abstract)

        run(this,evaluationService,solutionRepo);
    end

    methods
        function canAdvance=advance(this)
            canAdvance=this.tracer.advance();
        end
    end
end