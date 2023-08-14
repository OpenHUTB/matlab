function b=getPolygonBoundariesForLayer(obj,layer,tol)

    if isa(obj,'pcbStack')
        if~isempty(layer.FeaturePolygons)
            featurePolygons=cellfun(@(x)x.InternalPolyShape.Vertices,layer.FeaturePolygons,'UniformOutput',false);
            b=[layer.FillPolygons,layer.HolePolygons,featurePolygons];
        else
            b=[layer.FillPolygons,layer.HolePolygons];
        end
        [~,ia]=cellfun(@(x)uniquetol(x,tol,'ByRows',true,'DataScale',1),b,'UniformOutput',false);
        for i=1:numel(b)
            temp=b{i};
            b{i}=temp(sort(ia{i}),:);
        end
    else

        b=[layer.FillPolygons,layer.HolePolygons];



    end