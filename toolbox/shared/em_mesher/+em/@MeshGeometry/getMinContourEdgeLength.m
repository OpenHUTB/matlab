function minContourEdgeLength=getMinContourEdgeLength(obj)

    if isfield(obj.MesherStruct.Mesh,'MinContourEdgeLength')
        minContourEdgeLength=obj.MesherStruct.Mesh.MinContourEdgeLength;
    else
        minContourEdgeLength=[];
    end


end