


function[outMeanLocations,outMeanColor,outMeanNormals,...
    outMeanIntensity,outMeanRangeData,outMeanCovariance,...
    numPointsPerVoxel]=voxelGridFilter(inpLocations,inpColor,inpNormal,...
    inpIntensity,inpRangeData,gridStep,minVoxelPoints,inpRange)
%#codegen


































































    coder.gpu.kernelfun;
    coder.allowpcode('plain');
    coder.inline('never');


    if nargin==7
        inpRange=[];
    elseif nargin<7
        inpRange=[];
        minVoxelPoints=1;
    end





    if~coder.gpu.internal.isGpuEnabled
        outputType=class(inpLocations);
    else
        computeCapability=gpucoder.getComputeCapability;
        if computeCapability>=6.1&&strcmp(class(inpLocations),'double')
            outputType='double';
        else
            outputType='single';
        end
    end



    needCovariance=false;
    needCount=false;
    if nargout>5
        needCovariance=true;
    end
    if nargout>6
        needCount=true;
    end


    needColor=~isempty(inpColor);
    needNormal=~isempty(inpNormal);
    needIntensity=~isempty(inpIntensity);
    needRangeData=~isempty(inpRangeData);

    validCoords=vision.internal.codegen.gpu.extractValidIndices(inpLocations);
    isOrganized=ndims(inpLocations)==3;

    [validLoc,validCol,validNorm,validIntensity,validRangeData]=...
    vision.internal.codegen.gpu.getSubsetPoints(inpLocations,inpColor,...
    inpNormal,inpIntensity,inpRangeData,validCoords(:),isOrganized,'selected');



    numPoints=numel(validLoc)/3;

    if isempty(inpRange)
        tmpMat=validLoc(1:numPoints);
        minMaxX=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
        tmpMat=validLoc(numPoints+1:2*numPoints);
        minMaxY=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
        tmpMat=validLoc(2*numPoints+1:3*numPoints);
        minMaxZ=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
    else
        minMaxX=[inpRange(1),inpRange(2)];
        minMaxY=[inpRange(3),inpRange(4)];
        minMaxZ=[inpRange(5),inpRange(6)];
    end


    gridStep_inv=(1/gridStep);
    dx=uint64(floor((minMaxX(2)-minMaxX(1))*gridStep_inv+1));
    dy=uint64(floor((minMaxY(2)-minMaxY(1))*gridStep_inv+1));
    dz=uint64(floor((minMaxZ(2)-minMaxZ(1))*gridStep_inv+1));
    dxy=dx*dy;
    dxyz=dxy*dz;
    if(dx==0||dy==0||dz==0||dxy==0||dx~=dxy/dy||dz~=dxyz/dxy)
        coder.internal.error('vision:pointcloud:voxelSizeTooSmall');
    end



    minX=floor(minMaxX(1)*gridStep_inv);
    maxX=floor(minMaxX(2)*gridStep_inv);
    minY=floor(minMaxY(1)*gridStep_inv);
    maxY=floor(minMaxY(2)*gridStep_inv);
    minZ=floor(minMaxZ(1)*gridStep_inv);
    maxZ=floor(minMaxZ(2)*gridStep_inv);

    numVoxels_x=uint32(floor(maxX-minX+1));
    numVoxels_y=uint32(floor(maxY-minY+1));
    numVoxels_z=uint32(floor(maxZ-minZ+1));
    numVoxels_xy=uint32(floor(numVoxels_y*numVoxels_x));
    numVoxelsTotal=numVoxels_xy*numVoxels_z;




    inRangeVoxels=false(numPoints,1);
    outRangeVoxels=false(numPoints,1);


    coder.gpu.kernel;
    for i=1:numPoints
        xInp=validLoc(i);
        yInp=validLoc(i+numPoints);
        zInp=validLoc(i+2*numPoints);


        xInpInRange=minMaxX(1)<=xInp&&xInp<=minMaxX(2);
        yInpInRange=minMaxY(1)<=yInp&&yInp<=minMaxY(2);
        zInpInRange=minMaxZ(1)<=zInp&&zInp<=minMaxZ(2);

        if xInpInRange&&yInpInRange&&zInpInRange
            inRangeVoxels(i)=true;
        else
            outRangeVoxels(i)=true;
        end
    end


    [inRangeLoc,inRangeCol,inRangeNorm,inRangeIntensity,~]=...
    vision.internal.codegen.gpu.getSubsetPoints(validLoc,validCol,...
    validNorm,validIntensity,[],inRangeVoxels,0,'selected');


    numPointsInRange=numel(inRangeLoc)/3;
    voxelIndexVector=coder.nullcopy(zeros(numPointsInRange,1,'uint32'));


    coder.gpu.kernel;
    for i=1:numPointsInRange
        xInp=inRangeLoc(i);
        yInp=inRangeLoc(i+numPointsInRange);
        zInp=inRangeLoc(i+2*numPointsInRange);

        xCoord=uint32(floor((xInp-minMaxX(1))*gridStep_inv));
        yCoord=uint32(floor((yInp-minMaxY(1))*gridStep_inv));
        zCoord=uint32(floor((zInp-minMaxZ(1))*gridStep_inv));
        voxelIdx=zCoord*numVoxels_xy+yCoord*numVoxels_x+xCoord+1;
        voxelIndexVector(i)=voxelIdx;
    end




    meanLoc=zeros(numVoxelsTotal,3,outputType);
    if needColor
        meanCol=zeros(numVoxelsTotal,3,outputType);
    else
        meanCol=zeros(0,3,outputType);
    end
    if needNormal
        meanNorm=zeros(numVoxelsTotal,3,outputType);
    else
        meanNorm=zeros(0,3,outputType);
    end
    if needIntensity
        meanInt=zeros(numVoxelsTotal,1,outputType);
    else
        meanInt=zeros(0,1,outputType);
    end
    if needRangeData
        meanRData=zeros(numVoxelsTotal,3,outputType);
    else
        meanRData=zeros(0,3,outputType);
    end
    if needCovariance
        meanCov=zeros(3,3,numVoxelsTotal,outputType);
    else
        meanCov=zeros(3,3,0,outputType);
    end
    pointsPerVoxel=zeros(numVoxelsTotal,1,'uint32');


    coder.gpu.kernel;
    for ptIter=1:numPointsInRange
        voxelIdx=voxelIndexVector(ptIter);
        pointsPerVoxel(voxelIdx)=gpucoder.atomicAdd(pointsPerVoxel(voxelIdx),uint32(1));

        meanLoc(voxelIdx,1)=gpucoder.atomicAdd(meanLoc(voxelIdx,1),...
        cast(inRangeLoc(ptIter),outputType));
        meanLoc(voxelIdx,2)=gpucoder.atomicAdd(meanLoc(voxelIdx,2),...
        cast(inRangeLoc(ptIter+numPointsInRange),outputType));
        meanLoc(voxelIdx,3)=gpucoder.atomicAdd(meanLoc(voxelIdx,3),...
        cast(inRangeLoc(ptIter+2*numPointsInRange),outputType));

        if needColor
            meanCol(voxelIdx,1)=gpucoder.atomicAdd(meanCol(voxelIdx,1),...
            cast(inRangeCol(ptIter),outputType));
            meanCol(voxelIdx,2)=gpucoder.atomicAdd(meanCol(voxelIdx,2),...
            cast(inRangeCol(ptIter+numPointsInRange),outputType));
            meanCol(voxelIdx,3)=gpucoder.atomicAdd(meanCol(voxelIdx,3),...
            cast(inRangeCol(ptIter+2*numPointsInRange),outputType));
        end

        if needIntensity
            meanInt(voxelIdx)=gpucoder.atomicAdd(meanInt(voxelIdx),...
            cast(inRangeIntensity(ptIter),outputType));
        end

        if needNormal
            meanNorm(voxelIdx,1)=gpucoder.atomicAdd(meanNorm(voxelIdx,1),...
            cast(inRangeNorm(ptIter),outputType));
            meanNorm(voxelIdx,2)=gpucoder.atomicAdd(meanNorm(voxelIdx,2),...
            cast(inRangeNorm(ptIter+numPointsInRange),outputType));
            meanNorm(voxelIdx,3)=gpucoder.atomicAdd(meanNorm(voxelIdx,3),...
            cast(inRangeNorm(ptIter+2*numPointsInRange),outputType));
        end

        if needCovariance
            xInp=inRangeLoc(ptIter);
            yInp=inRangeLoc(ptIter+numPointsInRange);
            zInp=inRangeLoc(ptIter+2*numPointsInRange);
            coordVal=[xInp,yInp,zInp];

            coder.unroll;
            for covC=1:3
                coder.unroll;
                for covR=1:3
                    k=cast(coordVal(covR)*coordVal(covC),outputType);
                    meanCov(covR,covC,voxelIdx)=gpucoder.atomicAdd(...
                    meanCov(covR,covC,voxelIdx),k);
                end
            end
        end
    end

    coder.gpu.kernel;
    for voxelIdx=1:numVoxelsTotal
        ptsPerVoxel=cast(pointsPerVoxel(voxelIdx),outputType);
        meanLoc(voxelIdx,:)=meanLoc(voxelIdx,:)./ptsPerVoxel;
        if needColor
            meanCol(voxelIdx,:)=meanCol(voxelIdx,:)./ptsPerVoxel;
        end
        if needIntensity
            meanInt(voxelIdx)=meanInt(voxelIdx)./ptsPerVoxel;
        end
        if needNormal
            meanNorm(voxelIdx,:)=meanNorm(voxelIdx,:)./ptsPerVoxel;
        end
        if needCovariance
            coder.unroll;
            for covC=1:3
                coder.unroll;
                for covR=1:3
                    meanCov(covR,covC,voxelIdx)=(meanCov(covR,covC,voxelIdx)-...
                    meanLoc(voxelIdx,covR)*meanLoc(voxelIdx,covC)*ptsPerVoxel)/...
                    (ptsPerVoxel-1);
                end
            end
        end
    end

    if needRangeData

        coder.gpu.kernel;
        for ptIter=1:numPointsInRange
            voxelIdx=voxelIndexVector(ptIter);
            rangeVal=sqrt(meanLoc(voxelIdx,1).*meanLoc(voxelIdx,1)+...
            meanLoc(voxelIdx,2).*meanLoc(voxelIdx,2)+...
            meanLoc(voxelIdx,3).*meanLoc(voxelIdx,3));
            yawVal=asin(meanLoc(voxelIdx,3)./rangeVal);
            pitchVal=atan2(meanLoc(voxelIdx,1),meanLoc(voxelIdx,2));

            if pitchVal<0
                pitchVal=pitchVal+2*pi;
            end
            meanRData(voxelIdx,1)=rangeVal;
            meanRData(voxelIdx,2)=yawVal;
            meanRData(voxelIdx,3)=pitchVal;
        end
    end

    if minVoxelPoints>1
        coder.gpu.kernel;
        for i=1:numVoxelsTotal
            pointsPerVoxel(i)=pointsPerVoxel(i)*uint32(pointsPerVoxel(i)>=minVoxelPoints);
        end
    end


    validPointsPerVoxel=pointsPerVoxel>0;
    [meanLocations,meanColor,meanNormals,meanIntensity,meanRangeData]=...
    vision.internal.codegen.gpu.getSubsetPoints(meanLoc,meanCol,...
    meanNorm,meanInt,meanRData,validPointsPerVoxel,0,'selected');

    if needCount||needCovariance
        outIdx=cumsum(validPointsPerVoxel);
        outSize=uint32(0);
        coder.gpu.kernel;
        for i=1:2
            outSize=uint32(outIdx(numVoxelsTotal));
        end

        if needCount
            numPointsPerVoxel=zeros(outSize,1,'uint32');
            coder.gpu.kernel;
            for i=1:numVoxelsTotal
                if validPointsPerVoxel(i)
                    numPointsPerVoxel(outIdx(i))=cast(pointsPerVoxel(i),'uint32');
                end
            end
        end

        if needCovariance
            meanCovariance=zeros(3,3,outSize,outputType);
            coder.gpu.kernel;
            for i=1:numVoxelsTotal
                if validPointsPerVoxel(i)
                    meanCovariance(:,:,outIdx(i))=meanCov(:,:,i);
                end
            end
        end
    end


    if isempty(inpRange)
        outMeanLocations=cast(meanLocations,'like',inpLocations);
        if~needColor
            outMeanColor=zeros(0,3,'like',inpColor);
        else
            outMeanColor=cast(meanColor,'like',inpColor);
        end
        if~needNormal
            outMeanNormals=zeros(0,3,'like',inpNormal);
        else
            outMeanNormals=cast(meanNormals,'like',inpNormal);
        end
        if~needIntensity
            outMeanIntensity=zeros(0,1,'like',inpIntensity);
        else
            outMeanIntensity=cast(meanIntensity,'like',inpIntensity);
        end
        if~needRangeData
            outMeanRangeData=zeros(0,3,'like',inpRangeData);
        else
            outMeanRangeData=cast(meanRangeData,'like',inpRangeData);
        end
        if~needCovariance
            outMeanCovariance=zeros(3,3,0,'like',inpLocations);
        else
            outMeanCovariance=cast(meanCovariance,'like',inpLocations);
        end
    else
        [outRangeLoc,outRangeCol,outRangeNorm,outRangeIntensity,outRangeRangeData]=...
        vision.internal.codegen.gpu.getSubsetPoints(validLoc,validCol,...
        validNorm,validIntensity,validRangeData,outRangeVoxels,0,'selected');
        numPointsTotal=(numel(outRangeLoc)+numel(meanLocations))/3;

        outMeanLocations=coder.nullcopy(zeros(numPointsTotal,3,'like',inpLocations));
        if~needColor
            outMeanColor=zeros(0,3,'like',inpColor);
        else
            outMeanColor=coder.nullcopy(zeros(numPointsTotal,3,'like',inpColor));
        end
        if~needNormal
            outMeanNormals=zeros(0,3,'like',inpNormal);
        else
            outMeanNormals=coder.nullcopy(zeros(numPointsTotal,3,'like',inpNormal));
        end
        if~needIntensity
            outMeanIntensity=zeros(0,1,'like',inpIntensity);
        else
            outMeanIntensity=coder.nullcopy(zeros(numPointsTotal,1,'like',inpIntensity));
        end
        if~needRangeData
            outMeanRangeData=zeros(0,3,'like',inpRangeData);
        else
            outMeanRangeData=coder.nullcopy(zeros(numPointsTotal,3,'like',inpRangeData));
        end
        if~needCovariance
            outCovariance=nan(3,3,0,'like',inpLocations);
        else
            outCovariance=nan(3,3,numPointsTotal,'like',inpLocations);
        end

        coder.gpu.kernel;
        for ptIter=1:numPointsTotal
            if ptIter<=numel(meanLocations)/3
                outMeanLocations(ptIter,:)=cast(meanLocations(ptIter,:),'like',inpLocations);
                if needColor
                    outMeanColor(ptIter,:)=cast(meanColor(ptIter,:),'like',inpColor);
                end
                if needNormal
                    outMeanNormals(ptIter,:)=cast(meanNormals(ptIter,:),'like',inpNormal);
                end
                if needIntensity
                    outMeanIntensity(ptIter,:)=cast(meanIntensity(ptIter),'like',inpIntensity);
                end
                if needRangeData
                    outMeanRangeData(ptIter,:)=cast(meanRangeData(ptIter,:),'like',inpRangeData);
                end
                if needCovariance
                    outCovariance(:,:,ptIter)=cast(meanCovariance(:,:,ptIter),'like',inpLocations);
                end
            else
                trueIdx=ptIter-numel(meanLocations)/3;
                outMeanLocations(ptIter,:)=cast(outRangeLoc(trueIdx,:),'like',inpLocations);
                if needColor
                    outMeanColor(ptIter,:)=cast(outRangeCol(trueIdx,:),'like',inpColor);
                end
                if needNormal
                    outMeanNormals(ptIter,:)=cast(outRangeNorm(trueIdx,:),'like',inpNormal);
                end
                if needIntensity
                    outMeanIntensity(ptIter,:)=cast(outRangeIntensity(trueIdx),'like',inpIntensity);
                end
                if needRangeData
                    outMeanRangeData(ptIter,:)=cast(outRangeRangeData(trueIdx,:),'like',inpRangeData);
                end
            end
        end
    end
end





function c=minFunc(a,b)
    if isnan(a)&&isnan(b)
        c=a;
    elseif isnan(a)
        c=b;
    elseif isnan(b)
        c=a;
    else
        c=min(a,b);
    end
end

function c=maxFunc(a,b)
    if isnan(a)&&isnan(b)
        c=a;
    elseif isnan(a)
        c=b;
    elseif isnan(b)
        c=a;
    else
        c=max(a,b);
    end
end
