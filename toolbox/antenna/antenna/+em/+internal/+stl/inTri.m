function rtn=inTri(P,t,insidept)



    mp=max(P);mnp=min(P);
    dist=sqrt(sum((mp-mnp).^2,2));
    cpt=[insidept+[0,0,dist];insidept+[0,0,-dist]];

    tr1=triangulation(t,P);
    rtobj=matlabshared.internal.StaticSceneRayTracer(tr1);
    [directionf,distancef]=matlabshared.internal.segmentToRay(cpt(1,:),cpt(2,:));
    [pts,~,~]=allIntersections(rtobj,cpt(1,:),directionf,distancef);
    if isempty(pts{1})
        rtn=false;
    else
        rtn=true;
    end
end