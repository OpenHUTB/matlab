function saveMesh(obj,m)


    obj.MesherStruct.Mesh.wiresSeg=m.wiresSeg;
    obj.MesherStruct.Mesh.volDataSeg=m.volDataSeg;
    obj.MesherStruct.Mesh.wiresMPt=m.wiresMPt;
    obj.MesherStruct.Mesh.volDataMPt=m.volDataMPt;
    obj.MesherStruct.Mesh.wiresBoth=m.wiresBoth;
    obj.MesherStruct.Mesh.volDataBoth=m.volDataBoth;
    obj.MesherStruct.Mesh.wireNodes=m.wireNodes;
    obj.MesherStruct.Mesh.matchPts=m.matchPts;
    obj.MesherStruct.Mesh.bothPts=m.bothPts;
    obj.MesherStruct.Mesh.numParts=m.numParts;

    setHasMeshChanged(obj);
    resetHasStructureChanged(obj);
end