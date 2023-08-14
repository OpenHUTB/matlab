classdef QuantizedExplicitValues<FunctionApproximation.internal.gridcreator.GridingStrategy



    properties(SetAccess=protected)
ErrorFunction
AcceptableTolerance
InputTypes
Options
    end

    methods
        function this=QuantizedExplicitValues(dataTypes)
            this=this@FunctionApproximation.internal.gridcreator.GridingStrategy(dataTypes);
        end

        function this=register(this,errorFunction,acceptableTolerance,inputTypes,options)
            this.ErrorFunction=copy(errorFunction);
            this.AcceptableTolerance=acceptableTolerance;
            this.InputTypes=inputTypes;
            this.Options=options;
        end
    end
end
