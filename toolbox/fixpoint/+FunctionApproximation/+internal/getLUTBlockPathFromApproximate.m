function lutBlockPath=getLUTBlockPathFromApproximate(approximationPath)












    if FunctionApproximation.internal.approximationblock.isCreatedByFunctionApproximation(approximationPath)
        schema=FunctionApproximation.internal.approximationblock.BlockSchema();
        approximationPath=schema.getApproximateSource(approximationPath,1);
    end
    lutBlockPath=[approximationPath,'/LUT'];
end