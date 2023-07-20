function varargout=getPartMesh(obj,varargin)
    if isequal(nargin,1)
        varargout{1}=obj.MesherStruct.Mesh.PartMesh;
    else
        switch varargin{1}
        case 'Gnd'
            p=obj.MesherStruct.Mesh.PartMesh.GroundPlanes.p;
            t=obj.MesherStruct.Mesh.PartMesh.GroundPlanes.t;
        case 'Rad'
            p=obj.MesherStruct.Mesh.PartMesh.Radiators.p;
            t=obj.MesherStruct.Mesh.PartMesh.Radiators.t;
        case 'Feed'
            p=obj.MesherStruct.Mesh.PartMesh.Feeds.p;
            t=obj.MesherStruct.Mesh.PartMesh.Feeds.t;
        case 'Vias'
            p=obj.MesherStruct.Mesh.PartMesh.Vias.p;
            t=obj.MesherStruct.Mesh.PartMesh.Vias.t;
        case 'Others'
            p=obj.MesherStruct.Mesh.PartMesh.Others.p;
            t=obj.MesherStruct.Mesh.PartMesh.Others.t;
        otherwise
            error(message('antenna:antennaerrors:InvalidOption'));

        end
        varargout{1}=p;
        varargout{2}=t;
    end
end