function[model,inlierIndices,outlierIndices,meanError]=...
    pcfitplaneGpuImpl(ptCloud,ransacParams,sampleIndices,referenceVector,maxAngularDistance)

%#codegen

    coder.gpu.kernelfun;
    coder.inline('never');
    coder.allowpcode('plain');
    [statusCode,status,validLocations,indices]=...
    vision.internal.codegen.gpu.pcfitplane.initializeRansacModel...
    (ptCloud,sampleIndices,ransacParams.sampleSize);

    linearInd=1:numel(indices);
    validIndices=vision.internal.codegen.gpu.pcfitplane.findGpuImpl(linearInd',indices);
    modelParams=zeros(1,4,'like',validLocations);
    inlierInd=zeros(1,numel(validIndices));
    inlierNum=uint32(0);
    meanError=cast(0,'like',ptCloud.Location);

    if status==statusCode.NoError

        if~isempty(referenceVector)
            denorm=sqrt(referenceVector(1)*referenceVector(1)+...
            referenceVector(2)*referenceVector(2)+...
            referenceVector(3)*referenceVector(3));
            referenceVector=referenceVector./denorm;
        end
        [isFound,modelParams,inlierInd,inlierNum,meanError]=...
        vision.internal.codegen.gpu.pcfitplane.msac(validLocations,ransacParams,...
        referenceVector,maxAngularDistance);

        if isFound&&~isempty(referenceVector)
            normModelDot=referenceVector(1)*modelParams(1)+...
            referenceVector(2)*modelParams(2)+...
            referenceVector(3)*modelParams(3);
            a=min(1,max(-1,normModelDot));
            angle=abs(acos(a));
            if angle>pi/2
                modelParams=-modelParams;
            end
        end

        if~isFound
            status=statusCode.NotEnoughInliers;
        end
    end

    if(isempty(modelParams))||(~isfinite(modelParams(1))&&~isfinite(modelParams(2))&&...
        ~isfinite(modelParams(3))&&~isfinite(modelParams(4)))
        modelParams=zeros(1,4,'like',validLocations);
    end

    model=planeModel(modelParams);
    vision.internal.ransac.checkRansacRuntimeStatus(statusCode,status);

    if status==statusCode.NoError
        inlierIndices=vision.internal.codegen.gpu.pcfitplane.findGpuImpl(validIndices,inlierInd);

        falseVect=ones(ptCloud.Count,1);
        coder.gpu.kernel;
        for iter=1:inlierNum
            falseVect(inlierIndices(iter))=0;
        end
        linearIdx=1:ptCloud.Count;
        outlierIndices=vision.internal.codegen.gpu.pcfitplane.findGpuImpl(linearIdx',falseVect);

    else
        inlierIndices=[];
        outlierIndices=[];
        meanError=cast([],'like',ptCloud.Location);
    end

end



