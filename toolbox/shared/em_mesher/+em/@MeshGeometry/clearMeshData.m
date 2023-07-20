function clearMeshData(obj)

    obj.MesherStruct.Mesh.p=[];
    obj.MesherStruct.Mesh.t=[];
    obj.MesherStruct.Mesh.T=[];
    obj.MesherStruct.Mesh.Eps_r=[];
    obj.MesherStruct.Mesh.tan_delta=[];
    clearPartMesh(obj);
    obj.MesherStruct.Mesh.MaxEdgeLength=[];
    obj.MesherStruct.Mesh.MeshGrowthRate=[];
    obj.MesherStruct.Mesh.numEdges=[];
    obj.MesherStruct.MeshingChoice='auto';


end