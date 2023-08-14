classdef(Sealed)ElementWiseOperationValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    properties(Constant)
        NumSamples=2^8;
        NumIterations=3;
    end

    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=ElementWiseOperationValidator()
        end
    end

    methods
        function success=validate(this,functionWrapper,inputLoweBounds,inputUpperBounds,embeddedNumerictypes)






            inputValues=rand(this.NumSamples,numel(inputUpperBounds)).*(inputUpperBounds-inputLoweBounds)+inputLoweBounds;
            for iType=1:numel(embeddedNumerictypes)
                inputValues(:,iType)=double(fixed.internal.math.castUniversal(inputValues(:,iType),embeddedNumerictypes(iType)));
            end


            try
                outputValues=functionWrapper.evaluate(inputValues);
                success=true;
            catch err
                success=false;



                diagnostic=MException(err.identifier,err.message);
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end



            if success

                validIndices=~isnan(outputValues);
                outputValues=outputValues(validIndices);
                if~isempty(outputValues)
                    inputValues=inputValues(validIndices,:);
                    nIndices=size(inputValues,1);
                    for ii=1:this.NumIterations
                        indices=randi(nIndices,ceil(nIndices/2),1);
                        subSetOfInputs=inputValues(indices,:);
                        subSetOutput=functionWrapper.evaluate(subSetOfInputs);
                        success=all(outputValues(indices)==subSetOutput);
                        if~success
                            this.Diagnostic=MException(message('SimulinkFixedPoint:functionApproximation:functionNotVectorized'));
                            break;
                        end
                    end
                end
            end
        end
    end
end
