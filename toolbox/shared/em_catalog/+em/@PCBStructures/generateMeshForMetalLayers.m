function[ps,ts]=generateMeshForMetalLayers(obj,tempMetalLayers,vias,viapolys,layer_heights)


    maxEdgeLength=getMeshEdgeLength(obj);
    minContourEdgeLength=getMinContourEdgeLength(obj);
    growthRate=getMeshGrowthRate(obj);


    cornersSub=obj.BoardShape.ShapeVertices;




    allBoundaries=[{cornersSub},tempMetalLayers.Polygons];


    [~,domainCodes,domains]=em.MeshGeometry.constructDomainFromBoundary(allBoundaries);
    gd=em.MeshGeometry.buildgeometrymatrix(domains,domainCodes);


    PCell=makeContourArray(obj,gd,tempMetalLayers,viapolys,'rawContour');


    feeds=obj.FeedLocations(:,1:2);
    if~isempty(obj.ViaLocations)
        vias=obj.ViaLocations(:,1:2);
        f=[feeds;vias];
    end


    if minContourEdgeLength>maxEdgeLength
        minContourEdgeLength=0.9*maxEdgeLength;
        setMeshMinContourEdgeLength(obj,minContourEdgeLength);
    end
    smoothing_iter=10;
    refinecontours=true;
    [ps,ts,~]=em.internal.meshprinting.multiLayerMetalImprint(PCell,gd,feeds,...
    maxEdgeLength,...
    minContourEdgeLength,...
    growthRate,...
    smoothing_iter,...
    'Unstructured',...
    refinecontours);

    ps=ps';
    ts=ts';
    ts(4,:)=0;

end





