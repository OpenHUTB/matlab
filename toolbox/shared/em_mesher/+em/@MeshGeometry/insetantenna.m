function insetantenna(obj)


    numElements=size(obj.ElementPosition,1);

    haxRadPat=gca;
    for m=1:numElements
        str(m)=sprintf("Element %d",m);
    end

    hshowsel=uicontrol('Parent',get(haxRadPat,'Parent'),...
    'Units','Normalized','Position',[0.01,0.01,0.18,0.05],...
    'String',str,'Style','popupmenu','Callback',@selectionCallback);
    set(hshowsel,'BackgroundColor',[0.94,0.94,0.94]);
    antNum=hshowsel.Value;


    antennaAxSpec=[0.0,0.07,0.23,0.23];
    haxAnt=axes('Position',antennaAxSpec);
    placeantenna(obj,antNum,haxAnt,antennaAxSpec,haxRadPat);


    function selectionCallback(hObj,~,~)

        antNum=get(hObj,'Value');
        placeantenna(obj,antNum,haxAnt,antennaAxSpec,haxRadPat);

    end
    axes(haxRadPat);
end


function placeantenna(obj,m,haxAnt,antennaAxSpec,haxRadPat)


    numElements=numel(obj.Element);
    if numElements==1
        m=1;
    end
    axes(haxAnt);
    cla(haxAnt);
    if iscell(obj.MesherStruct.Geometry)
        p=obj.MesherStruct.Geometry{m}.BorderVertices.';
        geom=obj.MesherStruct.Geometry{m};
    else
        p=obj.MesherStruct.Geometry(m).BorderVertices.';
        geom=obj.MesherStruct.Geometry(m);
    end
    antennaColor=[223,185,58]/255;
    em.MeshGeometry.view_antenna_boundary(geom,antennaColor);
    feedwidth=getFeedWidth(obj);
    em.MeshGeometry.draw_feed(feedwidth(m),obj.FeedLocation(m,:),p,[0,1]);

    set(haxAnt,'Xtick',[],'XTickLabel',[],'Ytick',[],'YTickLabel',[],...
    'Ztick',[],'ZTickLabel',[]);
    set(haxAnt,'Tag','geometryInInstalledAntenna');
    xlabel('');
    ylabel('');
    zlabel('');


    view(-38,30);

    setAllowAxesRotate(rotate3d,haxAnt,false);
    setAllowAxesPan(pan,haxAnt,false);
    setAllowAxesZoom(zoom,haxAnt,false);


    highX=sum(antennaAxSpec([1,3]))+0*antennaAxSpec(1);

    highY=sum(antennaAxSpec([2,4]))+0.01/2;
    lineHor=annotation('line',[0,highX],[highY,highY],'LineStyle',':');
    lineVer=annotation('line',[highX,highX],[highY,0],'LineStyle',':');



    hlink=linkprop([haxRadPat,haxAnt],{'View'});
    setappdata(haxRadPat,'rotation_link',hlink);

    haxAnt.Toolbar.Visible='off';
end