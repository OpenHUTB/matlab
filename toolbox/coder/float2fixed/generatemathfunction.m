



function obj=generatemathfunction(varargin)
    if nargin<1
        error(['help ',mfilename()])
    end
    obj=coder.internal.mathfcngenerator.MathFunctionGenerator('UserInterp','Linear (degree-1 Polynomial)','CandidateFunctionName',varargin{1}).getGeneratorObject();
    return
end
