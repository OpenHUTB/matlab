function addpatplusant(obj,patternOptions)













    clim=patternOptions.MagnitudeScale;
    transparency=patternOptions.Transparency;
    sizeFactor=patternOptions.SizeRatio;
    antennaOffset=patternOptions.AntennaOffset;



    fig=get(groot,'CurrentFigure');

    axes_pattern=gca;
    set(axes_pattern,'Visible','off');
    set(get(axes_pattern,'Children'),'Visible','on');
    set(axes_pattern,'Tag','patternAxis');

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
    if(isprop(obj,'Platform'))
        plat_geom=getGeometry(obj.Platform);
        plat_Vertices=max(abs(plat_geom.BorderVertices));

    end



    if iscell(obj.MesherStruct.Geometry)
        Vertices=cell2mat(cellfun(@(x)max(abs(x.BorderVertices)),obj.MesherStruct.Geometry','UniformOutput',false));
    else
        Vertices=max(abs(obj.MesherStruct.Geometry.BorderVertices));
    end





    sf=axes_pattern.Children(1);
    h=hggroup('tag','patterngroup');
    set(axes_pattern.Children(2:end),'Parent',h);
    sf.FaceAlpha=transparency;





    tmp=class(obj);
    if(strcmpi(tmp,'installedAntenna'))
        sizeFactor=sizeFactor*5;
    end
    factor=sizeFactor/sqrt(sum(max([Vertices;plat_Vertices]).^2,2));

    direction=[0,0,1];
    if(strcmpi(class(obj),'sectorInvertedAmos'))
        direction=[1,0,0];
    end









    if((numel(tmp)>=5&&strcmpi(tmp(end-4:end),'Array'))||...
        strcmpi(tmp,'installedAntenna'))


        if((isa(obj,'conformalArray')&numel(obj.Element)==1)|isa(obj,'infiniteArray'))
            Vertices_polygons=getVerticesPolygons(obj);
            p=Vertices_polygons{1};Polygons=Vertices_polygons{2};
            groundplane=hasGroundplane(obj.Element);
            nullpt=getAlignmentPoint(p,Polygons,obj,groundplane,direction);
        elseif(isprop(obj,'ElementPosition'))
            nullpt=mean(obj.ElementPosition,1);
        else
            nullpt=mean(obj.FeedLocation,1);
        end

    elseif(strcmpi(class(obj),'pcbStack'))
        if(isa(obj.BoardShape,'antenna.Polygon'))
            centre_values=mean(obj.BoardShape.Vertices(:,1:2),'omitnan');
        else
            centre_values=obj.BoardShape.Center;
        end
        numval=0;
        z=0;
        for i=1:numel(obj.Layers)
            if(~strcmpi(class(obj.Layers{i}),'dielectric'))
                if(strcmpi(class(obj.Layers{i}),'antenna.Polygon'))
                    centre_patch=mean(obj.Layers{i}.Vertices,'omitnan');
                    centre_patch=centre_patch(1:2);
                else
                    centre_patch=obj.Layers{i}.Center;
                end

                centre_values=centre_values+centre_patch;
                numval=numval+1;
            else
                z=z+obj.Layers{i}.Thickness;

            end

        end
        if(numval==1||numval==2)
            nullpt=[centre_values,obj.BoardThickness];
        else
            nullpt=[centre_values/numval,z];
        end
    elseif(((numel(tmp)>=9)&&strcmpi(tmp(1:9),'reflector'))||...
        strcmpi(tmp,'cavity'))
        groundplane=hasGroundplane(obj.Exciter);
        Vertices_polygons=getVerticesPolygons(obj);
        if(iscell(obj.Exciter.MesherStruct.Geometry))
            numOfPoly=sum(cell2mat(cellfun(@(x)numel(x.polygons),obj.Exciter.MesherStruct.Geometry',...
            'UniformOutput',false)));
            Polygons=Vertices_polygons{2}(2:end);
        else
            numOfPoly=numel(obj.Exciter.MesherStruct.Geometry.polygons);
            Polygons=obj.Exciter.MesherStruct.Geometry.polygons;
        end

        if((numel(Vertices_polygons{2})-numOfPoly)==0)
            strtpt=0;
        elseif(isa(obj,'em.BackingStructure')||isa(obj,'em.ParabolicAntenna'))...
            &&em.internal.checkLRCArray(obj.Exciter)
            if(isprop(obj,'GroundPlaneLength')&&isinf(obj.GroundPlaneLength))||...
                (isprop(obj,'GroundPlaneWidth')&&isinf(obj.GroundPlaneWidth))
                strtpt=0;
            else
                strtpt=max(max(Vertices_polygons{2}{1}));
            end
        else
            strtpt=max(max(Vertices_polygons{2}{end-numOfPoly}));
        end
        tmp=min(cell2mat(cellfun(@(x)min(min(x)),Polygons,'UniformOutput',false)));
        if(tmp>1)
            Polygons=cellfun(@(x)x-tmp+1,Polygons,'UniformOutput',false);
        end
        p=Vertices_polygons{1}(strtpt+1:end,:);
        nullpt=getAlignmentPoint(p,Polygons,obj.Exciter,groundplane,direction);

    else
        groundplane=hasGroundplane(obj);
        Vertices_polygons=getVerticesPolygons(obj);
        p=Vertices_polygons{1};Polygons=Vertices_polygons{2};
        nullpt=getAlignmentPoint(p,Polygons,obj,groundplane,direction);
    end

    if((isprop(obj,'GroundPlaneLength')&obj.GroundPlaneLength==Inf)|...
        (isprop(obj,'GroundPlaneWidth')&obj.GroundPlaneWidth==Inf)|...
        (isprop(obj,'GroundPlaneRadius')&obj.GroundPlaneRadius==Inf))
        factor=0.7*factor;
        nullpt=[0,0,0];
    end



    geom=obj.MesherStruct.Geometry;


    if iscell(obj.MesherStruct.Geometry)
        numval=numel(obj.MesherStruct.Geometry);
        for i=1:numval
            obj.MesherStruct.Geometry{i}.BorderVertices=(obj.MesherStruct.Geometry{i}.BorderVertices-nullpt)*factor+antennaOffset;
            if(~isempty(obj.MesherStruct.Geometry{i}.SubstrateVertices))
                obj.MesherStruct.Geometry{i}.SubstrateVertices=(obj.MesherStruct.Geometry{i}.SubstrateVertices-nullpt)*factor+antennaOffset;
                if isfield(obj.MesherStruct.Geometry{i},'SubstrateBoundaryVertices')&&~isempty(obj.MesherStruct.Geometry{i}.SubstrateBoundaryVertices)
                    obj.MesherStruct.Geometry{i}.SubstrateBoundaryVertices=(obj.MesherStruct.Geometry{i}.SubstrateBoundaryVertices-nullpt)*factor+antennaOffset;
                end
            end
        end
    else
        obj.MesherStruct.Geometry.BorderVertices=(obj.MesherStruct.Geometry.BorderVertices-nullpt)*factor+antennaOffset;
        if(~isempty(obj.MesherStruct.Geometry.SubstrateVertices))
            obj.MesherStruct.Geometry.SubstrateVertices=(obj.MesherStruct.Geometry.SubstrateVertices-nullpt)*factor+antennaOffset;
            if isfield(obj.MesherStruct.Geometry,'SubstrateBoundaryVertices')&&~isempty(obj.MesherStruct.Geometry.SubstrateBoundaryVertices)
                obj.MesherStruct.Geometry.SubstrateBoundaryVertices=(obj.MesherStruct.Geometry.SubstrateBoundaryVertices-nullpt)*factor+antennaOffset;
            end
        end
    end









    p1=[1.2,-1.2;1.2,-1.2;1.2,-1.2];

    if(isprop(obj,'Platform'))
        hold on;
        plat_Vertices=(plat_geom.BorderVertices-nullpt)*factor+antennaOffset;
        H=trisurf(plat_geom.polygons{1},plat_Vertices(:,1),plat_Vertices(:,2),plat_Vertices(:,3),...
        'FaceColor',[0.5,0.5,0.5],'FaceAlpha',0.8,'EdgeColor',...
        [0.49,0.49,0.49],'EdgeAlpha',0.1);
        hold off;
    end
    if isfield(obj.MesherStruct,'metalname')
        metal_name=obj.MesherStruct.metalname;
    else
        metal_name='PEC';
    end
    [~,antennaColor]=em.MeshGeometry.getMetalInfo(metal_name);
    hmetal=hggroup;
    em.MeshGeometry.view_antenna_boundary(obj.MesherStruct.Geometry,antennaColor,hmetal,1);

    feedwidth=getFeedWidth(obj);
    if isempty(feedwidth)
        feedwidth=0.1e-3;
    end
    feedwidth=feedwidth*factor;
    addsubstrate(obj,1);
    addinfinitegp(obj,1);

    feedloc=obj.FeedLocation;
    if isempty(feedloc)
        feedloc=[0,0,0];
    end
    em.MeshGeometry.draw_feed(feedwidth,(feedloc-nullpt)*factor+antennaOffset,p1,clim);
    obj.MesherStruct.Geometry=geom;
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

function nullpt=getAlignmentPoint(Vertices,Polygons,obj,groundplane,direction)


    iter=size(obj.FeedLocation);
    nullpt=zeros(iter(1),3);

    for indx=1:iter(1)
        tmp_feed=obj.FeedLocation(indx,:);
        distance_vector=distancecart(Vertices,tmp_feed);
        [~,nearestpt]=min(distance_vector);



        if(groundplane)

            dist=get_z_dist(Vertices,direction,obj.Tilt,obj.TiltAxis);

            dist=round(dist,3);
            diff_val=dist(1:end-1)-dist(2:end);
            values=[dist(abs(diff_val)>0);dist(end)]*1e3;
            datavalues=categorical(values);
            tmp=categories(datavalues);

            if(numel(tmp)>10)
                if~isempty(Polygons)
                    faces=Polygons{1};
                    cutoff=max(max(faces));
                else
                    cutoff=size(Vertices,1);
                end
                nullpt(indx,:)=mean(Vertices(1:cutoff,:));
            elseif(numel(tmp)==1)
                nullpt(indx,:)=mean(Vertices);
            else
                sel=abs(dist)>0;
                nullpt(indx,:)=mean(Vertices(sel,:));
            end
        else
            for i=1:numel(Polygons)
                obj_faces=Polygons{i};
                sel=(obj_faces==nearestpt);
                if(any(sel(:)))
                    nullpt(indx,:)=mean(Vertices(min(min(obj_faces)):max(max(obj_faces)),:));
                    break
                end
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

function dist=get_z_dist(Vertices,direction,Tilt,TiltAxis)


    if(ischar(TiltAxis))
        TiltAxis=double(TiltAxis'==['X','Y','Z']);
    end
    tmp=direction';
    for i=1:size(Tilt,1)
        tmp=em.internal.rotateshape(tmp,[0,0,0],TiltAxis(i,:),Tilt(i));
    end
    dist=Vertices*tmp;
end

function vertices_polygons=getVerticesPolygons(obj)

    if(iscell(obj.MesherStruct.Geometry))
        p=cell2mat(cellfun(@(x)x.BorderVertices,obj.MesherStruct.Geometry','UniformOutput',false));
        Polygons=[];
    else
        p=obj.MesherStruct.Geometry.BorderVertices;
        Polygons=obj.MesherStruct.Geometry.polygons;
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











































