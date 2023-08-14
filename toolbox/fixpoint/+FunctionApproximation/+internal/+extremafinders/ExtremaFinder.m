classdef(Abstract)ExtremaFinder<handle





    methods
        function[value,functionValue]=getExtrema(this,functionWrapper,gridObject,varargin)
            copiedWrapper=copy(functionWrapper);
            [value,functionValue]=execute(this,copiedWrapper,gridObject,varargin{:});
        end
    end

    methods(Access=?FunctionApproximation.internal.extremafinders.ExtremaFinder)
        [value,functionValue]=execute(this,functionWrapper,gridObject,varargin)
    end
end


