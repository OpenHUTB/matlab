classdef ForwardDifferenceAccuracyOrder1<FunctionApproximation.internal.derivativecalculator.FiniteDifferenceInterface






    properties(Constant)

        Coefficients={...
        [0,-1;1,1],...
        [0,1;1,-2;2,1],...
        [0,-1;1,3;2,-3;3,1],...
        }
    end
end


