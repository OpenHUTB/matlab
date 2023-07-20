function m=getPrintedMesh(obj)

    m.Points=obj.MesherStruct.Mesh.p;
    m.Triangles=obj.MesherStruct.Mesh.t;
    m.Tetrahedra=obj.MesherStruct.Mesh.T;
    m.EpsilonR=obj.MesherStruct.Mesh.Eps_r;
    m.LossTangent=obj.MesherStruct.Mesh.tan_delta;