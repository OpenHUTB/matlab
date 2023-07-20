classdef EFIE<em.solvers.FMMSolver



    properties(Hidden,SetObservable,AbortSet)
        PreconditionerSize{mustBeAutoOrDbl(PreconditionerSize)}='Auto'
    end

    methods
        function c=EFIE(varargin)

            c=c@em.solvers.FMMSolver(varargin{:});
            c.IEType='EFIE';
        end
    end

end

function mustBeAutoOrDbl(PreconditionerSize)
    if isnumeric(PreconditionerSize)
        mustBePositive(PreconditionerSize);
    end
    if ischar(PreconditionerSize)
        if~strcmpi(PreconditionerSize,'auto')
            error('PreconditionerSize is either auto or a positive integer');
        end
    end
end