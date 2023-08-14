function eout=empty(varargin)







    szVec=optim.problemdef.OptimizationConstraint.sizeVec4Empty(varargin{:});
    eout=optim.problemdef.OptimizationConstraint(szVec);