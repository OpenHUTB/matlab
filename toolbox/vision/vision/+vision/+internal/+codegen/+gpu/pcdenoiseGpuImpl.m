

function[outLocations,outColor,outIntensity,outNormals,...
    outRangeData,inlierIndices,outlierIndices]=...
    pcdenoiseGpuImpl(inpLocations,inpColor,inpIntensity,...
    inpNormals,inpRangeData,numNeighbors,thresholdVal)
%#codegen




















    coder.gpu.kernelfun;
    coder.allowpcode('plain');
    coder.inline('never');


    isOrganized=ndims(inpLocations)==3;
    numPoints=numel(inpLocations)/3;


    validIdx=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(inpLocations);
    [validLocations,validColor,validNormal,validIntensity,validRangeData]=...
    vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(inpLocations,inpColor,...
    inpNormals,inpIntensity,inpRangeData,validIdx,isOrganized,'selected');
    numValidPoints=numel(validLocations)/3;


    if numValidPoints==0
        outLocations=validLocations;
        outColor=validColor;
        outIntensity=validIntensity;
        outNormals=validNormal;
        outRangeData=validRangeData;
        inlierIndices=zeros(1,0,'uint32');
        outlierIndices=uint32(1:numPoints);
        return;
    end


    [~,distMat,~]=...
    vision.internal.codegen.gpu.PointCloudImpl.multiQueryKNNSearchImpl(...
    validLocations,validLocations,numNeighbors+1);


    meanDist=distMat(1,:);
    coder.gpu.kernel;
    for j=1:numValidPoints
        for i=2:numNeighbors+1
            meanDist(j)=meanDist(j)+distMat(i,j);
        end
    end
    meanDist=meanDist/numNeighbors;


    meanOfAllDists=sum(meanDist)/numValidPoints;
    diffMat=meanDist-meanOfAllDists;
    diffMat=diffMat.^2;
    stdDevOfAllDists=sqrt(sum(diffMat)/numValidPoints);
    distThreshold=meanOfAllDists+thresholdVal*stdDevOfAllDists;


    inlierLocations=meanDist<=distThreshold;
    [outLocations,outColor,outNormals,outIntensity,outRangeData]=...
    vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(validLocations,validColor,...
    validNormal,validIntensity,validRangeData,inlierLocations,0,'selected');


    outIdx=cumsum(validIdx);
    inlierIndicesLogical=false(1,numPoints);
    for iter=1:numPoints
        if validIdx(iter)&&inlierLocations(outIdx(iter))
            inlierIndicesLogical(iter)=true;
        end
    end
    outlierIndicesLogical=~inlierIndicesLogical;


    pointLinearIndex=uint32(1:numPoints);
    inlierIndices=findGPUImpl(pointLinearIndex,inlierIndicesLogical);
    outlierIndices=findGPUImpl(pointLinearIndex,outlierIndicesLogical);
end



function[outMat,outSize]=findGPUImpl(inpMat,predMatInp)
%#codegen

    coder.gpu.kernelfun;
    coder.allowpcode('plain');


    [inpRows,inpCols]=size(inpMat);
    predLength=length(predMatInp);

    if isempty(predMatInp)||isempty(inpMat)
        outMat=zeros(size(inpMat),'like',inpMat);
        outSize=uint32(0);
        return;
    end

    if~(isvector(predMatInp)&&(inpRows==size(predMatInp,1)||inpCols==size(predMatInp,2)))

        outMat=zeros(size(inpMat),'like',inpMat);
        outSize=uint32(0);
        return;
    end


    if~islogical(predMatInp)
        predMat=(predMatInp>0);
    else
        predMat=predMatInp;
    end

    if~coder.gpu.internal.isGpuEnabled
        zeroMat=bsxfun(@times,inpMat,predMat);
        outSize=uint32(nnz(predMat));
        if isrow(predMat)
            outMatSize=[inpRows,outSize];
            nonZeroValues=zeroMat(find(zeroMat));
            outMat=reshape(nonZeroValues,outMatSize);
        else
            outMatSize=[outSize,inpCols];
            nonZeroValues=zeroMat(find(zeroMat));
            outMat=reshape(nonZeroValues,outMatSize);
        end

    else

        idxMat=predMat;
        idxMat=cumsum(idxMat);



        outSize=uint32(0);
        coder.gpu.kernel;
        for i=1:1
            outSize=uint32(idxMat(predLength));
        end



        if isrow(predMat)
            outMat=coder.nullcopy(zeros(inpRows,outSize,'like',inpMat));
            coder.gpu.kernel;
            for i=1:size(inpMat,2)
                for j=1:size(inpMat,1)
                    if predMat(i)
                        outMat(j,idxMat(i))=inpMat(j,i);
                    end
                end
            end
        else


            outMat=coder.nullcopy(zeros(outSize,inpCols,'like',inpMat));
            coder.gpu.kernel;
            for i=1:size(inpMat,2)
                for j=1:size(inpMat,1)
                    if predMat(j)
                        outMat(idxMat(j),i)=inpMat(j,i);
                    end
                end
            end
        end
    end
end
