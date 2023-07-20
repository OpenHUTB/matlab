function addpatplusant(obj,patternOptions)










    clim=patternOptions.MagnitudeScale;
    transparency=patternOptions.Transparency;
    sizeFactor=patternOptions.SizeRatio;
    antennaOffset=patternOptions.AntennaOffset;


    fig=get(groot,'CurrentFigure');

    axes_pattern=gca;
    set(axes_pattern,'Visible','off');
    set(get(axes_pattern,'Children'),'Visible','on');

    f=gcf;

    axis off;

    addantenna(obj);
    smallantenna=gca;
    set(fig,'CurrentAxes',axes_pattern);

    button_show=findobj(gcf,'Text','Show Antenna');
    if isempty(button_show)


        button_show=findobj(gcf,'String','Show Antenna');
    end
    button_show.delete;
    smallantenna.Visible='off';
    set(get(smallantenna,'Children'),'Visible','off');

    Lines=findall(gcf,'tag','boundarydotted');
    set(Lines,'Visible','off');


    try
        menu=uicontrol('Style','popupmenu','String',{'Show Antenna';'Hide Antenna';...
        'Overlay Antenna'},'Units','Normalized','Position',[0.01,0.01,0.20,0.05],...
        'Callback',@selectionCallback,'Tag','patternpopUp');
    catch
        posval=[10,10,180,25];




        menu=uidropdown(f,'Items',{'Show Antenna';'Hide Antenna';...
        'Overlay Antenna'},'Position',posval,...
        'ValueChangedFcn',@selectionCallback,'Tag','patternpopUp');
    end


    plat_Vertices=[];







    G=getGeometry(obj);
    if iscell(G)
        Vertices=cell2mat(cellfun(@(y)cell2mat(cellfun(@(x)...
        max(abs(x.Vertices)),y.volData.Surfaces',...
        'UniformOutput',false)),G,'UniformOutput',false));
    else
        Vertices=cell2mat(cellfun(@(x)max(abs(x.Vertices)),...
        G.volData.Surfaces','UniformOutput',false));
    end





    sf=axes_pattern.Children(1);
    h=hggroup('tag','patterngroup');
    set(axes_pattern.Children(2:end),'Parent',h);
    sf.FaceAlpha=transparency;









    factor=sizeFactor/sqrt(sum(max([Vertices;plat_Vertices]).^2,2));

    direction=[0,0,1];












    if(obj.getTotalArrayElems>1)


        nullpt=mean(obj.FeedLocation,1);
    else
        groundplane=hasGroundplane(obj);
        Vertices_polygons=getVerticesPolygons(obj);
        p=Vertices_polygons{1};Polygons=Vertices_polygons{2};
        nullpt=getAlignmentPoint(p,Polygons,obj,groundplane,direction);
    end











    geom=getGeometry(obj);
    geom.wires=clone(geom.wires);

    volData=em.wire.Volume;
    for surfInd=1:numel(geom.volData.Surfaces)
        volData.add(em.wire.Surface(geom.volData.Surfaces{surfInd}),...
        geom.volData.Colors(surfInd,:));
    end
    geom.volData=volData;

    for partsInd=1:length(geom.wires.Parts)
        geom.wires.Parts(partsInd).WireDiameter=...
        geom.wires.Parts(partsInd).WireDiameter*factor;
        geom.wires.Parts(partsInd).StartPoint=...
        (geom.wires.Parts(partsInd).StartPoint-nullpt)*factor+...
        antennaOffset;
        geom.wires.Parts(partsInd).Length=...
        geom.wires.Parts(partsInd).Length*factor;
    end

    if iscell(geom)
        numval=numel(geom);
        for i=1:numval
            numSurf=numel(geom.volData.Surfaces);
            for surfInd=1:numSurf
                geom{i}.volData.Surfaces{surfInd}.Vertices=...
                (geom{i}.volData.Surfaces{surfInd}.Vertices-...
                nullpt)*factor+antennaOffset;
            end
        end
    else
        numSurf=numel(geom.volData.Surfaces);
        for surfInd=1:numSurf
            geom.volData.Surfaces{surfInd}.Vertices=...
            (geom.volData.Surfaces{surfInd}.Vertices-nullpt)*...
            factor+antennaOffset;
        end
    end









    p1=[1.2,-1.2;1.2,-1.2;1.2,-1.2];










    geom.wires.show_internal(2,geom.volData,false,[],[],p1,clim);



    axis equal;
    view([135,20]);
    set(axes_pattern,'Xtick',[],'XTickLabel',[],'Ytick',[],'YTickLabel',[],...
    'Ztick',[],'ZTickLabel',[]);
    set(smallantenna,'Xtick',[],'XTickLabel',[],'Ytick',[],'YTickLabel',[],...
    'Ztick',[],'ZTickLabel',[]);
    xlabel('');
    ylabel('');
    zlabel('');







    taggrp=hggroup('Tag',num2str(rand*100),'Parent',axes_pattern,'HandleVisibility','off');
    patternOptions.setTag(taggrp);
    patternOptions.setPlot(f);
    selectionCallback(menu);



    function selectionCallback(hObj,~,~)


        grp=findobj(f,'Parent',axes_pattern,'-not','Tag','patterngroup');
        sf_tmp=findobj(f,'Tag','3D polar plot');

        if strcmpi(hObj.Type,'uidropdown')
            val=find(strcmpi(hObj.Items,hObj.Value));
        else
            val=hObj.Value;
        end

        switch val
        case 1

            set_group(grp,'off');
            smallantenna.Visible='on';
            set(get(smallantenna,'Children'),'Visible','on');
            sf_tmp.FaceAlpha=patternOptions.Transparency;
            set(Lines,'Visible','on');
        case 2
            set_group(grp,'off');
            smallantenna.Visible='off';
            set(get(smallantenna,'Children'),'Visible','off');
            sf_tmp.FaceAlpha=patternOptions.Transparency;
            set(Lines,'Visible','off');
        case 3
            set_group(grp,'on');
            smallantenna.Visible='off';
            set(get(smallantenna,'Children'),'Visible','off');
            sf_tmp.FaceAlpha=patternOptions.Transparency;
            set(Lines,'Visible','off');
        end



    end


end

function nullpt=getAlignmentPoint(Vertices,Polygons,obj,groundplane,~)


    iter=size(obj.FeedLocation);
    nullpt=zeros(iter(1),3);

    for indx=1:iter(1)
        tmp_feed=obj.FeedLocation(indx,:);
        if(iscell(Vertices))
            distance_vector=cellfun(@(x)distancecart(x,tmp_feed),Vertices,'UniformOutput',false);
            [~,nearestpt]=cellfun(@(x)min(x),distance_vector,'UniformOutput',false);
        else
            distance_vector=distancecart(Vertices,tmp_feed);
            [~,nearestpt]=min(distance_vector);
        end



        if(groundplane)

























        else
            temp_nullpt=zeros(0,3);
            for i=1:numel(Polygons)
                obj_faces=Polygons{i};
                sel=(obj_faces==nearestpt{i});
                if(any(sel(:)))
                    temp_nullpt(end+1,:)=mean(Vertices{i}(min(min(obj_faces)):max(max(obj_faces)),:));%#ok<AGROW>
                end
            end
            if~isempty(temp_nullpt)
                nullpt(indx,:)=mean(temp_nullpt,1);
            end
        end
    end
    nullpt=mean(nullpt,1);
end

function dist=distancecart(A,B)

    dist=sqrt(sum((A-B).^2,2));
end


function set_group(obj,val)



    str_val='matlab.graphics.primitive.Group';
    for k=1:numel(obj)
        tmpcls=class(obj(k));
        if(all(tmpcls(end-5:end)==str_val(end-5:end)))
            for j=1:numel(obj(k))
                tmp=obj(k);
                tmp(j).Visible=val;
            end
        else
            obj(k).Visible=val;
        end
    end
end














function vertices_polygons=getVerticesPolygons(obj)

    G=getGeometry(obj);
    if(iscell(G))
        p={};
        Polygons={};
        for Gind=1:numel(G)
            p=[p,cellfun(@(x)x.Vertices,G{Gind}.volData.Surfaces','UniformOutput',false)];%#ok<AGROW>
            Polygons=[Polygons,cellfun(@(x)x.Faces,G{Gind}.volData.Surfaces','UniformOutput',false)];%#ok<AGROW>
        end
    else
        p=cellfun(@(x)x.Vertices,G.volData.Surfaces','UniformOutput',false);
        Polygons=cellfun(@(x)x.Faces,G.volData.Surfaces','UniformOutput',false);
    end

    vertices_polygons={p,Polygons};
end

function gp=hasGroundplane(obj)
    gp=false;
    groundplane_values=10*isprop(obj,'GroundPlaneRadius')+1*(isprop(obj,'GroundPlaneLength')...
    ||isprop(obj,'GroundPlaneWidth'));
    switch groundplane_values
    case 10
        if(~isempty(obj.GroundPlaneRadius))
            gp=true;
        end
    case 1
        if(~isempty(obj.GroundPlaneLength))
            gp=true;
        end
    case 11
        if(~isempty(obj.GroundPlaneRadius))
            gp=true;
        end
        if(~isempty(obj.GroundPlaneLength))
            gp=true;
        end
    otherwise
        gp=false;
    end

    if(strcmpi(class(obj),'monopoleTopHat')...
        ||strcmpi(class(obj),'monopole'))
        gp=false;
    end
end











































