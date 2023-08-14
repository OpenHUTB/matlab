function[epsilonr,losstangent]=getMaterialParam(obj)
    epsilonr=obj.MesherStruct.Mesh.Eps_r;
    losstangent=obj.MesherStruct.Mesh.tan_delta;
end