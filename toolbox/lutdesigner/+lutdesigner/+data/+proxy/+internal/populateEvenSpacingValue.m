function value=populateEvenSpacingValue(firstPoint,spacing,numPoints)
    spacing=cast(spacing,'like',firstPoint);
    value=linspace(firstPoint,firstPoint+spacing*(numPoints-1),numPoints);
end
