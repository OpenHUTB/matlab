function viewmesh(p,t,feedwidth,feedloc,metaltype,varargin)

    hmetal=hggroup;
    [metalname,antennaColor]=em.MeshGeometry.getMetalInfo(metaltype);
    hfill=em.MeshGeometry.view_antenna_mesh(p,t,antennaColor);
    set(hfill,'Parent',hmetal);
    set(get(get(hmetal,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','on');
    set(hmetal,'DisplayName',metalname);

    if feedwidth~=0
        hfeed=hggroup;
        em.MeshGeometry.draw_feed(feedwidth,feedloc,p,[0,1],hfeed);
        set(get(get(hfeed,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','on');
        set(hfeed,'DisplayName','feed');
    end

    grid on;
    box on;


    xlabel('x (m)');
    ylabel('y (m)');
    hfig=gcf;
    ax=findobj(hfig,'type','axes');
    z=zoom;
    z.setAxes3DPanAndZoomStyle(ax,'camera');
    if all(p(3,:)==0)
        set(ax,'Ztick',[],'ZTickLabel',[])
    else
        zlabel('z (m)');
    end
    if isempty(varargin)
        view(-38,30);
    else
        view(varargin{1}(1),varargin{1}(2));
    end



end
