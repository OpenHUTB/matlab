classdef SimulinkLUTApproximateGenerator<FunctionApproximation.internal.approximategenerator.ApproximateGenerator




    methods
        function result=approximate(~,lutSolution,varargin)


            [success,diagnostic]=FunctionApproximation.internal.Utils.isAUTOSARBlocksetLicenseAvailable(lutSolution.Options);
            if~success
                throwAsCaller(diagnostic);
            end
            optargs={true,true};
            optargs(1:numel(varargin))=varargin;
            [displayApproximate,simApproximate]=optargs{:};


            adapter=FunctionApproximation.internal.getLUTSolutionToModelAdapter(...
            lutSolution.Options.UseFunctionApproximationBlock);
            modelInfo=getModel(adapter,lutSolution);


            modelObject=modelInfo.ModelObject;
            blockObject=get_param([modelInfo.ModelName,'/',adapter.getBlockName()],'Object');

            unlinkModel(modelInfo);

            if simApproximate

                sim(modelObject.Name);
            end

            if displayApproximate

                modelObject.Open='on';
            end

            baseName=['ModelWithApproximation_',datestr(now,'yyyymmddTHHMMSSFFF')];
            modelObject.Name=fixed.internal.modelnameutil.getModelNameWithCounter(baseName);
            modelObject.Dirty='off';
            result=struct();
            result.ModelObject=modelObject;
            result.BlockObject=blockObject;
        end
    end
end
