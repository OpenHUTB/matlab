classdef MatlabScriptWrapper<FunctionApproximation.internal.functionwrapper.SerializationNeedingWrapper





    methods
        function this=MatlabScriptWrapper(data)
            this.Data=data;

            this.NumberOfDimensions=this.Data.NumberOfDimensions;


            adapter=FunctionApproximation.internal.datatomodeladapter.getDataToScriptAdapter(data);
            this.FunctionToEvaluate=adapter.getScriptInfo(data);
        end

        function modify(this,data)
            this.Data=data;

            this.FunctionToEvaluate.update(data)
        end

        function setFunctionToEvaluate(this,functionToEvaluate)
            this.FunctionToEvaluate=functionToEvaluate;
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)
            if size(inputs,2)==3
                outputValue=this.FunctionToEvaluate.FunctionHandle(inputs(:,1),inputs(:,2),inputs(:,3));
            elseif size(inputs,2)==2
                outputValue=this.FunctionToEvaluate.FunctionHandle(inputs(:,1),inputs(:,2));
            else
                outputValue=this.FunctionToEvaluate.FunctionHandle(inputs);
            end
            outputValue=double(outputValue);
        end
    end
end


