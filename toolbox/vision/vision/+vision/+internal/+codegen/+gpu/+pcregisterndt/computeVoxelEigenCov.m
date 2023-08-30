
function[voxelMeans,voxelInvCov,voxelCovs,voxelNumPoints]=computeVoxelEigenCov(xyzPoints,voxelSize,minVoxelPoints,eigenValueRatio,inpRange)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.inline('never');

    if nargin==4
        inpRange=[];
    elseif nargin==3
        inpRange=[];
        eigenValueRatio=100;
    elseif nargin==2
        inpRange=[];
        eigenValueRatio=100;
        minVoxelPoints=1;
    end
    [voxelMeans,~,~,~,~,voxelCovs,voxelNumPoints]=...
    vision.internal.codegen.gpu.voxelGridFilter(xyzPoints,[],[],[],[],voxelSize,minVoxelPoints,inpRange);

    numCovMat=size(voxelCovs,3);
    voxelInvCov=nan(size(voxelCovs),'like',voxelCovs);
    [eigenLeft,eigenVal,eigenRight]=vision.internal.codegen.gpu.computeBatchedSvd(voxelCovs);

    coder.gpu.kernel;
    for iter=1:numCovMat

        isValidCovMat=true;
        for c=1:3
            for r=1:3
                if~isfinite(voxelCovs(r,c,iter))
                    isValidCovMat=false;
                end
            end
        end

        if isValidCovMat
            maxEigenValue=max(eigenVal(1,iter),max(eigenVal(2,iter),eigenVal(3,iter)));

            if maxEigenValue>=eigenVal(1,iter)*eigenValueRatio
                eigenVal(1,iter)=maxEigenValue/eigenValueRatio;
            end
            if maxEigenValue>=eigenVal(2,iter)*eigenValueRatio
                eigenVal(2,iter)=maxEigenValue/eigenValueRatio;
            end
            if maxEigenValue>=eigenVal(3,iter)*eigenValueRatio
                eigenVal(3,iter)=maxEigenValue/eigenValueRatio;
            end
            eigenValInv=zeros(3,'like',voxelCovs);
            eigenValInv(1,1)=1/eigenVal(1,iter);
            eigenValInv(2,2)=1/eigenVal(2,iter);
            eigenValInv(3,3)=1/eigenVal(3,iter);
            eigenValMat=zeros(3,'like',voxelCovs);
            eigenValMat(1,1)=eigenVal(1,iter);
            eigenValMat(2,2)=eigenVal(2,iter);
            eigenValMat(3,3)=eigenVal(3,iter);
            voxelCovs(:,:,iter)=eigenLeft(:,:,iter)*eigenValMat*transpose(eigenRight(:,:,iter));
            voxelInvCov(:,:,iter)=eigenLeft(:,:,iter)*eigenValInv*transpose(eigenRight(:,:,iter));
        end
    end
end
