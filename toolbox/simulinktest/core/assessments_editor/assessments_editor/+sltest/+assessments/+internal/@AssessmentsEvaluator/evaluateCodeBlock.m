function output=evaluateCodeBlock(varargin)




    narginchk(3,3);
    validateattributes(varargin{1},{'char'},{'scalartext'},mfilename,'code',1);
    validateattributes(varargin{2},{'char'},{'scalartext'},mfilename,'output',2);
    validateattributes(varargin{3},{'struct'},{'scalar'},mfilename,'workspace',3);

    cellfun(@(f)assignin('caller',f,varargin{3}.(f)),fieldnames(varargin{3}));
    eval(varargin{1});
    output=eval(varargin{2});
end
