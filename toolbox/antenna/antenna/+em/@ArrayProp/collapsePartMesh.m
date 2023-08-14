function[pPart,tPart]=collapsePartMesh(obj)

    numElements=numel(obj.Element);
    NumParts=obj.Element(1).MesherStruct.Mesh.PartMesh.NumParts;
    pPart=cell(numElements,NumParts);
    tPart=cell(numElements,NumParts);
    for i=1:numElements

        pPart(i,:)=[obj.Element(i).MesherStruct.Mesh.PartMesh.GroundPlanes.p...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Feeds.p...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Radiators.p...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Vias.p...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Others.p];

        tPart(i,:)=[obj.Element(i).MesherStruct.Mesh.PartMesh.GroundPlanes.t...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Feeds.t...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Radiators.t...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Vias.t...
        ,obj.Element(i).MesherStruct.Mesh.PartMesh.Others.t];
    end



























