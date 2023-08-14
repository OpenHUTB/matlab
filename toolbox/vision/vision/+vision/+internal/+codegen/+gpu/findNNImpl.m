









function[indices_sorted,distMat_sorted]=findNNImpl(ptCloudCoords,queryLocation,numNghbrs)
%#codegen



    coder.gpu.kernelfun;
    coder.allowpcode('plain');

    numPoints=numel(ptCloudCoords)/3;
    distMatAllPoints=coder.internal.inf(numPoints,1);

    coder.gpu.kernel;
    for refIter=1:numPoints
        refLocation=[ptCloudCoords(refIter),ptCloudCoords(refIter+numPoints),...
        ptCloudCoords(refIter+2*numPoints)];


        distVal=(refLocation(1)-queryLocation(1))*(refLocation(1)-queryLocation(1))+...
        (refLocation(2)-queryLocation(2))*(refLocation(2)-queryLocation(2))+...
        (refLocation(3)-queryLocation(3))*(refLocation(3)-queryLocation(3));

        distMatAllPoints(refIter)=distVal;
    end

    [distMatAllPointsSorted,indexSorted]=gpucoder.sort(distMatAllPoints);
    distMat_sorted=cast(sqrt(distMatAllPointsSorted(1:numNghbrs)),'like',ptCloudCoords);
    indices_sorted=cast(indexSorted(1:numNghbrs),'uint32');
end
