function addantenna(obj)

    haxRadPat=gca;

    try
        hshowsel=uicontrol('Parent',get(haxRadPat,'Parent'),...
        'Units','Normalized','Position',[0.01,0.05,0.18,0.05],...
        'String','Show Antenna',...
        'Style','checkbox','Value',1,'Callback',@selectionCallback);
        set(hshowsel,'BackgroundColor',[0.94,0.94,0.94]);
    catch
        hshowsel=uicheckbox('Parent',get(haxRadPat,'Parent'),'Position',[10,10,200,25],...
        'text','Show Antenna','Value',1,'ValueChangedFcn',@selectionCallback);
    end



    antennaAxSpec=[0.01,0.1,0.25,0.25];
    haxAnt=axes('Position',antennaAxSpec);
    obj.MesherStruct.Geometry.wires.show_internal(2,...
    obj.MesherStruct.Geometry.volData,false);



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