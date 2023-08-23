function[ptCloudA,ptCloudB,maxStepSize,outlierRatio,maxIterations,...
    tolerance,initTform]=parserGPUImpl(movingPoints,fixedmovingPoints,gridStep,varargin)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.internal.prefer_const(varargin{:});
    coder.inline('never');

    validateattributes(gridStep,{'single','double'},{'real','scalar','nonnan','nonsparse','positive'});
    ptCloudA=double(removeInvalidPointsLocal(movingPoints));
    ptCloudB=double(removeInvalidPointsLocal(fixedmovingPoints));

    numPointsA=numel(ptCloudA)/3;
    numPointsB=numel(ptCloudB)/3;
    if numPointsA<3||numPointsB<3
        coder.internal.error('vision:pointcloud:notEnoughPoints');
    end
    t=computeMeanLocation(ptCloudB)-computeMeanLocation(ptCloudA);
    [maxStepSize,outlierRatio,maxIterations,tolerance,initialTransform]=...
    vision.internal.ndt.parseOptionsCodegen(true,t,varargin{:});

    if isa(initialTransform,'affine3d')
        initRigidTform=rigidtform3d(initialTransform.T');
        initTform=double(initRigidTform.A);
    else
        initTform=double(initialTransform.T');
    end

    outlierRatio=double(outlierRatio);
    tolerance=[double(tolerance(1)),double(tolerance(2))*pi/180];
    maxIterations=double(maxIterations);
end


function meanLocation=computeMeanLocation(ptCloudLocations)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    numPoints=numel(ptCloudLocations)/3;
    tmpArrayX=coder.nullcopy(zeros(1,numPoints,'like',ptCloudLocations));
    tmpArrayY=coder.nullcopy(zeros(1,numPoints,'like',ptCloudLocations));
    tmpArrayZ=coder.nullcopy(zeros(1,numPoints,'like',ptCloudLocations));

    coder.gpu.kernel;
    for i=1:numPoints
        tmpArrayX(i)=ptCloudLocations(i);
        tmpArrayY(i)=ptCloudLocations(i+numPoints);
        tmpArrayZ(i)=ptCloudLocations(i+2*numPoints);
    end

    sumX=sum(tmpArrayX);
    sumY=sum(tmpArrayY);
    sumZ=sum(tmpArrayZ);

    meanLocation=[sumX/numPoints,sumY/numPoints,sumZ/numPoints];
end


function validLocations=removeInvalidPointsLocal(ptCloudLocations)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);

    numPoints=numel(ptCloudLocations)/3;
    indices=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(ptCloudLocations);

    outIdx=cumsum(indices);

    outLength=0;
    coder.gpu.kernel;
    for i=1:2
        outLength=outIdx(numPoints);
    end
    validLocations=coder.nullcopy(zeros(outLength,3,'like',ptCloudLocations));
    coder.gpu.kernel;
    for i=1:numPoints
        if indices(i)
            validLocations(outIdx(i))=ptCloudLocations(i);
            validLocations(outIdx(i)+outLength)=ptCloudLocations(i+numPoints);
            validLocations(outIdx(i)+2*outLength)=ptCloudLocations(i+2*numPoints);
        end
    end
end
