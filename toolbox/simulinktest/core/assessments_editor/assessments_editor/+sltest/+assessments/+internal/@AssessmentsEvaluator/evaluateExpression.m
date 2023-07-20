function value=evaluateExpression(varargin)



    narginchk(2,2);
    validateattributes(varargin{1},{'char'},{'scalartext'},mfilename,'expression',1);
    validateattributes(varargin{2},{'struct'},{'scalar'},mfilename,'workspace',2);

    cellfun(@(f)assignin('caller',f,varargin{2}.(f)),fieldnames(varargin{2}));
    value=eval(varargin{1});
end
