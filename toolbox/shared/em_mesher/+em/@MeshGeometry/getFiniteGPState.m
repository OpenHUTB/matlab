function propVal=getFiniteGPState(obj)
    if~isfield(obj.MesherStruct.Mesh,'PartMesh')
        propVal=[];
    elseif~isempty(obj.MesherStruct.Mesh.PartMesh.GndConnectionDomain)
        propVal=true;
    elseif isempty(obj.MesherStruct.Mesh.PartMesh.GndConnectionDomain)
        propVal=false;
    end
end