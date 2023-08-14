classdef(Sealed)InterpNWrapper<FunctionApproximation.internal.functionwrapper.SerializationNeedingWrapper






    methods
        function this=InterpNWrapper(interpNData)
            modify(this,interpNData);
            this.NumberOfDimensions=numel(this.Data.Data)-1;
        end

        function modify(this,data)
            this.Data=data;

            interpolationData=data.Data;

            interpString=FunctionApproximation.internal.modifyInterpString(this.Data.InterpolationMethod);
            extrapString=FunctionApproximation.internal.modifyInterpString(this.Data.ExtrapolationMethod);

            this.FunctionToEvaluate=griddedInterpolant(interpolationData(1:end-1),interpolationData{end},interpString,extrapString);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            outputValue=this.FunctionToEvaluate(inputs);
            if~isdouble(this.Data.OutputType)
                outputValue=fixed.internal.math.castUniversal(outputValue,this.Data.OutputType,true);
                outputValue=double(outputValue);
            end
        end
    end
end
