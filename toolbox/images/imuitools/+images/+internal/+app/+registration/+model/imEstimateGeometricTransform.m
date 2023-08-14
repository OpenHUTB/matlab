function[tform,inlierIndex,status]...
    =imEstimateGeometricTransform(matchedPoints1,matchedPoints2,...
    transformType,varargin)














































































































































    reportError=(nargout~=3);
    is2D=true;

    [tform,inlierIndex,status]=...
    algEstimateGeometricTransform(...
    matchedPoints1,matchedPoints2,transformType,reportError,...
    'estimateGeometricTransform2D',is2D,varargin{:});

end

function[tform,inlierIdx,status]=...
    algEstimateGeometricTransform(matchedPoints1,matchedPoints2,...
    transformType,reportError,funcName,is2D,varargin)
















    statusCode=struct(...
    'NoError',int32(0),...
    'NotEnoughPts',int32(1),...
    'NotEnoughInliers',int32(2));


    [points1,points2,ransacParams,sampleSize,tformType,status,classToUse]=...
    parseEstimateGeometricTransform(statusCode,...
    matchedPoints1,matchedPoints2,transformType,funcName,is2D,...
    varargin{:});


    if is2D
        failedMatrix=eye(3,classToUse);
    else
        failedMatrix=eye(4,classToUse);
    end


    if status==statusCode.NoError
        ransacFuncs=getRansacFunctions(tformType,is2D);
        points=cast(cat(3,points1,points2),classToUse);

        [isFound,tmatrix,inlierIdx]=images.internal.app.registration.model.msac(...
        points,ransacParams,ransacFuncs);

        if~isFound
            error(message('images:imageRegistration:poorQualityFeatures'));
        end



        if isequal(det(tmatrix),0)||any(~isfinite(tmatrix(:)))
            error(message('images:imageRegistration:poorQualityFeatures'));
        end
    else

        inlierIdx=false(size(matchedPoints1,1));
        tmatrix=failedMatrix;
    end

    if(status~=statusCode.NoError)
        tmatrix=failedMatrix;
    end


    if reportError
        checkRuntimeStatus(statusCode,status,sampleSize);
    end

    if is2D
        if isequal(tformType,'r')
            tform=rigid2d(tmatrix(1:3,1:3));
        elseif isequal(tformType,'p')
            tform=projective2d(tmatrix(1:3,1:3));
        else



            tform=affine2d(tmatrix(:,1:2));
        end
    else
        if(isequal(tformType,'r'))
            tform=rigid3d(tmatrix);
        else
            tform=affine3d(tmatrix);
        end
    end
end




function checkRuntimeStatus(~,~,~)



end


function ransacFuncs=getRansacFunctions(tformType,is2D)
    ransacFuncs.checkFunc=@checkTForm;

    if is2D
        ransacFuncs.evalFunc=@evaluateTform2d;
        switch(tformType)
        case 'r'
            ransacFuncs.fitFunc=@computeRigid2d;
        case 's'
            ransacFuncs.fitFunc=@computeSimilarity2d;
        case 'a'
            ransacFuncs.fitFunc=@computeAffine2d;
        otherwise
            ransacFuncs.fitFunc=@computeProjective2d;
        end
    else
        ransacFuncs.evalFunc=@evaluateTform3d;
        switch(tformType)
        case 'r'
            ransacFuncs.fitFunc=@computeRigid3d;
        otherwise
            ransacFuncs.fitFunc=@computeSimilarity3d;
        end
    end
end




function T=computeRigid2d(points)

    points1=points(:,:,1);
    points2=points(:,:,2);

    [R,t]=computeRigidTransform(points1,points2);
    T=coder.nullcopy(eye(3,'like',points));
    T(:,1:2)=[R';t'];

end

function[R,t]=computeRigidTransform(p,q)


    centroid1=mean(p);
    centroid2=mean(q);

    normPoints1=bsxfun(@minus,p,centroid1);
    normPoints2=bsxfun(@minus,q,centroid2);


    C=normPoints1'*normPoints2;

    [U,~,V]=svd(C);


    R=V*diag([ones(1,size(p,2)-1),sign(det(U*V'))])*U';


    t=centroid2'-R*centroid1';

end


function T=computeSimilarity2d(points)
    classToUse=class(points);

    [points1,points2,normMatrix1,normMatrix2]=...
    normalizePoints(points,classToUse);

    numPts=size(points1,1);
    constraints=zeros(2*numPts,5,'like',points);
    constraints(1:2:2*numPts,:)=[-points1(:,2),points1(:,1),...
    zeros(numPts,1),-ones(numPts,1),points2(:,2)];
    constraints(2:2:2*numPts,:)=[points1,ones(numPts,1),...
    zeros(numPts,1),-points2(:,1)];

    [~,~,V]=svd(constraints,0);
    h=V(:,end);
    T=coder.nullcopy(eye(3,'like',points));
    T(:,1:2)=[h(1:3),[-h(2);h(1);h(4)]]/h(5);
    T(:,3)=[0;0;1];

    T=denormalizeTform(T,normMatrix1,normMatrix2);

end


function T=computeAffine2d(points)
    classToUse=class(points);

    [points1,points2,normMatrix1,normMatrix2]=...
    normalizePoints(points,classToUse);

    numPts=size(points1,1);
    constraints=zeros(2*numPts,7,'like',points);
    constraints(1:2:2*numPts,:)=[zeros(numPts,3),-points1,...
    -ones(numPts,1),points2(:,2)];
    constraints(2:2:2*numPts,:)=[points1,ones(numPts,1),...
    zeros(numPts,3),-points2(:,1)];

    [~,~,V]=svd(constraints,0);
    h=V(:,end);
    T=coder.nullcopy(eye(3,'like',points));
    T(:,1:2)=reshape(h(1:6),[3,2])/h(7);
    T(:,3)=[0;0;1];

    T=denormalizeTform(T,normMatrix1,normMatrix2);

end


function T=computeProjective2d(points)
    classToUse=class(points);

    [points1,points2,normMatrix1,normMatrix2]=...
    normalizePoints(points,classToUse);

    numPts=size(points1,1);
    p1x=points1(:,1);
    p1y=points1(:,2);
    p2x=points2(:,1);
    p2y=points2(:,2);
    constraints=zeros(2*numPts,9,'like',points);
    constraints(1:2:2*numPts,:)=[zeros(numPts,3),-points1,...
    -ones(numPts,1),p1x.*p2y,p1y.*p2y,p2y];
    constraints(2:2:2*numPts,:)=[points1,ones(numPts,1),...
    zeros(numPts,3),-p1x.*p2x,-p1y.*p2x,-p2x];

    [~,~,V]=svd(constraints,0);
    h=V(:,end);
    T=reshape(h,[3,3])/h(9);

    T=denormalizeTform(T,normMatrix1,normMatrix2);

end


function T=computeRigid3d(points)

    points1=points(:,:,1);
    points2=points(:,:,2);


    [R,t]=computeRigidTransform(points1,points2);
    T=coder.nullcopy(eye(4,'like',points));
    T(:,1:3)=[R';t'];
    T(:,4)=[0;0;0;1];

end


function T=computeSimilarity3d(points)
    classToUse=class(points);

    [points1,points2,normMatrix1,normMatrix2]=...
    normalizePoints(points,classToUse);


    T=computeSimilarityTransform3D(points1,points2)';
    T=denormalizeTform(T,normMatrix1,normMatrix2);

end

function T=computeSimilarityTransform3D(points1,points2)
















%#codegen


    centroid1=mean(points1);
    centroid2=mean(points2);

    pointsCentroid1=bsxfun(@minus,points1,centroid1);
    pointsCentroid2=bsxfun(@minus,points2,centroid2);


    M=pointsCentroid2'*pointsCentroid1;


    N=zeros(4,'like',points1);
    N(1,1)=M(1,1)+M(2,2)+M(3,3);
    N(1,2)=M(2,3)-M(3,2);
    N(1,3)=M(3,1)-M(1,3);
    N(1,4)=M(1,2)-M(2,1);
    N(2,2)=M(1,1)-M(2,2)-M(3,3);
    N(2,3)=M(1,2)+M(2,1);
    N(2,4)=M(3,1)+M(1,3);
    N(3,3)=-M(1,1)+M(2,2)-M(3,3);
    N(3,4)=M(2,3)+M(3,2);
    N(4,4)=-M(1,1)-M(2,2)+M(3,3);



    N=N+triu(N,1)';


    [V,D]=eig(N,'vector');



    D=real(D);
    [~,selectedEigenvalueIdx]=max(D);
    quat=real(V(:,selectedEigenvalueIdx).');


    if quat(1)<0
        quat=-quat;
    end

    R=quaternionToRotation(quat');


    scale=norm(pointsCentroid2)/norm(pointsCentroid1');



    R=R'*(scale.*eye(3));


    t=centroid2'-R*centroid1';

    T=[R,t;0,0,0,1];

end

function R=quaternionToRotation(quats)
















%#codegen

    numQuats=size(quats,2);

    q0=reshape(quats(1,:),1,1,numQuats);
    qx=reshape(quats(2,:),1,1,numQuats);
    qy=reshape(quats(3,:),1,1,numQuats);
    qz=reshape(quats(4,:),1,1,numQuats);

    R=[q0.^2+qx.^2-qy.^2-qz.^2,2*qx.*qy-2*q0.*qz,2*qx.*qz+2*q0.*qy;...
    2*qx.*qy+2*q0.*qz,q0.^2-qx.^2+qy.^2-qz.^2,2*qy.*qz-2*q0.*qx;...
    2*qx.*qz-2*q0.*qy,2*qy.*qz+2*q0.*qx,q0.^2-qx.^2-qy.^2+qz.^2];

end


function[samples1,samples2,normMatrix1,normMatrix2]=...
    normalizePoints(points,classToUse)
    points1=cast(points(:,:,1),classToUse);
    points2=cast(points(:,:,2),classToUse);

    if(size(points1,2)==2)
        [samples1,normMatrix1]=...
        normalizePointsAlg(points1',2,classToUse);
        [samples2,normMatrix2]=...
        normalizePointsAlg(points2',2,classToUse);
    else
        [samples1,normMatrix1]=...
        normalizePointsAlg(points1',3,classToUse);
        [samples2,normMatrix2]=...
        normalizePointsAlg(points2',3,classToUse);
    end

    samples1=samples1';
    samples2=samples2';
end

function[normPoints,T,Tinv]=normalizePointsAlg(p,numDims,outputClass)


    points=p(1:numDims,:);


    cent=cast(mean(points,2),outputClass);


    translatedPoints=bsxfun(@minus,points,cent);


    meanDistanceFromCenter=cast(mean(sqrt(sum(translatedPoints.^2))),...
    outputClass);
    if meanDistanceFromCenter>0
        scale=cast(sqrt(numDims),outputClass)/meanDistanceFromCenter;
    else
        scale=cast(1,outputClass);
    end







    T=diag(ones(1,numDims+1)*scale);
    T(1:end-1,end)=-scale*cent;
    T(end)=1;

    if size(p,1)>numDims
        normPoints=T*p;
    else
        normPoints=translatedPoints*scale;
    end


    if nargout>2
        Tinv=diag(ones(1,numDims+1)/scale);
        Tinv(1:end-1,end)=cent;
        Tinv(end)=1;
    end

end


function tform=denormalizeTform(tform,normMatrix1,normMatrix2)
    tform=normMatrix1'*(tform/normMatrix2');
    tform=tform./tform(end);
end


function dis=evaluateTform2d(tform,points)
    points1=points(:,:,1);
    points2=points(:,:,2);

    numPoints=size(points1,1);
    pt1h=[points1,ones(numPoints,1,'like',points)];
    pt1h=pt1h*tform;
    w=pt1h(:,3);
    pt=pt1h(:,1:2)./[w,w];
    delta=pt-points2;
    dis=hypot(delta(:,1),delta(:,2));
    dis(abs(pt1h(:,3))<eps(class(points)))=inf;
end


function dis=evaluateTform3d(tform,points)
    points1=points(:,:,1);
    points2=points(:,:,2);

    numPoints=size(points1,1);
    pt1h=[points1,ones(numPoints,1,'like',points)];

    tpoints1=pt1h*tform;

    dis=sqrt((tpoints1(:,1)-points2(:,1)).^2+...
    (tpoints1(:,2)-points2(:,2)).^2+...
    (tpoints1(:,3)-points2(:,3)).^2);
end


function tf=checkTForm(tform)
    tf=all(isfinite(tform(:)));
end

function[points1,points2,ransacParams,sampleSize,tformType,...
    status,classToUse]=parseEstimateGeometricTransform(statusCode,...
    matchedPoints1,matchedPoints2,transformType,fileName,is2D,...
    varargin)





    parser=inputParser;
    parser.FunctionName=fileName;


    parser.addParameter('MaxNumTrials',1000);
    parser.addParameter('Confidence',99);

    if is2D
        parser.addParameter('MaxDistance',1.5);
    else
        parser.addParameter('MaxDistance',1);
    end


    parser.parse(varargin{:});
    r=parser.Results;

    maxNumTrials=r.MaxNumTrials;
    confidence=r.Confidence;
    maxDistance=r.MaxDistance;

    if is2D
        [points1,points2]=checkAndConvertMatchedPoints(...
        matchedPoints1,matchedPoints2,...
        fileName,'matchedPoints1','matchedPoints2');
        [sampleSize,tformType]=checkTransformType2d(char(transformType),fileName);
    else
        check3DMatchedPoints(matchedPoints1,matchedPoints2,fileName)
        points1=matchedPoints1;
        points2=matchedPoints2;
        [sampleSize,tformType]=checkTransformType3d(char(transformType),fileName);
    end

    status=checkPointsSize(statusCode,sampleSize,points1);


    checkMaxNumTrials(maxNumTrials,fileName);
    checkConfidence(confidence,fileName);
    checkMaxDistance(maxDistance,fileName);

    classToUse=getClassToUse(points1,points2);

    ransacParams.maxNumTrials=int32(maxNumTrials);
    ransacParams.confidence=cast(confidence,classToUse);
    ransacParams.maxDistance=cast(maxDistance,classToUse);
    ransacParams.recomputeModelFromInliers=true;



    sampleSize=cast(sampleSize,classToUse);
    ransacParams.sampleSize=sampleSize;

end

function[points1,points2]=checkAndConvertMatchedPoints(...
    matchedPoints1,matchedPoints2,fileName,varName1,varName2)


    assert(...
    isequal(class(matchedPoints1),class(matchedPoints2)),...
    'Mismatched Point Classes.');

    points1=checkAndConvertPoints(...
    matchedPoints1,fileName,varName1);
    points2=checkAndConvertPoints(...
    matchedPoints2,fileName,varName2);

    assert(isequal(size(points1),size(points2)),...
    'Number of points do not match');
end

function pointsOut=checkAndConvertPoints(pointsIn,fileName,varName)


    checkPoints(pointsIn,fileName,varName);


    if isnumeric(pointsIn)
        pointsOut=pointsIn;
    else
        pointsOut=pointsIn.Location;
    end

end

function checkPoints(pointsIn,fileName,varName)


    if isnumeric(pointsIn)
        checkPtsAttributes(pointsIn,fileName,varName);
    else
        checkPtsAttributes(pointsIn.Location,fileName,varName);
    end

end


function checkPtsAttributes(value,fileName,varName)
    validateattributes(value,{'numeric'},...
    {'2d','nonsparse','real','size',[NaN,2]},fileName,varName);

end

function check3DMatchedPoints(points1,points2,fileName)
    varName1='matchedPoints1';
    varName2='matchedPoints2';
    assert(...
    isequal(class(points1),class(points2)),...
    'Mismatched Point Classes.');

    check3DPoints(points1,varName1,fileName);
    check3DPoints(points2,varName2,fileName);

    assert(isequal(size(points1),size(points2)),...
    'Number of points do not match');
end

function check3DPoints(points,varName,fileName)

    validateattributes(points,{'numeric'},...
    {'2d','nonsparse','real','ncols',3},fileName,varName);
end


function[sampleSize,tformType]=checkTransformType2d(value,fileName)
    list={'rigid','similarity','affine','projective'};
    validatestring(value,list,fileName,'TransformType');

    tformType=lower(value(1));

    switch(tformType)
    case 'r'
        sampleSize=2;
    case 's'
        sampleSize=2;
    case 'a'
        sampleSize=3;
    otherwise
        sampleSize=4;
    end
end

function[sampleSize,tformType]=checkTransformType3d(value,fileName)
    list={'rigid','similarity'};
    validatestring(value,list,fileName,'TransformType');

    tformType=lower(value(1));

    sampleSize=3;
end

function status=checkPointsSize(statusCode,sampleSize,points1)
    if size(points1,1)<sampleSize
        status=statusCode.NotEnoughPts;
    else
        status=statusCode.NoError;
    end
end

function r=checkMaxNumTrials(value,fileName)
    validateattributes(value,{'numeric'},...
    {'scalar','nonsparse','real','integer','positive','finite'},...
    fileName,'MaxNumTrials');
    r=1;
end

function r=checkConfidence(value,fileName)
    validateattributes(value,{'numeric'},...
    {'scalar','nonsparse','real','positive','finite','<',100},...
    fileName,'Confidence');
    r=1;
end

function r=checkMaxDistance(value,fileName)
    validateattributes(value,{'numeric'},...
    {'scalar','nonsparse','real','positive','finite'},...
    fileName,'MaxDistance');
    r=1;
end

function c=getClassToUse(points1,points2)
    if isa(points1,'double')||isa(points2,'double')
        c='double';
    else
        c='single';
    end
end
