
















































function[labels,numClusters]=pcsegdistImpl(pointCloudLocations,minDist,maxNeighbors)
%#codegen



    if nargin<3
        maxNeighbors=numel(pointCloudLocations)/3;
    end


    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    if isempty(pointCloudLocations)
        labels=zeros(0,1,'uint32');
        numClusters=cast(0,'like',pointCloudLocations);
        return;
    end


    [validLocations,validIndices]=removeInvalidPoints(pointCloudLocations);



    if isempty(validLocations)
        isOrganized=ndims(pointCloudLocations)==3;
        if isOrganized
            labels=zeros(size(pointCloudLocations,1),size(pointCloudLocations,2),'uint32');
        else
            labels=zeros(size(pointCloudLocations,1),1,'uint32');
        end
        numClusters=cast(0,'like',pointCloudLocations);
        return;
    end



    maxVal=max(abs(validLocations(:)));
    if minDist>=maxVal
        if ndims(pointCloudLocations)==3
            labels=ones(size(pointCloudLocations,1),size(pointCloudLocations,2),'uint32');
        else
            labels=ones(size(pointCloudLocations,1),1,'uint32');
        end
        for i=1:numel(labels)
            if~validIndices(i)
                labels(i)=0;
            end
        end
        numClusters=cast(1,'like',pointCloudLocations);
        return;
    end




    LARGE_POINTCLOUD=2^16;
    numPoints=size(validLocations,1);
    if numPoints>=LARGE_POINTCLOUD
        maxNeighbors=ceil(0.01*numPoints);
    end


    adjListPtrArray=coder.nullcopy(zeros(1,numPoints,'uint32'));



    numNghbrArray=computeNeighbors(validLocations,minDist,maxNeighbors);


    adjListPtrArray(1)=1;
    adjListPtrArray(2:end)=cumsum(numNghbrArray(1:end-1))+1;


    [adjListArray,clusterIdxArray]=computeAdjacentListArray(validLocations,...
    adjListPtrArray,minDist,numNghbrArray);




    reIterateFlag=true;
    while(reIterateFlag)
        for tmpIter=1:2
            [clusterIdxArray,reIterateFlag]=readjustClusterIdx(clusterIdxArray,reIterateFlag);
            [clusterIdxArray,reIterateFlag]=checkNearestNeighbors(adjListArray,...
            adjListPtrArray,numNghbrArray,clusterIdxArray,reIterateFlag);
        end
    end


    [outIdxArray,numClusters]=getUniqueLabels(clusterIdxArray);


    labels=reshapeLabels(outIdxArray,validIndices,size(pointCloudLocations));
    numClusters=cast(numClusters,'like',pointCloudLocations);
end


function[validLocations,indices]=removeInvalidPoints(locs)
%#codegen

    isOrganized=ndims(locs)==3;
    indices=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(locs);
    idxPos=cumsum(indices);
    outLength=idxPos(end);

    validLocations=coder.nullcopy(zeros(outLength,3));


    idxPos=idxPos.*indices;
    coder.gpu.internal.kernelImpl(false);
    for i=1:length(idxPos)
        if idxPos(i)
            if isOrganized
                [posR,posC]=ind2sub([size(locs,1),size(locs,2)],i);
                validLocations(idxPos(i),:)=locs(posR,posC,:);
            else
                validLocations(idxPos(i),:)=locs(i,:);
            end
        end
    end
end


function labels=reshapeLabels(labelsLin,indices,outSize)
%#codegen

    if numel(outSize)==3
        labels=zeros(outSize(1),outSize(2),'uint32');
    else
        labels=zeros(outSize(1),1,'uint32');
    end

    k=1;
    for i=1:numel(labels)
        if indices(i)
            labels(i)=labelsLin(k);
            k=k+1;
        end
    end
end


function numNghbrArray=computeNeighbors(ptCloudLoc,radius,maxNeighbors)
%#codegen
    numPts=size(ptCloudLoc,1);
    numNghbrArray=zeros(1,numPts,'uint32');

    coder.gpu.internal.kernelImpl(false);
    for colIter=1:numPts
        refPt=ptCloudLoc(colIter,:);
        numNgbrCount=uint32(0);
        for rowIter=1:numPts
            diffMat=ptCloudLoc(rowIter,:)-refPt;
            diffMat_sum=diffMat(1)*diffMat(1)+...
            diffMat(2)*diffMat(2)+diffMat(3)*diffMat(3);
            numNgbrCount=numNgbrCount+uint32(diffMat_sum<=radius*radius);
        end
        numNghbrArray(colIter)=min(numNgbrCount,maxNeighbors);
    end
end


function[aListArray,cIdxArray]=computeAdjacentListArray(ptCloudLoc,aListPtrArray,...
    radius,numNghbrArray)
%#codegen
    numPts=size(ptCloudLoc,1);
    cIdxArray=uint32(1:numPts)';
    aListArray=coder.nullcopy(zeros(numNghbrArray(end)+aListPtrArray(end)-1,1,'uint32'));

    coder.gpu.internal.kernelImpl(false);
    for qPtIter=1:numPts
        numNgbrs=numNghbrArray(qPtIter);
        startIdx=aListPtrArray(qPtIter);
        refLoc=ptCloudLoc(qPtIter,:);
        for ptIter=1:numPts

            diffVal=refLoc-ptCloudLoc(ptIter,:);
            diffVal=diffVal.*diffVal;
            dist=sum(diffVal);

            if dist<=radius*radius&&startIdx-aListPtrArray(qPtIter)<numNgbrs
                aListArray(startIdx)=ptIter;
                startIdx=startIdx+1;

                cIdxArray(ptIter)=min(cIdxArray(ptIter),qPtIter);
                cIdxArray(qPtIter)=min(cIdxArray(qPtIter),cIdxArray(ptIter));
            end
        end
    end
end


function[clusterIdxArray,reIterateFlag]=readjustClusterIdx(clusterIdxArray,reIterateFlag)
%#codegen

    numPts=length(clusterIdxArray);
    coder.gpu.internal.kernelImpl(false);
    for ptIter=1:numPts
        ref=clusterIdxArray(clusterIdxArray(ptIter));
        label=clusterIdxArray(ptIter);
        origIdx=clusterIdxArray(ptIter);

        while(label~=ref)
            label=ref;
            ref=clusterIdxArray(label);
        end

        if label~=origIdx
            clusterIdxArray(ptIter)=label;
        end
        reIterateFlag=false;
    end
end


function[clusterIdxArray,reIterateFlag]=checkNearestNeighbors(adjListArray,...
    adjListPtrArray,numNghbrArray,clusterIdxArray,reIterateFlag)
%#codegen

    numPts=length(clusterIdxArray);

    coder.gpu.internal.kernelImpl(false);
    for qPtIter=1:numPts
        minIdx=uint32(inf);
        startIdx=adjListPtrArray(qPtIter);
        for ptIter=0:numNghbrArray(qPtIter)-1
            cIdx=clusterIdxArray(adjListArray(startIdx+ptIter));
            if(cIdx<minIdx)
                minIdx=cIdx;
            end
        end

        if clusterIdxArray(qPtIter)>minIdx
            clusterIdxArray(qPtIter)=minIdx;
            reIterateFlag=true;
        end
    end
end


function[outVectFinal,numClusters]=getUniqueLabels(inpVect)%#codegen


    [sortedVect,sortedIdx]=gpucoder.sort(inpVect);

    diffMat=[0;double(sortedVect(1:end-1))]-[0;double(sortedVect(2:end))];
    diffMat_logical=diffMat<0;

    outIdx=cumsum(diffMat_logical);
    numClusters=cast(outIdx(end)+1,'uint32');

    outVectFinal=inpVect;
    coder.gpu.internal.kernelImpl(false);
    for i=1:length(inpVect)
        outVectFinal(sortedIdx(i))=outIdx(i)+1;
    end
end