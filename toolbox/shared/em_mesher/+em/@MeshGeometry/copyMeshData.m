function objOut=copyMeshData(obj,otherObj)

    if nargin==1
        objOut.MesherStruct.Mesh=obj.MesherStruct.Mesh;
        objOut.MesherStruct.MeshingChoice=obj.MesherStruct.MeshingChoice;
    else
        obj.MesherStruct.Mesh=otherObj.MesherStruct.Mesh;
        obj.MesherStruct.MeshingChoice=otherObj.MesherStruct.MeshingChoice;
        objOut=obj;
    end

end