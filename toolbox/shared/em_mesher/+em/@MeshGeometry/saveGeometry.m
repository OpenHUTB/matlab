function saveGeometry(obj,vertices,polygons,plotOption,...
    maxFeatureSize,varargin)




    obj.MesherStruct.Geometry.BorderVertices=vertices;
    obj.MesherStruct.Geometry.polygons=polygons;
    obj.MesherStruct.Geometry.doNotPlot=plotOption;
    obj.MesherStruct.Geometry.MaxFeatureSize=maxFeatureSize;
    if nargin==6
        obj.MesherStruct.Geometry.BoundaryEdges=varargin{:};
    end
    if nargin==7
        obj.MesherStruct.Geometry.BoundaryEdges=varargin{1};
        obj.MesherStruct.Geometry.DomainNumbers=varargin{2};
    end
    saveLoad(obj);
    saveConductor(obj);
end
