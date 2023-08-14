classdef(Sealed)TimeVarianceValidator<FunctionApproximation.internal.utilities.ValidatorInterface







    properties(Constant)
        NumSamples=2^8;
        NumIterations=3;
    end

    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=TimeVarianceValidator()
        end
    end

    methods
        function success=validate(this,functionWrapper,inputLoweBounds,inputUpperBounds)
            success=true;



            originalRNG=rng(0,'twister');
            inputValues=rand(this.NumSamples,numel(inputUpperBounds)).*(inputUpperBounds-inputLoweBounds)+inputLoweBounds;

            rng(originalRNG);

            data=functionWrapper.Data;
            if~isempty(data)&&isa(data,'FunctionApproximation.internal.serializabledata.BlockData')
                blockWrapper=functionWrapper;
                while~isa(blockWrapper,'FunctionApproximation.internal.functionwrapper.BlockWrapper')
                    blockWrapper=blockWrapper.FunctionToEvaluate;
                end




                curSimTime=blockWrapper.FunctionToEvaluate.ModelObject.StopTime;
                blockWrapper.FunctionToEvaluate.ModelObject.StopTime=get_param(data.ModelName,'StopTime');
                try
                    output=blockWrapper.evaluate(inputValues);
                catch
                    success=false;
                end
                blockWrapper.FunctionToEvaluate.ModelObject.StopTime=curSimTime;

                if success


                    outputDiff=(output-output(:,1));
                    if~any(outputDiff(:))
                        success=false;
                    end
                end
            end

            if success
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:subsystemNotTimeInvariant'));
            end
        end
    end
end


