function equ=empty(varargin)











    szVec=optim.problemdef.OptimizationConstraint.sizeVec4Empty(varargin{:});
    equ=optim.problemdef.OptimizationEquality(szVec);
