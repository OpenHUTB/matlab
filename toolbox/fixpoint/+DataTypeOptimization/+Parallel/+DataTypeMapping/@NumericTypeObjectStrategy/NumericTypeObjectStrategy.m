classdef NumericTypeObjectStrategy<DataTypeOptimization.Parallel.DataTypeMapping.DataTypeObjectStrategy






    methods(Hidden)

        function modifiedObject=getModifiedObject(this,dataType)

            modifiedObject=this.dataTypeObjectWrapper.Object;


            evaluatedNumericType=dataType.evaluatedNumericType;


            modifiedObject.DataTypeMode=evaluatedNumericType.DataTypeMode;


            modifiedObject.Signedness=evaluatedNumericType.Signedness;


            modifiedObject.WordLength=evaluatedNumericType.WordLength;


            modifiedObject.FractionLength=evaluatedNumericType.FractionLength;


            modifiedObject.SlopeAdjustmentFactor=evaluatedNumericType.SlopeAdjustmentFactor;


            modifiedObject.Bias=evaluatedNumericType.Bias;
        end

    end

end


