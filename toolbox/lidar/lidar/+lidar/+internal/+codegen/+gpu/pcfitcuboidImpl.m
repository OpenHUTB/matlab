function bbox=pcfitcuboidImpl(location,indices,azimuthMin,stepSize,azimuthMax)%#codegen
























    coder.allowpcode("plain");


    if ndims(location)==3

        locationUnOrg=reshape(location,[],3);
    else
        locationUnOrg=location;
    end

    locValid=findValidPoints(locationUnOrg,indices);

    if numel(locValid)==0

        bbox=zeros(1,9);
    else

        azimuth=findAzimuth(azimuthMin,stepSize,azimuthMax);
        loc2D=locValid(:,1:2);
        [c1,c2]=findProjection(loc2D,azimuth);

        [distance1,c1Min,c1Max]=findSmallestDistance(c1);
        [distance2,c2Min,c2Max]=findSmallestDistance(c2);

        scores=varianceCriterion(distance1,distance2);
        [theta,thetaIdx]=findBestTheta(azimuth,scores);

        c1minTheta=c1Min(thetaIdx);
        c1maxTheta=c1Max(thetaIdx);
        c2minTheta=c2Min(thetaIdx);
        c2maxTheta=c2Max(thetaIdx);
        bbox2d=fitRectangle(theta,c1minTheta,c1maxTheta,c2minTheta,c2maxTheta);

        minHeight=gpucoder.reduce(locValid(:,3),@funcMin,'dim',1);
        maxHeight=gpucoder.reduce(locValid(:,3),@funcMax,'dim',1);
        bbox=fitCuboid(bbox2d,minHeight,maxHeight);
    end
end

function validLocation=findValidPoints(location,indices)




    finiteIndexFlag=allFiniteImpl(indices);
    if~finiteIndexFlag
        validLocation=zeros(0,3,'like',location);
        return;
    end


    if numel(indices)>0
        filteredLocation=location(indices,:);
    else
        filteredLocation=location;
    end

    validIdx=...
    vision.internal.codegen.gpu.PointCloudImpl.extractValidPoints(...
    filteredLocation);


    color=[];
    normal=[];
    intensity=[];
    rangeData=[];
    isOrganized=false;
    [validLocation,~,~,~,~]=...
    vision.internal.codegen.gpu.PointCloudImpl.subsetImpl(...
    filteredLocation,color,normal,intensity,rangeData,validIdx,...
    isOrganized,'selected');
end

function azimuth=findAzimuth(azimuthMin,stepSize,azimuthMax)%#codegen


    azimuthCount=floor((azimuthMax-azimuthMin)./stepSize)+1;
    azimuth=coder.nullcopy(zeros(azimuthCount,1));
    coder.gpu.kernel;
    for idx=1:azimuthCount
        azimuth(idx)=azimuthMin+(stepSize*(idx-1));
    end
end

function[c1,c2]=findProjection(location,azimuth)%#codegen


    azimuthCount=cast(numel(azimuth),'like',location);
    locationCount=cast(size(location,1),'like',location);
    c1=coder.nullcopy(zeros(azimuthCount,locationCount,class(location)));
    c2=coder.nullcopy(zeros(azimuthCount,locationCount,class(location)));



    coder.gpu.kernel;
    for locationIdx=1:locationCount
        coder.gpu.kernel;
        for azimuthIdx=1:azimuthCount
            degrees=azimuth(azimuthIdx);

            e1=[cosd(degrees),sind(degrees)]';
            e2=[-sind(degrees),cosd(degrees)]';

            point=location(locationIdx,1:2);
            c1(azimuthIdx,locationIdx)=point*e1;
            c2(azimuthIdx,locationIdx)=point*e2;
        end
    end
end

function[distance,cMin,cMax]=findSmallestDistance(projection)%#codegen



    cMin=gpucoder.reduce(projection,@funcMin,'dim',2);
    cMax=gpucoder.reduce(projection,@funcMax,'dim',2);



    azimuthCount=cast(size(projection,1),'like',projection);
    projectionCount=cast(size(projection,2),'like',projection);
    distance=coder.nullcopy(zeros(size(projection),'like',projection));

    coder.gpu.kernel;
    for projIdx=1:projectionCount
        coder.gpu.kernel;
        for azimuthIdx=1:azimuthCount
            proj=projection(azimuthIdx,projIdx);
            distFromMin=proj-cMin(azimuthIdx);
            distFromMax=cMax(azimuthIdx)-proj;
            distance(azimuthIdx,projIdx)=min(distFromMin,distFromMax);
        end
    end
end

function[theta,idx]=findBestTheta(Azimuth,scores)%#codegen

    [~,idx]=min(scores);
    theta=double(Azimuth(idx));
end

function scores=varianceCriterion(distance1,distance2)%#codegen



    if~coder.gpu.internal.isGpuEnabled
        computeDataType='double';
    else
        computeCapability=gpucoder.getComputeCapability;
        if computeCapability>=6.1
            computeDataType='double';
        else
            computeDataType='single';
        end
    end


    azimuthCount=cast(size(distance1,1),'like',distance1);
    projectionCount=cast(size(distance1,2),'like',distance1);



    edgeFlag=coder.nullcopy(false(size(distance1)));
    edge1Count=cast(zeros(azimuthCount,1),computeDataType);

    coder.gpu.kernel;
    for projIdx=1:projectionCount
        coder.gpu.kernel;
        for azimuthIdx=1:azimuthCount
            edgeFlag(azimuthIdx,projIdx)=distance1(azimuthIdx,projIdx)...
            <=distance2(azimuthIdx,projIdx);


            addOne=cast(edgeFlag(azimuthIdx,projIdx),computeDataType);
            edge1Count(azimuthIdx)=gpucoder.atomicAdd(...
            edge1Count(azimuthIdx),addOne);
        end
    end

    edge2Count=projectionCount-edge1Count;







    edge1Means=zeros(azimuthCount,1,computeDataType);
    edge2Means=zeros(azimuthCount,1,computeDataType);
    coder.gpu.kernel;
    for projIdx=1:projectionCount
        coder.gpu.kernel;
        for azimuthIdx=1:azimuthCount
            if edgeFlag(azimuthIdx,projIdx)
                n=edge1Count(azimuthIdx);
                dist=distance1(azimuthIdx,projIdx);
                meanDelta=dist./n;
                edge1Means(azimuthIdx)=gpucoder.atomicAdd(edge1Means(azimuthIdx),meanDelta);
            else
                n=edge2Count(azimuthIdx);
                dist=distance2(azimuthIdx,projIdx);
                meanDelta=dist./n;
                edge2Means(azimuthIdx)=gpucoder.atomicAdd(edge2Means(azimuthIdx),meanDelta);
            end
        end
    end



    scores=zeros(azimuthCount,1,computeDataType);
    coder.gpu.kernel;
    for projIdx=1:projectionCount
        coder.gpu.kernel;
        for azimuthIdx=1:azimuthCount
            if edgeFlag(azimuthIdx,projIdx)
                n=edge1Count(azimuthIdx);
                dist=distance1(azimuthIdx,projIdx);
                mean=edge1Means(azimuthIdx);
            else
                n=edge2Count(azimuthIdx);
                dist=distance2(azimuthIdx,projIdx);
                mean=edge2Means(azimuthIdx);
            end
            varDelta=((dist-mean).^2)./n;
            scores(azimuthIdx)=gpucoder.atomicAdd(...
            scores(azimuthIdx),varDelta);
        end
    end
end

function bbox2d=fitRectangle(theta,c1min,c1max,c2min,c2max)%#codegen



    coder.gpu.kernel;
    coder.inline('never')

    a=[cosd(theta),sind(theta),c1min];
    b=[-sind(theta),cosd(theta),c2min];
    c=[cosd(theta),sind(theta),c1max];
    d=[-sind(theta),cosd(theta),c2max];


    vertices=coder.nullcopy(zeros(4,2,class(theta)));
    vertices(1,:)=findIntersectionPoint(b,c);
    vertices(2,:)=findIntersectionPoint(a,b);
    vertices(3,:)=findIntersectionPoint(a,d);

    vertices(4,1)=vertices(1,1)+vertices(3,1)-vertices(2,1);
    vertices(4,2)=vertices(1,2)+vertices(3,2)-vertices(2,2);


    [longVertex,length,width]=findLongEdge(vertices);


    if((vertices(2,2)-longVertex(2))~=0)
        yaw=atand((vertices(2,2)-longVertex(2))/(vertices(2,1)-longVertex(1)));
    else
        yaw=cast(0,class(vertices));
    end

    bbox2d=[(vertices(4,:)+vertices(2,:))/2,length,width,yaw];

end

function bbox3d=fitCuboid(bbox2d,minHeight,maxHeight)%#codegen



    coder.gpu.kernel;


    l=bbox2d(3);
    w=bbox2d(4);
    h=double(maxHeight-minHeight);

    centerZ=double((maxHeight+minHeight))./2;
    center=[bbox2d(1),bbox2d(2),centerZ];

    roll=cast(0,class(bbox2d));
    pitch=cast(0,class(bbox2d));
    yaw=bbox2d(5);

    bbox3d=[center,l,w,h,roll,pitch,yaw];
end

function point=findIntersectionPoint(a,b)%#codegen





    coder.gpu.kernel;
    point=coder.nullcopy(zeros(1,2));


    if a(2)==0
        point(1)=a(3)/a(1);
    elseif b(2)==0
        point(1)=b(3)/b(1);
    else
        point(1)=(b(3)/b(2)-a(3)/a(2))/(b(1)/b(2)-a(1)/a(2));
    end


    if a(2)~=0
        point(2)=-a(1)*point(1)/a(2)+a(3)/a(2);
    else
        point(2)=-b(1)*point(1)/b(2)+b(3)/b(2);
    end
end

function[longVertex,length,width]=findLongEdge(vertices)%#codegen



    coder.gpu.kernel;



    distance1=sqrt(sum((vertices(1,:)-vertices(2,:)).^2));
    distance2=sqrt(sum((vertices(3,:)-vertices(2,:)).^2));


    if distance1>distance2
        longVertex=vertices(1,:);
        length=distance1;
        width=distance2;
    else
        longVertex=vertices(3,:);
        length=distance2;
        width=distance1;
    end
end

function minVal=funcMin(a,b)%#codegen
    minVal=min(a,b);
end

function maxVal=funcMax(a,b)%#codegen
    maxVal=max(a,b);
end

function flag=allFiniteImpl(input)


    flag=true;
    coder.gpu.kernel
    for idx=1:numel(input)

        if~isfinite(input(idx))


            flag=isfinite(input(idx));
        end
    end
end
