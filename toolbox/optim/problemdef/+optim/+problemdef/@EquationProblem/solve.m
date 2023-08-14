function[sol,varargout]=solve(prob,varargin)























































    if nargout>4
        error(message('MATLAB:TooManyOutputs'));
    end


    if nargin>2&&isa(varargin{2},'globaloptim.internal.AbstractGlobalSolver')
        error(message('optim_problemdef:EquationProblem:solve:MultipleStartPointSolversNotSupported',class(varargin{2})));
    end


    prob.ProblemdefOptions.FromEqnSolve=true;
    [sol,varargout{1:nargout-1}]=solveImpl(prob,varargin{:});

end