function res=invokeDVGMFunc(funcPath,varargin)
    fh=builtin('_GetFunctionHandleForFullpath',funcPath);
    res=fh(varargin{:});
end