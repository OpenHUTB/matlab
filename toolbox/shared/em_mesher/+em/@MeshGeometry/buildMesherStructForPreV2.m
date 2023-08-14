function rstruct=buildMesherStructForPreV2(preV2struct,V2struct,partstring)


    V2struct.Geometry=preV2struct.Geometry;

    V2struct.Mesh.FeedType=preV2struct.Mesh.FeedType;
    if isfield(preV2struct.Mesh,'p')
        V2struct.Mesh.p=preV2struct.Mesh.p;
    end
    if isfield(preV2struct.Mesh,'t')
        V2struct.Mesh.t=preV2struct.Mesh.t;
    end

    if isfield(preV2struct.Mesh,'FeedWidth')
        V2struct.Mesh.FeedWidth=preV2struct.Mesh.FeedWidth;
    end


    if isfield(preV2struct.Mesh,'PartMesh')
        if~isempty(preV2struct.Mesh.PartMesh)
            V2struct.Mesh.PartMesh.GndConnectionDomain=preV2struct.Mesh.PartMesh.GndConnectionDomain;
            V2struct.Mesh.PartMesh.GndConnectionDomainCode=preV2struct.Mesh.PartMesh.GndConnectionDomainCode;

            idGnd=1;
            idRad=1;
            idFeed=1;
            idVia=1;
            idOther=1;
            for i=1:numel(partstring)
                partId=partstring{i};

                switch partId
                case 'Gnd'
                    V2struct.Mesh.PartMesh.GroundPlanes.p{idGnd}=preV2struct.Mesh.PartMesh.p{i};
                    V2struct.Mesh.PartMesh.GroundPlanes.t{idGnd}=preV2struct.Mesh.PartMesh.t{i};
                    idGnd=idGnd+1;
                case 'Rad'
                    V2struct.Mesh.PartMesh.Radiators.p{idRad}=preV2struct.Mesh.PartMesh.p{i};
                    V2struct.Mesh.PartMesh.Radiators.t{idRad}=preV2struct.Mesh.PartMesh.t{i};
                    idRad=idRad+1;
                case 'Feed'
                    V2struct.Mesh.PartMesh.Feeds.p{idFeed}=preV2struct.Mesh.PartMesh.p{i};
                    V2struct.Mesh.PartMesh.Feeds.t{idFeed}=preV2struct.Mesh.PartMesh.t{i};
                    idFeed=idFeed+1;
                case 'Vias'
                    V2struct.Mesh.PartMesh.Vias.p{idVia}=preV2struct.Mesh.PartMesh.p{i};
                    V2struct.Mesh.PartMesh.Vias.t{idVia}=preV2struct.Mesh.PartMesh.t{i};
                    idVia=idVia+1;
                case 'Others'
                    V2struct.Mesh.PartMesh.Others.p{idOther}=preV2struct.Mesh.PartMesh.p{i};
                    V2struct.Mesh.PartMesh.Others.t{idOther}=preV2struct.Mesh.PartMesh.t{i};
                    idOther=idOther+1;
                otherwise
                    error(message('antenna:antennaerrors:InvalidOption'));

                end
            end
        end
    end

    if isfield(preV2struct.Mesh,'numEdges')
        V2struct.Mesh.numEdges=preV2struct.Mesh.numEdges;
    end
    if isfield(preV2struct.Mesh,'MaxEdgeLength')
        V2struct.Mesh.MaxEdgeLength=preV2struct.Mesh.MaxEdgeLength;
    end
    if isfield(preV2struct.Mesh,'MeshGrowthRate')
        V2struct.Mesh.MeshGrowthRate=preV2struct.Mesh.MeshGrowthRate;
    end
    V2struct.MeshingFrequency=preV2struct.MeshingFrequency;
    V2struct.MeshingChoice=preV2struct.MeshingChoice;
    V2struct.HasMeshChanged=preV2struct.HasMeshChanged;
    V2struct.Parent=preV2struct.Parent;
    V2struct.IsDynamicPropertyAdded=preV2struct.IsDynamicPropertyAdded;
    V2struct.infGP=preV2struct.infGP;
    V2struct.infGPconnected=preV2struct.infGPconnected;
    V2struct.CacheFlag=preV2struct.CacheFlag;
    V2struct.DisplayWaitBar=preV2struct.DisplayWaitBar;

    rstruct=V2struct;
end