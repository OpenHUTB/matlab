function cleanArrayPartMesh(obj)
    obj.MesherStruct.Mesh.ArrayParts.p=[];
    obj.MesherStruct.Mesh.ArrayParts.t=[];
    obj.MesherStruct.Mesh=rmfield(obj.MesherStruct.Mesh,'ArrayParts');
end