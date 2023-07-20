function copyMeshObjects(obj,m)


    if~isempty(m.wiresSeg)
        obj.MesherStruct.Mesh.wiresSeg=clone(m.wiresSeg);
        obj.MesherStruct.Mesh.volDataSeg=clone(m.volDataSeg);
        obj.MesherStruct.Mesh.volDataMPt=clone(m.volDataMPt);
    end
    if~isempty(m.wiresBoth)
        obj.MesherStruct.Mesh.wiresBoth=clone(m.wiresBoth);
        obj.MesherStruct.Mesh.volDataBoth=clone(m.volDataBoth);
    end

end