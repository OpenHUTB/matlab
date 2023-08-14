function addantenna(obj)

    haxRadPat=gca;

    try
        hshowsel=uicontrol('Parent',get(haxRadPat,'Parent'),...
        'Units','Normalized','Position',[0.01,0.05,0.18,0.05],...
        'String','Show Antenna',...
        'Style','checkbox','Value',1,'Callback',@selectionCallback,'Tag','ShowCheckBox');
        set(hshowsel,'BackgroundColor',[0.94,0.94,0.94]);
    catch
        hshowsel=uicheckbox('Parent',get(haxRadPat,'Parent'),'Position',[10,10,200,25],...
        'text','Show Antenna','Value',1,'ValueChangedFcn',@selectionCallback,'Tag','ShowCheckBox');
    end



    antennaAxSpec=[0.01,0.1,0.25,0.25];
    haxAnt=axes('Position',antennaAxSpec);
    if iscell(obj.MesherStruct.Geometry)
        p=cell2mat(cellfun(@(x)x.BorderVertices,obj.MesherStruct.Geometry','UniformOutput',false));
        p=p';
    else
        p=obj.MesherStruct.Geometry.BorderVertices.';
    end
    if isfield(obj.MesherStruct,'metalname')
        metal_name=obj.MesherStruct.metalname;
    else
        metal_name='PEC';
    end
    [~,antennaColor]=em.MeshGeometry.getMetalInfo(metal_name);
    em.MeshGeometry.view_antenna_boundary(obj.MesherStruct.Geometry,antennaColor);
    if~isempty(obj.SolverStruct.Source)&&...
        strcmpi(obj.SolverStruct.Source.type,'planewave')
        feedwidth=getFeedWidth(obj.Element);
        em.MeshGeometry.draw_feed(feedwidth,obj.Element.FeedLocation,p,[0,1]);
    else
        feedwidth=getFeedWidth(obj);
        em.MeshGeometry.draw_feed(feedwidth,obj.FeedLocation,p,[0,1]);
    end
    addsubstrate(obj,1);
    addinfinitegp(obj,1);
    addplatform(obj,p(1,:)',p(2,:)',p(3,:)',1);
    set(haxAnt,'Xtick',[],'XTickLabel',[],'Ytick',[],'YTickLabel',[],...
    'Ztick',[],'ZTickLabel',[]);
    set(haxAnt,'Tag','geometryInPattern');
    xlabel('');
    ylabel('');
    zlabel('');


    view([135,20]);

    setAllowAxesRotate(rotate3d,haxAnt,false);
    setAllowAxesPan(pan,haxAnt,false);
    setAllowAxesZoom(zoom,haxAnt,false);


    highX=sum(antennaAxSpec([1,3]))+antennaAxSpec(1);

    highY=sum(antennaAxSpec([2,4]))+0.01;
    lineHor=annotation('line',[0,highX],[highY,highY],'LineStyle',':','tag','boundarydotted');
    lineVer=annotation('line',[highX,highX],[highY,0],'LineStyle',':','tag','boundarydotted');


    hlink=linkprop([haxRadPat,haxAnt],{'View'});
    setappdata(haxRadPat,'rotation_link',hlink);
    if~isempty(haxAnt.Toolbar)&&isvalid(haxAnt.Toolbar)
        haxAnt.Toolbar.Visible='off';
    end



    function selectionCallback(hObj,~,~)

        if get(hObj,'Value')==0
            set(haxAnt,'Visible','off');
            set(get(haxAnt,'Children'),'Visible','off');
            set([lineHor,lineVer],'LineStyle','none');
        else
            set(haxAnt,'Visible','on');
            set(get(haxAnt,'Children'),'Visible','on');
            set([lineHor,lineVer],'LineStyle',':');
        end
    end
end