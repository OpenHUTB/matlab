function protectedshow(obj)





























    if~isempty(get(groot,'CurrentFigure'))
        clf(gcf);
    end

    createGeometry(obj);
    feedwidth=getFeedWidth(obj);
    if~(isa(obj,'pcbStack')||isa(obj,'patchMicrostripInsetfed')||...
        isa(obj,'em.PrintedAntenna')||isa(obj,'em.HelixAntenna')||...
        isa(obj,'em.ConeAntenna')||isa(obj,'spiralRectangular')||...
        isa(obj,'waveguideRidge')||isa(obj,'hornRidge')||...
        isa(obj,'disconeStrip')||isa(obj,'biconeStrip')||...
        isa(obj,'rfpcb.PrintedLine')||isa(obj,'monopoleCylindrical')||...
        isa(obj,'pcbComponent'))
        feedwidth=updateFeedwidth(obj,feedwidth);
    end

    if iscell(obj.MesherStruct.Geometry)
        BorderVertices=cell2mat(cellfun(@(x)x.BorderVertices,...
        obj.MesherStruct.Geometry','UniformOutput',false));
        [~,mult,unit]=engunits(BorderVertices);
        for m=1:numel(obj.MesherStruct.Geometry)
            obj.MesherStruct.Geometry{m}.multiplier=mult;
            obj.MesherStruct.Geometry{m}.unit=unit;
        end
    else
        BorderVertices=obj.MesherStruct.Geometry.BorderVertices;
        [~,mult,unit]=engunits(BorderVertices);
        obj.MesherStruct.Geometry.multiplier=mult;
        obj.MesherStruct.Geometry.unit=unit;
    end

    if isprop(obj,'FeedLocation')
        feedloc=obj.FeedLocation;
    else
        feedloc=[];
    end




    [X,Y,Z]=em.MeshGeometry.viewgeom(obj.MesherStruct.Geometry,feedwidth,...
    feedloc,obj.MesherStruct.metalname);

    addsubstrate(obj);
    addLoad(obj,feedwidth);
    [X,Y,Z]=addphantom(obj,X,Y,Z);
    [X,Y,Z]=addplatform(obj,X,Y,Z,mult);

    if isa(obj,'em.ApertureAntenna')
        em.MeshGeometry.decoratefigureandaxes(X,Y,Z,unit,obj.ViewAngle);
    elseif isa(obj,'cassegrainOffset')
        em.MeshGeometry.decoratefigureandaxes(X,Y,Z,unit,[38,15]);
    elseif isa(obj,'gregorianOffset')
        em.MeshGeometry.decoratefigureandaxes(X,Y,Z,unit,[34,4]);
    elseif isa(obj,'hornScrimp')
        em.MeshGeometry.decoratefigureandaxes(X,Y,Z,unit,[-35,14]);
    else
        em.MeshGeometry.decoratefigureandaxes(X,Y,Z,unit);
    end

    if~strcmpi(class(obj),'infiniteArray')
        addinfinitegp(obj);
    else
        addunitcell(obj);
        if obj.MesherStruct.infGPconnected
            title(['Unit cell of ',class(obj.Element),' in an infinite Array']);
        else
            if obj.RemoveGround
                title(['Unit cell of ',class(obj.Element.Exciter),' in an infinite Array']);
            else
                title(['Unit cell of ',class(obj.Element.Exciter),' over a ',...
                class(obj.Element),' in an infinite Array']);
            end
        end
        leg1=legend('show');
        set(leg1,'Position',[0.8,0.078,0.18,0.11]);
        return;
    end

    if~obj.MesherStruct.infGP
        if isa(obj,'em.Antenna')
            title([class(obj),' antenna element']);
        elseif isa(obj,'pcbComponent')||isa(obj,'rfpcb.PrintedLine')
            title([class(obj),' element']);
        elseif isa(obj,'customArrayMesh')||isa(obj,'customArrayGeometry')
            title([class(obj),' array element']);
        elseif strcmpi(class(obj),'installedAntenna')
            ht=title('Installed antenna');%#ok<NASGU>
        elseif isprop(obj,'Element')
            if iscell(obj.Element)
                title([class(obj),' of antennas']);
            else
                title([class(obj),' of ',class(obj.Element),' antennas']);
            end
        end
    elseif obj.MesherStruct.infGP&&~obj.MesherStruct.infGPconnected
        if isa(obj,'em.Antenna')
            title([class(obj.Exciter),' over infinite ground plane']);
        else
            if iscell(obj.Element)
                title([class(obj),' of antennas over infinite ground plane']);
            else
                title([class(obj),' of ',class(obj.Element(1).Exciter),' over infinite ground plane']);
            end
        end
    else
        if isa(obj,'em.Antenna')
            title([class(obj),' over infinite ground plane']);
        else
            if iscell(obj.Element)
                title([class(obj),' of antennas over infinite ground plane']);
            else
                title([class(obj),' of ',class(obj.Element),' over infinite ground plane']);
            end
        end
    end

    leg1=legend('show');




    [aa,bb,~]=unique(leg1.String,'Stable');
    [~,bi]=setdiff(1:numel(leg1.String),bb,'Stable');
    while(numel(aa)~=numel(leg1.String))
        curAx=gca;

        dispname=copy(curAx.Children);
        leg1.String=aa;

        ch=matlab.graphics.illustration.internal.getLegendableChildren(curAx);

        ch(bi)=[];
        legend(ch,leg1.String);

        for n=1:numel(dispname)
            if~(strcmpi(dispname(n).DisplayName,curAx.Children(n).DisplayName))
                curAx.Children(n).DisplayName=dispname(n).DisplayName;
            end
        end

    end

    set(leg1,'Position',[0.8,0.078,0.18,0.11]);

    if strcmpi(class(obj),'installedAntenna')
        insetantenna(obj);
    elseif strcmpi(class(obj),'platform')
        axis equal;
        title('Platform object')
    elseif strcmpi(class(obj),'customAntennaStl')
        axis equal;
    elseif strcmpi(class(obj),'draRectangular')||strcmpi(class(obj),'draCylindrical')
        axis equal;
    elseif strcmpi(class(obj),'reflector')
        if(obj.GroundPlaneLength==0)||(obj.GroundPlaneWidth==0)
            axis equal;
        end
    end
    set(gcf,'Tag','show');
end
