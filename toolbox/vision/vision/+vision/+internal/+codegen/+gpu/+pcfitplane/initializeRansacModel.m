function[statusCode,status,locations,indices]=...
    initializeRansacModel(ptCloud,sampleIndices,sampleSize)






































%#codegen
    coder.gpu.kernelfun;
    coder.inline('never');
    coder.allowpcode('plain');


    statusCode=struct(...
    'NoError',int32(0),...
    'NotEnoughPts',int32(1),...
    'NotEnoughInliers',int32(2));

    if~isempty(sampleIndices)

        row=size(ptCloud.Location,1);
        col=size(ptCloud.Location,1);
        locationTemp=ptCloud.Location;
        locationInp=coder.nullcopy(...
        zeros(numel(sampleIndices),3,'like',ptCloud.Location));
        locationInp(:,1)=locationTemp(sampleIndices);
        locationInp(:,2)=locationTemp(row*col+sampleIndices);
        locationInp(:,3)=locationTemp(2*row*col+sampleIndices);
    else

        locationInp=ptCloud.Location;
    end



    isOrganized=~ismatrix(locationInp);



    indices=vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(locationInp);
    [locations,~,~,~,~]=...
    vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(locationInp,[],...
    [],[],[],indices,isOrganized,'selected');



    if(numel(locations)/3)<sampleSize
        status=statusCode.NotEnoughPts;
    else
        status=statusCode.NoError;
    end

end

