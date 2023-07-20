function[groundPtsIdx,rangeData]=segmentGroundFromLidarDataImpl(...
    locationData,rangeDataInp,seedAngle,deltaAngle,repairDepthThresh)

%#codegen



    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');
    coder.inline('never');

    if isempty(rangeDataInp)
        rangeData=vision.internal.codegen.gpu.convertFromCartesianToSphericalCoordinateImpl(locationData);
    else
        rangeData=rangeDataInp;
    end

    dataType=class(rangeData);



    [repairRange,repairAngle]=vision.internal.codegen.gpu.segmentGroundPreProcessing(rangeData,size(rangeData,1),...
    size(rangeData,2),repairDepthThresh);


    groundPtsIdx=vision.internal.codegen.gpu.floodFill(repairAngle,repairRange,...
    cast(deltaAngle,dataType),cast(seedAngle,dataType));
end

