classdef ExplicitEnumerateValues<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.Interface




    methods
        function this=ExplicitEnumerateValues(values)



            this.Values={values};


            this.DataType=numerictype(1,32,0);
        end
    end
end
