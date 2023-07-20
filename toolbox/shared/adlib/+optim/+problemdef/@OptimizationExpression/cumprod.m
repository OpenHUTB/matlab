function eout=cumprod(obj,varargin)


















    Op=optim.internal.problemdef.operator.Cumprod(size(obj),varargin{:});
    eout=createUnary(obj,Op);