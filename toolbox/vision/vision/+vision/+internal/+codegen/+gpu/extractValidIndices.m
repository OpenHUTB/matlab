










function validCoords=extractValidIndices(ptCloudCoords)

%#codegen




    coder.gpu.kernelfun;
    coder.allowpcode('plain');


    numPoints=numel(ptCloudCoords)/3;
    validCoords=false(numPoints,1);

    coder.gpu.kernel;
    for i=1:numPoints
        validCoords(i)=isfinite(ptCloudCoords(i))&&...
        isfinite(ptCloudCoords(i+numPoints))&&...
        isfinite(ptCloudCoords(i+2*numPoints));
    end
end
