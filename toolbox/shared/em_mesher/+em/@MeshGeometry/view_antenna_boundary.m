function view_antenna_boundary(geometry,antennaColor,hmetal,usebaseunits)

    if nargin==1
        antennaColor='none';
    elseif nargin==2
        hmetal=hggroup;
        usebaseunits=1;
    elseif nargin==3
        usebaseunits=1;
    end

    if iscell(geometry)
        for i=1:numel(geometry)
            makePatchForGeometry(geometry{i},antennaColor,hmetal,usebaseunits)
        end
    else
        makePatchForGeometry(geometry,antennaColor,hmetal,usebaseunits)
    end

end

function makePatchForGeometry(geometry,antennaColor,hmetal,usebaseunits)

    if~isfield(geometry,'multiplier')||usebaseunits==1
        mul=1;
    else
        mul=geometry.multiplier;
    end
    for i=1:numel(geometry.polygons)
        patchinfo.Vertices=geometry.BorderVertices.*mul;
        patchinfo.Faces=geometry.polygons{i};
        hpatch=patch(patchinfo,'FaceColor',antennaColor,'EdgeColor',...
        'none','AmbientStrength',0.5,'FaceLighting','gouraud',...
        'DiffuseStrength',0.8,'SpecularColorReflectance',0.6,...
        'SpecularStrength',0.7,'FaceOffsetFactor',0.01);
        set(hpatch,'Parent',hmetal);
    end
    if isfield(geometry,'BoundaryEdges')
        for i=1:numel(geometry.BoundaryEdges)
            patchinfo.Faces=geometry.BoundaryEdges{i};
            hedge=patch(patchinfo,'FaceColor','none',...
            'AmbientStrength',0.5,'FaceLighting','gouraud',...
            'DiffuseStrength',0.8,'SpecularColorReflectance',0.6,...
            'SpecularStrength',0.7,'FaceOffsetFactor',0.01);
            hAnnotation=get(hedge,'Annotation');
            hLegendEntry=get(hAnnotation','LegendInformation');
            set(hLegendEntry,'IconDisplayStyle','off');
        end
    end
end