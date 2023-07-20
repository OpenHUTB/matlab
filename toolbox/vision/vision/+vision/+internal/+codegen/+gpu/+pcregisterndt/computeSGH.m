














function[score,gradient,hessian]=computeSGH(qryPoints,qryPointsTransformedMat,...
    Ja,Ha,fixedVoxelMeans,fixedVoxelICov,nghbrsIdxMat,numNgbrsMat,numRefPoints,d1,d2)
%#codegen

    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');

    numQryPoints=numel(qryPoints)/3;
    maxNgbrsMat=gpucoder.reduce(numNgbrsMat,@findMax);
    maxNgbrs=maxNgbrsMat(1);

    scoreSumLocal=zeros(maxNgbrs,numQryPoints,'like',qryPoints);
    gradientSumLocal=zeros(6,maxNgbrs,numQryPoints,'like',qryPoints);
    hessianSumLocal=zeros(6,6,maxNgbrs,numQryPoints,'like',qryPoints);


    if maxNgbrs
        coder.gpu.kernel;
        for ptIter=1:numQryPoints
            coder.gpu.kernel;
            for ngbrIter=1:maxNgbrs
                if 0<numNgbrsMat(ptIter)&&ngbrIter<=numNgbrsMat(ptIter)




                    ngbrIdx=nghbrsIdxMat(ngbrIter,ptIter);
                    voxelMean=[fixedVoxelMeans(ngbrIdx);...
                    fixedVoxelMeans(ngbrIdx+numRefPoints);...
                    fixedVoxelMeans(ngbrIdx+2*numRefPoints)];

                    qryPointMeanSubtracted=[qryPointsTransformedMat(ptIter,1)-voxelMean(1);...
                    qryPointsTransformedMat(ptIter,2)-voxelMean(2);
                    qryPointsTransformedMat(ptIter,3)-voxelMean(3)];


                    voxelICov=fixedVoxelICov(:,:,ngbrIdx);


                    prod=[0,0,0];
                    prod(1)=voxelICov(1,1)*qryPointMeanSubtracted(1)+...
                    voxelICov(1,2)*qryPointMeanSubtracted(2)+...
                    voxelICov(1,3)*qryPointMeanSubtracted(3);

                    prod(2)=voxelICov(2,1)*qryPointMeanSubtracted(1)+...
                    voxelICov(2,2)*qryPointMeanSubtracted(2)+...
                    voxelICov(2,3)*qryPointMeanSubtracted(3);

                    prod(3)=voxelICov(3,1)*qryPointMeanSubtracted(1)+...
                    voxelICov(3,2)*qryPointMeanSubtracted(2)+...
                    voxelICov(3,3)*qryPointMeanSubtracted(3);

                    prodValue=qryPointMeanSubtracted(1).*prod(1)+...
                    qryPointMeanSubtracted(2).*prod(2)+...
                    qryPointMeanSubtracted(3).*prod(3);


                    scoreSumLocal(ngbrIter,ptIter)=double(-d1*exp(-d2*(prodValue/2.0)));
                end
            end
        end


        coder.gpu.kernel;
        for ptIter=1:numQryPoints
            coder.gpu.kernel;
            for ngbrIter=1:maxNgbrs
                if 0<ngbrIter&&ngbrIter<=numNgbrsMat(ptIter)




                    ngbrIdx=nghbrsIdxMat(ngbrIter,ptIter);
                    voxelMean=[fixedVoxelMeans(ngbrIdx);...
                    fixedVoxelMeans(ngbrIdx+numRefPoints);...
                    fixedVoxelMeans(ngbrIdx+2*numRefPoints)];

                    qryPointMeanSubtracted=[qryPointsTransformedMat(ptIter,1)-voxelMean(1);...
                    qryPointsTransformedMat(ptIter,2)-voxelMean(2);
                    qryPointsTransformedMat(ptIter,3)-voxelMean(3)];


                    voxelICov=fixedVoxelICov(:,:,ngbrIdx);


                    [Jp,Hp]=vision.internal.codegen.gpu.pcregisterndt.jacobianHessian(Ja,Ha,qryPoints(ptIter,:));
                    [grad,hess]=vision.internal.codegen.gpu.pcregisterndt.gradientHessian(qryPointMeanSubtracted,voxelICov,d1,d2,Jp,Hp);
                    gradientSumLocal(:,ngbrIter,ptIter)=double(grad);
                    hessianSumLocal(:,:,ngbrIter,ptIter)=double(hess);
                end
            end
        end

        sumVal=gpucoder.reduce(scoreSumLocal(:),@funcSum);
        score=sumVal(1);

        gradient=zeros(6,1,'like',qryPoints);
        coder.gpu.nokernel;
        for i=1:6
            tmpMat=gradientSumLocal(i,:);
            sumVal=gpucoder.reduce(tmpMat,@funcSum);
            gradient(i,1)=sumVal(1);
        end

        if gpucoder.getComputeCapability>=6.1


            hessian=zeros(6,6,'like',qryPoints);
            hessianSumLocalSize=size(hessianSumLocal);
            coder.gpu.kernel
            for dim4=1:hessianSumLocalSize(4)
                coder.gpu.kernel
                for dim3=1:hessianSumLocalSize(3)
                    coder.gpu.kernel
                    for col=1:hessianSumLocalSize(2)
                        coder.gpu.kernel
                        for row=1:hessianSumLocalSize(1)
                            hessian(row,col)=gpucoder.atomicAdd(...
                            hessian(row,col),...
                            hessianSumLocal(row,col,dim3,dim4));
                        end
                    end
                end
            end
        else


            hessian=coder.nullcopy(zeros(6,6,'like',qryPoints));
            tempSum=gpucoder.reduce(hessianSumLocal,{@funcSum},'dim',4);
            hessianVardim=gpucoder.reduce(tempSum,{@funcSum},'dim',3);
            for idx=1:36
                hessian(idx)=hessianVardim(idx);
            end
        end
    else
        score=0;
        gradient=zeros(6,1,'like',qryPoints);
        hessian=zeros(6,6,'like',qryPoints);
    end
end

function c=funcSum(a,b)
    c=a+b;
end

function c=findMax(a,b)
    c=max(a,b);
end
