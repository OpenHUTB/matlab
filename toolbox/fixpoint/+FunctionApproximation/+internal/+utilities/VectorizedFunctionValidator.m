classdef(Sealed)VectorizedFunctionValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    properties(Constant)
        NumSamples=2^8;
        NumIterations=3;
    end

    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=VectorizedFunctionValidator()
        end
    end

    methods
        function success=validate(this,functionWrapper,inputLoweBounds,inputUpperBounds,embeddedNumerictypes)




            if functionWrapper.getVectorized()
                inputValues=rand(this.NumSamples,numel(inputUpperBounds)).*(inputUpperBounds-inputLoweBounds)+inputLoweBounds;
                for iType=1:numel(embeddedNumerictypes)
                    inputValues(:,iType)=double(fixed.internal.math.castUniversal(inputValues(:,iType),embeddedNumerictypes(iType)));
                end


                try
                    outputValues=functionWrapper.evaluate(inputValues);
                    success=true;
                catch err %#ok<NASGU>
                    success=false;
                end



                if success
                    success=size(outputValues,1)==size(inputValues,1);
                    success=success&&(size(outputValues,2)==1);
                end
            else
                success=false;
            end

            if~success
                this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:functionNotVectorized'));
            end
        end
    end
end
