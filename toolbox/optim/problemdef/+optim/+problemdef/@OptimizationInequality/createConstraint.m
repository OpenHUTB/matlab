function newcon=createConstraint(~,varargin)








    newcon=optim.problemdef.OptimizationInequality(varargin{:});