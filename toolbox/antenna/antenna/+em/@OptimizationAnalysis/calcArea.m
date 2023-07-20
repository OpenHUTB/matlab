function rtn=calcArea(obj)




    createGeometry(obj);
    Geometry=getGeometry(obj);
    if iscell(Geometry)
        Vertices=cell2mat(cellfun(@(x)x.BorderVertices,Geometry,'UniformOutput',false)');
    else
        Vertices=Geometry.BorderVertices;
    end
    xMax=max(Vertices(:,1));
    xMin=min(Vertices(:,1));
    xSpan=xMax-xMin;
    yMax=max(Vertices(:,2));
    yMin=min(Vertices(:,2));
    ySpan=yMax-yMin;
    zMax=max(Vertices(:,3));
    zMin=min(Vertices(:,3));
    zSpan=zMax-zMin;
    xyarea=xSpan*ySpan;
    yzarea=ySpan*zSpan;
    zxarea=zSpan*xSpan;
    rtn=max(xyarea,max(yzarea,zxarea));
end

