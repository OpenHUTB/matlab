function[pLayer,tLayer,pOuter]=makeLayerPoints(pground,pradiator,tradiator)%#ok<INUSD>
















    [boundarypoints,polygonHoleMap]=em.internal.findBoundary(pradiator',tradiator(1:3,:)');
    numPolygons=size(polygonHoleMap,1);
    numHoles=sum(sum(polygonHoleMap));
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





    polyIds=cell2mat(boundarypoints(polyBuckets));
    Ppoly=pradiator(:,polyIds);

    [inp,onp]=inpolygon(pground(1,:),pground(2,:),Ppoly(1,:),Ppoly(2,:));

    pOuter=[pground(1,~inp&~onp);pground(2,~inp&~onp)];

    if~isequal(numHoles,0)


        holeBuckets=polys(~ismember(polys,polyBuckets));
        holeIds=cell2mat(boundarypoints(holeBuckets));
        Phole=pradiator(:,holeIds);

        [inh,onh]=inpolygon(pground(1,:),pground(2,:),Phole(1,:),Phole(2,:));
        pInner=[pground(1,inh&~onh);pground(2,inh&~onh)];
    else
        pInner=[];
    end


    pTotal=[pInner,pOuter];

































    pnew=[pradiator(1:2,:),pTotal];
    pnew=em.internal.antuniquetol(pnew,1e-12);






    DT=delaunayTriangulation(pnew');
    pLayer=DT.Points';
    tLayer=DT.ConnectivityList';
