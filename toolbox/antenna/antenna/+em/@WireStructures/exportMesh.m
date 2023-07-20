function[Pnodes,Pmatch]=exportMesh(obj)





    Pnodes=obj.MesherStruct.Mesh.wireNodes;
    Pmatch=obj.MesherStruct.Mesh.matchPts;

end
