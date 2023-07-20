function ineq=empty(varargin)











    szVec=optim.problemdef.OptimizationConstraint.sizeVec4Empty(varargin{:});
    ineq=optim.problemdef.OptimizationInequality(szVec);
