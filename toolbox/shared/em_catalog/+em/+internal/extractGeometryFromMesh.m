function[f,v,boundarypoints,G]=extractGeometryFromMesh(p,t)


    if isequal(size(p,1),2)||isequal(size(p,1),3)
        p=p';
    end

    if size(t,1)>=3
        t=t';
    end
    if isequal(size(t,1),4)
        t(:,4)=[];
    end

    [boundarypoints,polygonHoleMap]=em.internal.findBoundary(p,t);


    for m=1:numel(boundarypoints)
        boundarypoints{m}=[boundarypoints{m},boundarypoints{m}(1)];
    end


    numPolygons=size(polygonHoleMap,1);
    numHoles=max(sum(polygonHoleMap,2));
    [polyidx,holeidx]=find(polygonHoleMap==1);
    polys=1:numPolygons;
    if~isequal(numHoles,0)
        polysWithHoles=polys(ismember(polys,polyidx));
        polysWithoutHoles=polys(~ismember(polys,polyidx));
        Holes=polysWithoutHoles(ismember(polysWithoutHoles,holeidx));
        polysWithoutHoles=polysWithoutHoles(~ismember(polysWithoutHoles,Holes));
        polyBuckets=[polysWithoutHoles,polysWithHoles];
    else
        polyBuckets=polys;
    end


    Ppoly=[];
    for m=1:numel(polyBuckets)
        polyIds=cell2mat(boundarypoints(polyBuckets(m)));
        PpolyBuckets=p(polyIds,:);
        Ppoly1=[PpolyBuckets;NaN(1,size(PpolyBuckets,2))];
        Ppoly=[Ppoly;Ppoly1];
    end


    Phole=[];
    holeBuckets=polys(~ismember(polys,polyBuckets));
    for m=1:numel(holeBuckets)
        holeIds=cell2mat(boundarypoints(holeBuckets(m)));
        PholeBuckets=p(holeIds,:);
        Phole1=[PholeBuckets;NaN(1,size(PholeBuckets,2))];
        Phole=[Phole;Phole1];
    end

    [f,v]=em.internal.getFaceVertexFromBoundary(Ppoly,Phole,numHoles);
    G.PolyFilledVertices=Ppoly;
    G.PolyHoleVertices=Phole;
    G.NumHoles=numHoles;
end
