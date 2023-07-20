

function[outLoc,outCol,outNorm,outInt,outRData]=...
    pcmergeGPUImpl(ptCloudALoc,ptCloudACol,ptCloudAInt,ptCloudANorm,ptCloudARData,...
    ptCloudBLoc,ptCloudBCol,ptCloudBInt,ptCloudBNorm,ptCloudBRData,gridStep)
%#codegen
















































    coder.gpu.kernelfun;
    coder.allowpcode('plain');
    coder.inline('never');

    isOrganizedA=~ismatrix(ptCloudALoc);
    isOrganizedB=~ismatrix(ptCloudBLoc);


    if~isempty(ptCloudALoc)
        indicesA=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(ptCloudALoc);
        [pointsA,colorA,normalsA,intensityA,rangeDataA]=...
        vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(ptCloudALoc,ptCloudACol,...
        ptCloudANorm,ptCloudAInt,ptCloudARData,indicesA,isOrganizedA,'selected');
    else
        pointsA=zeros(0,3,'like',ptCloudALoc);
        colorA=cast([],'uint8');
        normalsA=cast([],'like',ptCloudALoc);
        intensityA=cast([],'like',ptCloudALoc);
        rangeDataA=cast([],'like',ptCloudALoc);
    end

    if~isempty(ptCloudBLoc)
        indicesB=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(ptCloudBLoc);
        [pointsB,colorB,normalsB,intensityB,rangeDataB]=...
        vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(ptCloudBLoc,ptCloudBCol,...
        ptCloudBNorm,ptCloudBInt,ptCloudBRData,indicesB,isOrganizedB,'selected');
    else
        pointsB=zeros(0,3,'like',ptCloudBLoc);
        colorB=cast([],'uint8');
        normalsB=cast([],'like',ptCloudBLoc);
        intensityB=cast([],'like',ptCloudBInt);
        rangeDataB=cast([],'like',ptCloudBLoc);
    end


    if isempty(pointsA)&&isempty(pointsB)

        outLoc=zeros(0,3,'like',ptCloudALoc);
        outCol=cast([],'like',ptCloudACol);
        outNorm=cast([],'like',ptCloudANorm);
        outInt=cast([],'like',ptCloudAInt);
        outRData=cast([],'like',ptCloudARData);

    elseif isempty(pointsB)

        outLoc=pointsA;
        outCol=colorA;
        outNorm=normalsA;
        outInt=intensityA;
        outRData=rangeDataA;

    elseif isempty(pointsA)

        outLoc=pointsB;
        outCol=colorB;
        outNorm=normalsB;
        outInt=intensityB;
        outRData=rangeDataB;

    else

        numPointsA=numel(pointsA)/3;
        numPointsB=numel(pointsB)/3;

        mergedLocMat=concatMat(pointsA,numPointsA,pointsB,numPointsB);
        mergedColMat=concatMat(colorA,numPointsA,colorB,numPointsB);
        mergedNormMat=concatMat(normalsA,numPointsA,normalsB,numPointsB);
        mergedIntMat=concatMat(intensityA,numPointsA,intensityB,numPointsB);
        mergedRDataMat=concatMat(rangeDataA,numPointsA,rangeDataB,numPointsB);


        rangeLimits=overlapRangeGPUImpl(pointsA,numPointsA,pointsB,numPointsB);

        if isempty(rangeLimits)
            outLoc=mergedLocMat;
            outCol=mergedColMat;
            outNorm=mergedNormMat;
            outInt=mergedIntMat;
            outRData=mergedRDataMat;

        else

            [outLoc,outCol,outNorm,outInt,outRData]=...
            vision.internal.codegen.gpu.voxelGridFilter(mergedLocMat,mergedColMat,...
            mergedNormMat,mergedIntMat,mergedRDataMat,gridStep,1,rangeLimits);
        end
    end

end


function outMat=concatMat(inpMatA,numPointsA,inpMatB,numPointsB)
%#codegen

    emptyPtCloud=isempty(inpMatA)||isempty(inpMatB);
    if~emptyPtCloud
        totalPoints=numPointsA+numPointsB;
        outMat=coder.nullcopy(zeros(totalPoints,size(inpMatA,2),'like',inpMatA));
        coder.gpu.kernel;
        for iter=1:totalPoints
            if iter<=numPointsA
                outMat(iter,:)=inpMatA(iter,:);
            else
                outMat(iter,:)=inpMatB(iter-numPointsA,:);
            end
        end
    else
        outMat=zeros(0,size(inpMatA,2),class(inpMatA));
    end
end


function rangeLimits=overlapRangeGPUImpl(inpPointsA,numPointsA,inpPointsB,numPointsB)
%#codegen


    tmpMat=inpPointsA(1:numPointsA);
    xlimA=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
    tmpMat=inpPointsA(numPointsA+1:numPointsA*2);
    ylimA=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
    tmpMat=inpPointsA(2*numPointsA+1:numPointsA*3);
    zlimA=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});


    tmpMat=inpPointsB(1:numPointsB);
    xlimB=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
    tmpMat=inpPointsB(numPointsB+1:numPointsB*2);
    ylimB=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});
    tmpMat=inpPointsB(2*numPointsB+1:numPointsB*3);
    zlimB=gpucoder.reduce(tmpMat(:),{@minFunc,@maxFunc});

    if(xlimA(1)>xlimB(2)||xlimA(2)<xlimB(1)||...
        ylimA(1)>ylimB(2)||ylimA(2)<ylimB(1)||...
        zlimA(1)>zlimB(2)||zlimA(2)<zlimB(1))

        rangeLimits=cast([],'like',xlimA);
    else
        rangeLimits=[max(xlimA(1),xlimB(1)),min(xlimA(2),xlimB(2))...
        ,max(ylimA(1),ylimB(1)),min(ylimA(2),ylimB(2))...
        ,max(zlimA(1),zlimB(1)),min(zlimA(2),zlimB(2))];
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
