function savePartMesh(obj,parts)








    if~isequal(parts.NumGnds,0)
        for i=1:(parts.NumGnds)
            obj.MesherStruct.Mesh.PartMesh.GroundPlanes.p{i}=parts.GroundPlanes.Gnd{i}{1};
            obj.MesherStruct.Mesh.PartMesh.GroundPlanes.t{i}=parts.GroundPlanes.Gnd{i}{2};
        end
    end

    if~isequal(parts.NumRads,0)
        for i=1:(parts.NumRads)
            obj.MesherStruct.Mesh.PartMesh.Radiators.p{i}=parts.Radiators.Rad{i}{1};
            obj.MesherStruct.Mesh.PartMesh.Radiators.t{i}=parts.Radiators.Rad{i}{2};
        end
    end

    if~isequal(parts.NumFeeds,0)
        for i=1:(parts.NumFeeds)
            obj.MesherStruct.Mesh.PartMesh.Feeds.p{i}=parts.Feeds.Feed{i}{1};
            obj.MesherStruct.Mesh.PartMesh.Feeds.t{i}=parts.Feeds.Feed{i}{2};
        end
    end

    if~isequal(parts.NumVias,0)
        for i=1:(parts.NumVias)
            obj.MesherStruct.Mesh.PartMesh.Vias.p{i}=parts.Vias.Via{i}{1};
            obj.MesherStruct.Mesh.PartMesh.Vias.t{i}=parts.Vias.Via{i}{2};
        end
    end

    if~isequal(parts.NumOthers,0)
        for i=1:(parts.NumOthers)
            obj.MesherStruct.Mesh.PartMesh.Others.p{i}=parts.Others.Other{i}{1};
            obj.MesherStruct.Mesh.PartMesh.Others.t{i}=parts.Others.Other{i}{2};
        end
    end


    partCount=parts.NumGnds+...
    parts.NumRads+...
    parts.NumFeeds+...
    parts.NumVias+...
    parts.NumOthers;
    obj.MesherStruct.Mesh.PartMesh.NumParts=partCount;
    obj.MesherStruct.Mesh.PartMesh.NumGnds=parts.NumGnds;
    obj.MesherStruct.Mesh.PartMesh.NumRads=parts.NumRads;
    obj.MesherStruct.Mesh.PartMesh.NumFeeds=parts.NumFeeds;
    obj.MesherStruct.Mesh.PartMesh.NumVias=parts.NumVias;
    obj.MesherStruct.Mesh.PartMesh.NumOthers=parts.NumOthers;
end