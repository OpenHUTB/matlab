classdef ExplicitValues<SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.Interface





    methods
        function this=ExplicitValues(values)



            this.Values={values};

            if isfi(values)&&values.isscalingslopebias
                diffVector=SimulinkFixedPoint.AutoscalerUtils.subtractSlopeBiasFiValues(values(2:end),values(1:end-1));
            else
                diffVector=values(2:end)-values(1:end-1);
            end


            minimumDeltaValue=min(diffVector);


            this.DataType=SimulinkFixedPoint.AutoscalerConstraints.DataTypeCreator.getDataType(values,minimumDeltaValue);
        end
    end
end
