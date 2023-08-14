function addLoad(obj,feedwidth)

    if~isfield(obj.MesherStruct,'Load')||...
        ~isfield(obj.MesherStruct.Load,'Location')||...
        isempty(obj.MesherStruct.Load.Location)
        return;
    end
    Zloc=obj.MesherStruct.Load.Location;
    feedColor=[0,0,255]/255;

    if obj.MesherStruct.Load.numLoads>0
        geometry=obj.MesherStruct.Geometry;
        if iscell(geometry)
            BorderVertices=cell2mat(cellfun(@(x)x.BorderVertices,...
            geometry','UniformOutput',false));
            mul=geometry{1}.multiplier;
        else
            BorderVertices=geometry.BorderVertices;
            mul=geometry.multiplier;
        end
        loadw=ones(1,obj.MesherStruct.Load.numLoads)*feedwidth(1);
        hload=hggroup;
        em.MeshGeometry.draw_feed(loadw.*mul,Zloc'.*mul,...
        BorderVertices.'.*mul,[0,1],hload,feedColor,'load');
        set(get(get(hload,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','on');
        set(hload,'DisplayName','load');
    end
end