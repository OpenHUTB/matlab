function allCombinations=getAllGridSizeCombinations(gridSize,scaleMatrix,bias)







    combinations=FunctionApproximation.internal.solvers.getTransformedGrid(gridSize,scaleMatrix,bias);
    coordinatesInEachDimension=num2cell(combinations',2);
    coordinateSetCreator=FunctionApproximation.internal.CoordinateSetCreator(coordinatesInEachDimension);
    allCombinations=coordinateSetCreator.CoordinateSets;
end
