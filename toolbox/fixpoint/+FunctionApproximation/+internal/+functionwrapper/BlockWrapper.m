classdef BlockWrapper<FunctionApproximation.internal.functionwrapper.SerializationNeedingWrapper






    methods
        function this=BlockWrapper(data)
            this.Data=data;
            if~isempty(this.Data)

%#USEPARALLEL
                this.NumberOfDimensions=this.Data.NumberOfDimensions;


                dataToModelAdapter=FunctionApproximation.internal.datatomodeladapter.getDataToModelAdapter(data);
                this.FunctionToEvaluate=dataToModelAdapter.getModelInfo(data);
            end
        end

        function modify(this,data)
            this.Data=data;

            this.FunctionToEvaluate.update(data)
        end

        function setFunctionToEvaluate(this,functionToEvaluate)
            this.FunctionToEvaluate=functionToEvaluate;
        end

        function setVectorized(this,value)
            setVectorized@FunctionApproximation.internal.functionwrapper.SerializationNeedingWrapper(this,value);
            setVectorized(this.FunctionToEvaluate,value);
        end
    end

    methods(Access=protected)
        function outputValue=execute(this,inputs)


            this.FunctionToEvaluate.loadModel();
            this.FunctionToEvaluate.ModelWorkspace.assignin(...
            this.FunctionToEvaluate.InputValuesVariableName,inputs);

            out=sim(this.FunctionToEvaluate.ModelName,'SaveFormat','Array');
            this.FunctionToEvaluate.dirtyOff();


            outputValue=double(out.yout);
            if this.getVectorized()
                outputValue=outputValue';
            end


            clearTempFiles(this.FunctionToEvaluate);
        end
    end
end


