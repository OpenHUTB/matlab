function g=convertStackGeomToCatalogGeom(obj,geom)






    Ngeom=numel(geom);
    nlayers=getNumMetalLayers(obj);


    SubstrateVertices=[];
    SubstratePolygons=[];
    SubstrateBoundary=[];
    if isDielectricSubstrate(obj)
        SubstrateVertices=geom{1}.SubstrateVertices;
        SubstratePolygons=geom{1}.SubstratePolygons;
        if isfield(geom{1},'SubstrateBoundary')
            SubstrateBoundary=geom{1}.SubstrateBoundary;
            SubstrateBoundaryVertices=geom{1}.SubstrateBoundaryVertices;
        end
    end


    geom(1:nlayers)=fliplr(geom(1:nlayers));
    isBoundaryEdges=cellfun(@(x)isfield(x,'BoundaryEdges'),geom);

    BorderVertices=cellfun(@(x)x.BorderVertices,geom,'UniformOutput',false);
    plen=cellfun(@(x)size(x,1),BorderVertices);
    BorderVertices=cell2mat(BorderVertices');

    cumplensum=cumsum(plen);

    for i=2:Ngeom
        geom{i}.polygons{1}=geom{i}.polygons{1}+cumplensum(i-1);
    end

    polygons=cellfun(@(x)x.polygons{1},geom,'UniformOutput',false);

    BoundaryEdges=[];
    for i=1:Ngeom
        if i==1
            offset=0;
        else
            offset=cumplensum(i-1);
        end
        if isBoundaryEdges(i)
            geom{i}.BoundaryEdges{1}=geom{i}.BoundaryEdges{1}+offset;
        else
            geom{i}.BoundaryEdges{1}=geom{i}.polygons{1};
        end
    end


    if any(isBoundaryEdges)
        BoundaryEdges=cellfun(@(x)x.BoundaryEdges{1},geom,'UniformOutput',false);
    end

    doNotPlot=zeros(1,numel(geom));
    MaxFeatureSize=0;
    for m=1:numel(geom)
        MaxFeatureSize=max(MaxFeatureSize,max(geom{m}.MaxFeatureSize));
    end


    temp.BorderVertices=BorderVertices;
    temp.polygons={cell2mat(polygons.')};
    temp.doNotPlot=doNotPlot;
    temp.MaxFeatureSize=MaxFeatureSize;
    if~isempty(BoundaryEdges)
        temp.BoundaryEdges=BoundaryEdges;
    end
    temp.SubstrateVertices=SubstrateVertices;
    temp.SubstratePolygons=SubstratePolygons;
    if~isempty(SubstrateBoundary)
        temp.SubstrateBoundary=SubstrateBoundary;
        temp.SubstrateBoundaryVertices=SubstrateBoundaryVertices;
    end
    g=temp;
end