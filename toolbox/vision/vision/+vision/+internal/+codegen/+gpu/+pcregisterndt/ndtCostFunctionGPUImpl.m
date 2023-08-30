function[scoreSumDouble,gradientSumDouble,hessianSumDouble]=...
    ndtCostFunctionGPUImpl(inpPoseArray,ndtArgsStruct)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.inline('never');

    qryPoints=ndtArgsStruct.ps;
    fixedVoxelMeans=ndtArgsStruct.mvals;
    fixedVoxelICov=ndtArgsStruct.iCov;
    d1=ndtArgsStruct.d1;
    d2=ndtArgsStruct.d2;
    voxelSize=ndtArgsStruct.radius;

    numQryPoints=numel(qryPoints)/3;
    numRefPoints=numel(fixedVoxelMeans)/3;
    [R,Ja,Ha]=vision.internal.codegen.gpu.pcregisterndt.computeJaHa(inpPoseArray);
    qryPointsTransformedMat=coder.nullcopy(qryPoints);
    coder.gpu.kernel;
    for ptIter=1:numQryPoints
        tmpArr=R*[qryPoints(ptIter,1);qryPoints(ptIter,2);qryPoints(ptIter,3)];
        qryPointsTransformedMat(ptIter,:)=tmpArr+...
        [inpPoseArray(1);inpPoseArray(2);inpPoseArray(3)];
    end

    [nghbrsIdxMat,numNgbrsMat]=...
    vision.internal.codegen.gpu.pcregisterndt.multiQueryRadiusSearch(...
    fixedVoxelMeans,qryPointsTransformedMat,voxelSize);

    [scoreSum,gradientSum,hessianSum]=...
    vision.internal.codegen.gpu.pcregisterndt.computeSGH(qryPoints,qryPointsTransformedMat,...
    Ja,Ha,fixedVoxelMeans,fixedVoxelICov,nghbrsIdxMat,numNgbrsMat,numRefPoints,d1,d2);

    scoreSumDouble=(scoreSum);
    gradientSumDouble=(gradientSum);
    hessianSumDouble=(hessianSum);
end