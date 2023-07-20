function saveSubstrateGeometry(obj,vertices,polygons,boundary,...
    boundaryvertices)

    obj.MesherStruct.Geometry.SubstrateVertices=vertices;
    obj.MesherStruct.Geometry.SubstratePolygons=polygons;
    if nargin>3
        obj.MesherStruct.Geometry.SubstrateBoundary=boundary;
        obj.MesherStruct.Geometry.SubstrateBoundaryVertices=boundaryvertices;
    else
        obj.MesherStruct.Geometry.SubstrateBoundary=[];
        obj.MesherStruct.Geometry.SubstrateBoundaryVertices=[];
    end

end