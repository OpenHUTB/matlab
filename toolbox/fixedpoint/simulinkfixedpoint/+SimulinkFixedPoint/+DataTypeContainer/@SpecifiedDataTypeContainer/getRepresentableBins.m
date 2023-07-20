function log2RepresentableBin=getRepresentableBins(dtContainer)


























    calc=SimulinkFixedPoint.DataTypeContainer.RepresentableBinCalculator();
    log2RepresentableBin=calc.getBinsForNumerictype(dtContainer.evaluatedNumericType);
end