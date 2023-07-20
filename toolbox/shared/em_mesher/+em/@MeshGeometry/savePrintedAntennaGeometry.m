function savePrintedAntennaGeometry(obj,geom)

    obj.MesherStruct.Geometry=geom;
    saveLoad(obj);
    saveConductor(obj);
end