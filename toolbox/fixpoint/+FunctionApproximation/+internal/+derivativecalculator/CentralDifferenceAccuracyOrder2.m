classdef CentralDifferenceAccuracyOrder2<FunctionApproximation.internal.derivativecalculator.FiniteDifferenceInterface






    properties(Constant)

        Coefficients={...
        [-1,-1/2;1,1/2],...
        [-1,1;0,-2;1,1],...
        [-2,-1/2;-1,1;1,-1;2,1/2],...
        }
    end
end


