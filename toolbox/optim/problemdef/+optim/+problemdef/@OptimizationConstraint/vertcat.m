function con=vertcat(varargin)






    con=optim.problemdef.OptimizationConstraint.concat(1,varargin{:});
