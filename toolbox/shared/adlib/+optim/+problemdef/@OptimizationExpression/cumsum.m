function eout=cumsum(obj,varargin)


















    Op=optim.internal.problemdef.operator.Cumsum(size(obj),varargin{:});
    eout=createUnary(obj,Op);

end
