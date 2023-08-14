

function[isFound,bestModelParams,bestInliers,bestInlierNum,bestmError]=...
    msac(inpLoc,params,referenceVector,maxAngularDist)











































%#codegen

    coder.gpu.kernelfun;
    coder.inline('never');
    coder.allowpcode('plain');


    sampleSize=params.sampleSize;
    maxDist=params.maxDistance;
    maxSkipTrials=params.maxNumTrials*10;
    maxNumTrails=params.maxNumTrials;
    numPoints=numel(inpLoc)/3;



    if~coder.gpu.internal.isGpuEnabled
        outputType=class(inpLoc);
    else
        computeCapability=gpucoder.getComputeCapability;
        if computeCapability>=6.1
            outputType='double';
        else
            outputType='single';
        end
    end





    coder.extrinsic('vision.internal.testEstimateGeometricTransform');
    if(coder.target('MEX')&&vision.internal.testEstimateGeometricTransform)...
        ||coder.target('Rtw')
        rng('default');
        randNumMat=uint32(randi(numPoints,maxSkipTrials,sampleSize));
    else
        randNumMat=uint32(vision.internal.codegen.gpu.pcfitplane.randomNumberGen...
        (numPoints,maxSkipTrials*(sampleSize)));
        randNumMat=reshape(randNumMat,[maxSkipTrials,sampleSize]);
    end

    isValidModel=false(maxNumTrails,1);
    modelMat=zeros(maxNumTrails,4,'like',inpLoc);
    invalidModelCounter=uint32(1);



    coder.gpu.kernel;
    for trailIter=1:maxNumTrails
        iter=trailIter;
        checkIter=~isValidModel(trailIter);
        strideVal=maxNumTrails;
        while checkIter&&iter<=maxSkipTrials
            checkFlag=randNumMat(iter,1)~=randNumMat(iter,2)&&...
            randNumMat(iter,2)~=randNumMat(iter,3)&&...
            randNumMat(iter,3)~=randNumMat(iter,1);

            if checkFlag
                pointIndices=randNumMat(iter,:);
                pointsMat=[inpLoc(pointIndices(1)),inpLoc(pointIndices(1)+numPoints),inpLoc(pointIndices(1)+2*numPoints);...
                inpLoc(pointIndices(2)),inpLoc(pointIndices(2)+numPoints),inpLoc(pointIndices(2)+2*numPoints);...
                inpLoc(pointIndices(3)),inpLoc(pointIndices(3)+numPoints),inpLoc(pointIndices(3)+2*numPoints)];
                modelMat(trailIter,:)=fitPlaneGPUImpl(pointsMat);
                if isempty(referenceVector)


                    isValidModel(trailIter)=checkPlaneGPUImpl(modelMat(trailIter,:));
                else


                    isValidModel(trailIter)=checkPerpendicularPlaneGPUImpl(modelMat(trailIter,:),referenceVector,maxAngularDist);
                end
            end
            checkIter=~isValidModel(trailIter);
            if checkIter
                [invalidModelCounter,oldVal]=gpucoder.atomicAdd(invalidModelCounter,uint32(1));
                iter=strideVal+cast(oldVal,'like',iter);
                strideVal=0;
            end
        end
    end




    distMat=coder.internal.inf(numPoints,maxNumTrails,outputType);
    coder.gpu.kernel;
    for iter=1:maxNumTrails
        coder.gpu.kernel;
        for ptIter=1:numPoints


            if isValidModel(iter)
                distMat(ptIter,iter)=inpLoc(ptIter,:)*[modelMat(iter,1);...
                modelMat(iter,2);modelMat(iter,3)];
                distMat(ptIter,iter)=abs(distMat(ptIter,iter)+modelMat(iter,4));
            end
        end
    end

    threshold=maxDist;
    accDist=zeros(maxNumTrails,1,outputType);
    inlierPts=zeros(numPoints,maxNumTrails);
    inlierNum=zeros(maxNumTrails,1,'uint32');
    mError=coder.nullcopy(zeros(maxNumTrails,1,outputType));
    checkMat=coder.nullcopy(zeros(numPoints,maxNumTrails));


    coder.gpu.kernel;
    for iter=1:maxNumTrails
        coder.gpu.kernel;
        for pIter=1:numPoints
            if isValidModel(iter)
                checkMat(pIter,iter)=double(distMat(pIter,iter)>=threshold);
                distMat(pIter,iter)=checkMat(pIter,iter)*threshold+...
                ~checkMat(pIter,iter)*distMat(pIter,iter);

                inlierPts(pIter,iter)=~checkMat(pIter,iter);
            end
        end
    end




    strideVal=numPoints/10;
    coder.gpu.kernel;
    for iter=1:(maxNumTrails*numPoints)/strideVal
        coder.gpu.nokernel;
        for pIter=1:strideVal

            temIt=((iter-1)*strideVal)+pIter;
            tempIter=floor(temIt/numPoints)+1;

            tempCheck=isValidModel(tempIter)&&~checkMat(temIt);

            accDist(tempIter)=gpucoder.atomicAdd(accDist(tempIter),...
            (isValidModel(tempIter)*distMat(temIt)+...
            ~isValidModel(tempIter)*realmax(outputType)));

            mError(tempIter)=gpucoder.atomicAdd(mError(tempIter),...
            (tempCheck)*distMat(temIt));

            inlierNum(tempIter)=gpucoder.atomicAdd(inlierNum(tempIter),...
            uint32(tempCheck));
        end
    end



    [~,minIdx]=min(accDist);


    bestModelParams=modelMat(minIdx,:);
    bestInliers=inlierPts(:,minIdx);
    bestInlierNum=inlierNum(minIdx);
    bestmError=double(mError(minIdx)/double(bestInlierNum));
    bestmError=cast(bestmError,class(inpLoc));



    if isempty(referenceVector)
        isFound=checkPlaneGPUImpl(bestModelParams(:))&&...
        ~isempty(bestInliers)&&bestInlierNum>=sampleSize;
    else
        isFound=checkPerpendicularPlaneGPUImpl(bestModelParams(:),...
        referenceVector,maxAngularDist)&&~isempty(bestInliers)&&bestInlierNum>=sampleSize;
    end

end


function model=fitPlaneGPUImpl(points)
%#codegen
    a=points(2,:)-points(1,:);
    b=points(3,:)-points(1,:);

    normal=[a(2).*b(3)-a(3).*b(2),...
    a(3).*b(1)-a(1).*b(3),...
    a(1).*b(2)-a(2).*b(1)];
    denom=normal(1)*normal(1)+normal(2)*normal(2)+normal(3)*normal(3);
    if denom<eps(class(points))
        model=coder.internal.inf(1,4,'like',points);
    else
        normal=normal/sqrt(denom);
        d=-(points(1,1)*normal(1)+points(1,2)*normal(2)+...
        points(1,3)*normal(3));
        model=cast([normal,d],'like',points);
    end
end

function isValid=checkPlaneGPUImpl(modelMat)
%#codegen
    isValid=(numel(modelMat)==4)&isfinite(modelMat(1))&...
    isfinite(modelMat(2))&isfinite(modelMat(3));
end

function isValid=checkPerpendicularPlaneGPUImpl(model,normAxis,threshold)
%#codegen
    coder.inline('never')
    isValid=numel(model)==4&&isfinite(model(1))&&isfinite(model(2))...
    &&isfinite(model(3))&&isfinite(model(4));
    if isValid
        temp=normAxis(1)*model(1)+normAxis(2)*model(2)+normAxis(3)*model(3);
        a=min(1,max(-1,temp));
        angle=abs(acos(a));
        angle=min(angle,pi-angle);
        isValid=angle<threshold;
    end
end
