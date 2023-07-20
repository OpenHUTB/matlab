function p=createSpherePoints(obj,N)

    totNodes=zeros(3,0);
    for wireInd=1:length(obj.WiresInt)
        totNodes=[totNodes,obj.WiresInt{wireInd}.wireNodesOrig];%#ok<AGROW>
    end
    R=em.internal.findRadiusOfBoundingSphere(totNodes);

    [x,y,z]=sphere(N);
    p=R*[x(:)';y(:)';z(:)'];

end