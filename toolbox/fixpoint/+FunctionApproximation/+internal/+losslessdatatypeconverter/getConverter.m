function converter=getConverter(options)





    if options.ExploreFixedPoint||options.ExploreFloatingPoint
        converter=FunctionApproximation.internal.losslessdatatypeconverter.LUTDBUnitLosslessDataTypeConverter();
    else
        converter=FunctionApproximation.internal.losslessdatatypeconverter.NullConverter();
    end
end
