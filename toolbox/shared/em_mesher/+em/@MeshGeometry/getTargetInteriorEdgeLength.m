function propVal=getTargetInteriorEdgeLength(obj)
    if isfield(obj.MesherStruct.Mesh,'TargetInteriorEdgeLength')
        propVal=obj.MesherStruct.Mesh.TargetInteriorEdgeLength;
    else
        propVal=[];
    end
end