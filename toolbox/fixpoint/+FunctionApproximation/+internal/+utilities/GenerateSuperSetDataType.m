classdef GenerateSuperSetDataType<handle




    methods(Static)
        function dataType=generateDataType(aDataType,bDataType,breakpointValues)

            dataTypeSignedness=aDataType.Signed||bDataType.Signed;
            dataTypeWL=max(aDataType.WordLength,bDataType.WordLength)+1;

            dataTypeFL=max(aDataType.FractionLength,bDataType.FractionLength);
            dataType=numerictype(dataTypeSignedness,dataTypeWL,aDataType.SlopeAdjustmentFactor,-dataTypeFL,0);

            denominatorReciprocalType=fixed.internal.type.tightFixedPointType(1./diff(breakpointValues),max(32,bDataType.WordLength));

            if aDataType.isscalingslopebias&&bDataType.isscalingslopebias
                dataType=fi(0,dataType);
                dataType.ProductMode='SpecifyPrecision';
                dataType.ProductWordLength=dataType.WordLength+denominatorReciprocalType.WordLength;
                dataType.ProductFractionLength=dataType.FractionLength+denominatorReciprocalType.FractionLength;
                dataType.SumMode='SpecifyPrecision';
                dataType.SumWordLength=max(dataType.WordLength,denominatorReciprocalType.WordLength)+1;
                dataType.SumFractionLength=max(dataType.FractionLength,denominatorReciprocalType.FractionLength);
            end
        end
    end
end
