










function[indicesOut,distMatOut]=findNRImpl(ptCloudCoords,rangeDataCoords,queryLocation,radius,doSortDist)


%#codegen




    coder.gpu.kernelfun;
    coder.allowpcode('plain');

    numPoints=numel(ptCloudCoords)/3;
    pointsInRadius=zeros(numPoints,1,'uint32');
    distMatAllPoints=zeros(numPoints,1,'like',ptCloudCoords);

    isOrganized=ndims(ptCloudCoords)==3;
    useRangeSearch=queryLocation(1)==0&&queryLocation(2)==0&&...
    queryLocation(3)==0;
    useRangeSearch=useRangeSearch&&isOrganized;
    useRangeSearch=useRangeSearch&&~isempty(rangeDataCoords);

    if useRangeSearch



        coder.gpu.kernel;
        for ptIter=1:numPoints
            pointsInRadius(ptIter)=uint32(rangeDataCoords(ptIter)<=radius);
            distMatAllPoints(ptIter)=rangeDataCoords(ptIter)*rangeDataCoords(ptIter);
        end
    else
        coder.gpu.kernel;
        for refIter=1:numPoints
            refLocation=[ptCloudCoords(refIter),ptCloudCoords(refIter+numPoints),...
            ptCloudCoords(refIter+2*numPoints)];


            distVal=(refLocation(1)-queryLocation(1))*(refLocation(1)-queryLocation(1))+...
            (refLocation(2)-queryLocation(2))*(refLocation(2)-queryLocation(2))+...
            (refLocation(3)-queryLocation(3))*(refLocation(3)-queryLocation(3));

            distMatAllPoints(refIter)=distVal;
            pointsInRadius(refIter)=uint32(distVal<=radius*radius);
        end
    end


    idxMat=pointsInRadius;
    idxMat=cumsum(idxMat);




    outSize=uint32(0);
    coder.gpu.kernel;
    for i=1:2
        outSize=idxMat(numPoints);
    end

    indicesOut_unsorted=zeros(outSize,1,'uint32');
    distMatOut=zeros(outSize,1,'like',ptCloudCoords);

    coder.gpu.kernel;
    for i=1:numPoints
        if pointsInRadius(i)
            indicesOut_unsorted(idxMat(i))=i;
            distMatOut(idxMat(i))=distMatAllPoints(i);
        end
    end


    if doSortDist
        [distMatOut,sortedInd]=gpucoder.sort(distMatOut);
        indicesOut=uint32(indicesOut_unsorted(sortedInd));
    else
        indicesOut=uint32(indicesOut_unsorted);
    end
    distMatOut=sqrt(distMatOut);
end
