function newcon=createConstraint(~,varargin)








    newcon=optim.problemdef.OptimizationEquality(varargin{:});

