function Hmax=updateFreqBasedEdgeLength(obj,freq,speedOfLight,elementsPerLambda)








    obj.MesherStruct.MeshingFrequency=freq;
    Hmax=speedOfLight/obj.MesherStruct.MeshingFrequency/elementsPerLambda;


