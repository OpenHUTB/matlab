function combinations=getTransformedGrid(gridSize,scaleMatrix,bias)



























    combinations=scaleMatrix*diag(gridSize)+bias;
    combinations=round(combinations);
    combinations=combinations(all(combinations>1,2),:);
end