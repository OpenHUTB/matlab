









function indicesOut=findPtsInROI(ptCloudCoords,roi)


%#codegen




    coder.gpu.kernelfun;
    coder.allowpcode('plain');

    numPoints=numel(ptCloudCoords)/3;

    inROI=false(numPoints,1);
    coder.gpu.kernel;
    for ptIter=1:numPoints
        inROI(ptIter)=ptCloudCoords(ptIter)>=roi(1)&ptCloudCoords(ptIter)<=roi(2)...
        &ptCloudCoords(ptIter+numPoints)>=roi(3)&ptCloudCoords(ptIter+numPoints)<=roi(4)...
        &ptCloudCoords(ptIter+2*numPoints)>=roi(5)&ptCloudCoords(ptIter+2*numPoints)<=roi(6);
    end


    idxMat=uint32(inROI);
    idxMat=cumsum(idxMat);




    outSize=uint32(0);
    coder.gpu.kernel;
    for i=1:2
        outSize=idxMat(numPoints);
    end

    indicesOut=zeros(outSize,1,'uint32');
    coder.gpu.kernel;
    for i=1:numPoints
        if inROI(i)
            indicesOut(idxMat(i))=i;
        end
    end
end
