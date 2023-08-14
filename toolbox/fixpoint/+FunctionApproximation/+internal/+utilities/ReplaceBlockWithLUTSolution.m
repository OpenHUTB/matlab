classdef ReplaceBlockWithLUTSolution<FunctionApproximation.internal.utilities.BlockReplacementInterface





    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=ReplaceBlockWithLUTSolution()
        end
    end

    methods
        function[success,diagnostic]=replace(~,originalBlockPath,solutionObject)





            [modelObject,blockObject]=solutionObject.approximate(false,false);

            [success,diagnostic]=FunctionApproximation.internal.Utils.replaceBlockWithBlock(originalBlockPath,blockObject.getFullName);


            close_system(modelObject.getFullName,0)
        end
    end
end
