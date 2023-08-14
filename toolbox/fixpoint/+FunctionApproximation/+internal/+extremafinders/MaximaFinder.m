classdef MaximaFinder<FunctionApproximation.internal.extremafinders.ExtremaFinder






    properties(SetAccess=private)
        MinimaFinder;
    end

    methods
        function this=MaximaFinder(minimaFinder)
            this.MinimaFinder=minimaFinder;
        end
    end

    methods(Access=?FunctionApproximation.internal.extremafinders.ExtremaFinder)
        function[value,functionValue]=execute(this,functionWrapper,gridObject,varargin)
            [value,functionValue]=execute(this.MinimaFinder,-functionWrapper,gridObject,varargin{:});
            functionValue=-functionValue;
        end
    end
end


