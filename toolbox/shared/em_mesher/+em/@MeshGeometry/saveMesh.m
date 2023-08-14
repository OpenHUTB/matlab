function saveMesh(obj,m)

    obj.MesherStruct.Mesh.p=m.Points;
    obj.MesherStruct.Mesh.t=m.Triangles;
    obj.MesherStruct.Mesh.T=m.Tetrahedra;
    obj.MesherStruct.Mesh.Eps_r=m.EpsilonR;
    obj.MesherStruct.Mesh.tan_delta=m.LossTangent;



    chkParent=getParent(obj);
    if~isempty(chkParent)
        setHasMeshChanged(chkParent);
        resetHasStructureChanged(chkParent);
    end
    setHasMeshChanged(obj);
    resetHasStructureChanged(obj);
end
