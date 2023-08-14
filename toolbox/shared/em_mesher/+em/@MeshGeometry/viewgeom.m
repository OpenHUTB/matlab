function[X,Y,Z]=viewgeom(geometry,feedwidth,feedloc,metaltype)

    hmetal=hggroup;
    [metalname,antennaColor]=em.MeshGeometry.getMetalInfo(metaltype);
    em.MeshGeometry.view_antenna_boundary(geometry,antennaColor,hmetal,0);
    set(get(get(hmetal,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','on');
    set(hmetal,'DisplayName',metalname);

    if iscell(geometry)
        mul=geometry{1}.multiplier;
        BorderVertices=cell2mat(cellfun(@(x)x.BorderVertices,geometry',...
        'UniformOutput',false));
        X=BorderVertices(:,1).*mul;
        Y=BorderVertices(:,2).*mul;
        Z=BorderVertices(:,3).*mul;
    else
        mul=geometry.multiplier;
        BorderVertices=geometry.BorderVertices;
        X=geometry.BorderVertices(:,1).*mul;
        Y=geometry.BorderVertices(:,2).*mul;
        Z=geometry.BorderVertices(:,3).*mul;
    end

    if feedwidth~=0
        hfeed=hggroup;
        em.MeshGeometry.draw_feed(feedwidth.*mul,feedloc.*mul,...
        BorderVertices.'.*mul,[0,1],hfeed);
        set(get(get(hfeed,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','on');
        set(hfeed,'DisplayName','feed');
    end
    grid on;
    box on;

end
