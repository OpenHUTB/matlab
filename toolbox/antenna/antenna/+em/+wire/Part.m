classdef(Abstract)Part<handle&matlab.mixin.Heterogeneous




    properties
        StartPoint=em.wire.Part.DefaultStartPoint
        Azimuth=em.wire.Part.DefaultAzimuth
        Elevation=em.wire.Part.DefaultElevation
        Load=lumpedElement
    end

    properties(Access=private,Constant)
        DefaultStartPoint=[0,0,0]
        DefaultAzimuth=0
        DefaultElevation=90
    end

    properties(Abstract,Hidden)
Color
    end

    properties(Dependent,GetAccess=protected,SetAccess=private)
Transform
    end

    properties(Constant,Access=protected)
        LightSpeed=2.99792458e8
    end

    methods(Access=protected)
        function p=makeInputParser(obj)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'StartPoint',obj.DefaultStartPoint);
            addParameter(p,'Azimuth',obj.DefaultAzimuth);
            addParameter(p,'Elevation',obj.DefaultElevation);
        end

        function setParsedProperties(obj,p)
            obj.StartPoint=p.Results.StartPoint;
            obj.Azimuth=p.Results.Azimuth;
            obj.Elevation=p.Results.Elevation;
        end
    end

    methods
        function obj=Part(varargin)
            if nargin>0
                p=makeInputParser(obj);
                parse(p,varargin{:});
                setParsedProperties(obj,p);
            end
        end

        function set.StartPoint(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','vector','finite','real','nonnan','numel',3})
            obj.StartPoint=val;
        end

        function set.Azimuth(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real'})
            obj.Azimuth=val;
        end

        function set.Elevation(obj,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','scalar','finite','real'})
            obj.Elevation=val;
        end

        function T=get.Transform(obj)






            T=em.wire.AffineTransform;
            rotateZ(T,degtorad(obj.Azimuth));
            [x,y,z]=sph2cart(degtorad(obj.Azimuth),...
            degtorad(obj.Elevation),1);
            rotate(T,[0,0,1],[x,y,z]);
            translate(T,obj.StartPoint);
        end
    end

    methods(Access=protected)
        function copyProperties(in,out)

            out.StartPoint=in.StartPoint;
            out.Azimuth=in.Azimuth;
            out.Elevation=in.Elevation;
            out.Color=in.Color;
        end
    end

    methods
        function out=clone(obj)

            out=localClone(obj);
        end
    end

    methods(Abstract,Hidden)
        out=localClone(obj)
    end

    methods(Hidden)
        function val=isRadiatorLossy(obj)%#ok<MANU>

            val=false;
        end

        function vol=makeVolume(obj,isMultiColor)
            if nargin==1
                isMultiColor=false;
            end

            [msh,objs]=makeMesh(obj);
            tol=sqrt(eps)*obj.Length;

            vol=em.wire.Volume;
            n=numel(msh.Surfaces);
            nc=em.wire.WirePart.NumPoints;
            theta=(0:nc-1)'*2*pi/nc;
            for i=1:n

                if isMultiColor
                    colorPrev=objs(i).Color-1;
                else
                    colorPrev=objs(i).Color;
                end
                diam=objs(i).WireDiameter;
                r=0.5*diam;
                curv=em.wire.Curve(r*cos(theta),r*sin(theta),zeros(nc,1));
                enddiam=objs(i).EndDiameter;
                if diam~=enddiam
                    r=0.5*enddiam;
                    endCurv=em.wire.Curve(r*cos(theta),r*sin(theta),zeros(nc,1));
                else
                    endCurv=copy(curv);
                end

                pts=msh.Surfaces{i}.Vertices;
                v1=diff(pts);
                T=em.wire.AffineTransform;
                rotate(T,[0,0,1],v1)
                translate(T,pts(1,:))
                transform(curv,T)
                transform(endCurv,T)

                Tsnap=em.wire.AffineTransform;
                translate(Tsnap,v1)
                color=objs(i).Color;

                transform(endCurv,Tsnap);
                voli=em.wire.Volume;
                if i==1||objs(i-1).EndDiameter<diam||...
                    any(msh.Surfaces{i-1}.Vertices(2,:)~=pts(1,:))
                    add(voli,em.wire.Surface(curv),colorPrev)
                end
                if~isempty(objs(i).PhantomNextParts)
                    mshPhant=makeMesh(objs(i).PhantomNextParts);
                    ptsPhant=mshPhant.Surfaces{1}.Vertices;
                    if norm(ptsPhant(2,:)-pts(1,:),inf)<=tol
                        v1Phant=diff(mshPhant.Surfaces{1}.Vertices);
                        v2Phant=diff(pts);
                        Tbend=em.wire.AffineTransform;
                        rotate(Tbend,v1Phant,v2Phant,ptsPhant(2,:));
                        if max(max(abs(Tbend.T-eye(4))))>sqrt(eps)
                            diamPhant=objs(i).PhantomNextParts(1).EndDiameter;
                            rPhant=0.5*diamPhant;
                            endCurvPhant=em.wire.Curve(rPhant*cos(theta),rPhant*sin(theta),zeros(nc,1));
                            T=em.wire.AffineTransform;
                            rotate(T,[0,0,1],v1Phant)
                            translate(T,v1Phant)
                            translate(T,ptsPhant(1,:))
                            transform(endCurvPhant,T)

                            voliTemp=extruder(endCurvPhant,Tbend,1,objs(i).PhantomNextParts.Color);
                            add(voli,voliTemp);
                        end
                    elseif norm(ptsPhant(1,:)-pts(2,:),inf)<=tol
                        v2Phant=diff(mshPhant.Surfaces{1}.Vertices);
                        Tbend=em.wire.AffineTransform;
                        rotate(Tbend,v1,v2Phant,pts(2,:));
                        if max(max(abs(Tbend.T-eye(4))))>sqrt(eps)

                            voliTemp=extruder(endCurv,Tbend,1,color);
                            add(voli,voliTemp);
                        end
                    end
                end
                add(voli,em.wire.Surface(curv,endCurv),color,colorPrev);
                if i==n||enddiam>objs(i+1).WireDiameter||...
                    any(pts(2,:)~=msh.Surfaces{i+1}.Vertices(1,:))
                    add(voli,em.wire.Surface(endCurv),color)
                end
                add(vol,voli);
                transform(curv,Tsnap)

                if i<n
                    pts2=msh.Surfaces{i+1}.Vertices;

                    if norm(pts(2,:)-pts2(1,:),inf)<=tol
                        v2=diff(pts2);
                        Tbend=em.wire.AffineTransform;
                        if enddiam<=objs(i+1).WireDiameter
                            rotate(Tbend,v1,v2,pts(2,:));
                            if max(max(abs(Tbend.T-eye(4))))>sqrt(eps)

                                voli=extruder(endCurv,Tbend,1,color);
                                add(vol,voli);
                            end
                        else
                            rotate(Tbend,-v2,-v1,pts2(1,:));
                            if max(max(abs(Tbend.T-eye(4))))>sqrt(eps)


                                diam=objs(i+1).WireDiameter;
                                r=0.5*diam;
                                curv=em.wire.Curve(r*cos(theta),r*sin(theta),zeros(nc,1));
                                T=em.wire.AffineTransform;
                                rotate(T,[0,0,1],v2)
                                translate(T,pts2(1,:))
                                transform(curv,T)

                                voli=extruder(curv,Tbend,1,color);
                                add(vol,voli);
                            end
                        end
                    end
                end
                colorPrev=color;
            end
        end

        function p=show_internal(obj,dim,vol,showLegend,mult,unit,feedAxis,clim)

            if nargin<6||isempty(mult)
                mult=1;
                unit='';
            end
            p=show(vol,dim,mult);
            b=vol.Bounds*mult;
            if nargin<7||isempty(feedAxis)

                feedAxis=b.';
            end
            if nargin<8
                clim=[0,1];
            end

            feedwidth=[];
            feedloc=[];
            if~isempty(obj.FeedLocation)
                if isa(obj,'em.wire.partAntenna')


                    for i=1:numel(obj.Parts)
                        if isa(obj.Parts(i),'em.wire.WirePart')&&...
                            ~isempty(obj.Parts(i).FeedLocation)
                            feedloc=obj.Parts(i).FeedLocation;
                            feedwidth=2*obj.Parts(i).WireDiameter;
                            break
                        end
                    end
                elseif isa(obj,'em.wire.WirePart')
                    feedloc=obj.FeedLocation;
                    feedwidth=2*obj.WireDiameter;
                end
            else

                if isa(obj,'em.wire.partAntenna')


                    for i=1:numel(obj.Parts)
                        if isa(obj.Parts(i),'em.wire.WirePart')&&...
                            ~isempty(obj.Parts(i).FeedLocation)
                            feedloc(end+1,:)=obj.Parts(i).FeedLocation;%#ok<AGROW>
                            feedwidth(end+1)=2*obj.Parts(i).WireDiameter;%#ok<AGROW>
                        end
                    end
                end
            end
            feedloc=feedloc*mult;
            feedwidth=feedwidth*mult;



            if showLegend
                hmetal=hggroup;
                set(p,'Parent',hmetal);

                set(get(get(hmetal,'Annotation'),'LegendInformation'),...
                'IconDisplayStyle','on');
                if any(feedwidth~=0)
                    hfeed=hggroup;

                    if dim==1
                        pfeed=p(arrayfun(@(x)isequal(x.FaceColor,[176,0,27]/255),p));
                        set(pfeed,'Parent',hfeed)
                        pfeed=p(arrayfun(@(x)isequal(x.EdgeColor,[176,0,27]/255),p));
                        set(pfeed,'Parent',hfeed)
                    else
                        em.MeshGeometry.draw_feed(2*feedwidth(feedwidth~=0),...
                        feedloc(feedwidth~=0,:),feedAxis,[0,1],hfeed)
                    end
                    set(get(get(hfeed,'Annotation'),'LegendInformation'),...
                    'IconDisplayStyle','on');
                    set(hfeed,'DisplayName','feed');
                end
                grid on;
                box on;


                if dim>1
                    set(hmetal,'DisplayName','PEC');
                    em.MeshGeometry.decoratefigureandaxes(b(:,1),b(:,2),b(:,3),unit)
                elseif dim==1

                    set(hmetal,'DisplayName','  wire segment');
                    em.MeshGeometry.decoratefigureandaxes(feedAxis(:,1),feedAxis(:,2),feedAxis(:,3),unit)
                else
                    set(hmetal,'DisplayName','  matching points');
                    em.MeshGeometry.decoratefigureandaxes(feedAxis(:,1),feedAxis(:,2),feedAxis(:,3),unit)
                end
            else
                if any(feedwidth~=0)&&dim~=1
                    em.MeshGeometry.draw_feed(2*feedwidth(feedwidth~=0),...
                    feedloc(feedwidth~=0,:),feedAxis,clim)
                end
            end

            firstObj=obj(1);
            while isa(firstObj,'em.wire.partAntenna')
                firstObj=firstObj.Parts(1);
            end
            if isa(firstObj,'ground')

                makePatchForInfGPGeometry(true,b(2,1),b(2,2),b(2,3),feedwidth)
            end

            if showLegend
                leg1=legend('show');
                set(leg1,'Position',[0.73,0.078,0.25,0.11]);
            end
        end
    end

    methods
        function show(obj)



            if~isempty(get(groot,'CurrentFigure'))
                clf(gcf);
            end
            vol=makeVolume(obj);
            show_internal(obj,3,vol,true)
        end

        function mesh(obj,freq)
            if nargin<2
                freq=0;
            else
                validateattributes(freq,{'numeric'},...
                {'nonempty','scalar','real','finite','nonnegative'},'','freq')
            end
            if~isempty(get(groot,'CurrentFigure'))
                clf(gcf);
            end
            vol=makeMesh(obj,freq);
            show_internal(obj,1,vol,true)
        end

        function out=stack(varargin)
            narginchk(1,inf)
            nargoutchk(0,1)
            for i=1:numel(varargin)
                validateattributes(varargin{i},{'em.wire.Part'},...
                {'nonempty','scalar'},i)
            end


            varargin{1}.StartPoint=[0,0,0];
            for i=2:numel(varargin)
                if isprop(varargin{i-1},'EndPoint')
                    varargin{i}.StartPoint=varargin{i-1}.EndPoint;
                else
                    varargin{i}.StartPoint=varargin{i-1}.StartPoint;
                end
            end

            if numel(varargin)==1
                p=varargin{1};
            else
                p=em.wire.partAntenna(varargin{:});
            end
            if nargout
                out=p;
            else
                show(p)
            end
        end

        function out=add(varargin)

























            narginchk(1,inf)
            nargoutchk(0,1)
            if~isempty(varargin{1})
                validateattributes(varargin{1},{'em.wire.Part'},...
                {'nonempty','scalar'},1);
            end
            for i=2:numel(varargin)
                validateattributes(varargin{i},{'em.wire.Part'},...
                {'nonempty','scalar'},i)
            end

            if numel(varargin)==1
                p=varargin{1};
            elseif isempty(varargin{1})
                if numel(varargin)==2
                    p=varargin{2};
                else
                    p=em.wire.partAntenna(varargin{2:end});
                end
            else
                p=em.wire.partAntenna(varargin{:});
            end
            if nargout
                out=p;
            else
                show(p)
            end
        end
    end

    methods(Static)
        function out=nec2ml(filename)


            gc=[];
            gs=1;
            gw=[];

            fid=fopen(filename);
            tline=fgetl(fid);
            while ischar(tline)
                if isempty(tline)
                    tline=fgetl(fid);
                    continue
                end
                switch(tline(1:2))
                case 'GC'
                    C=textscan(tline,'GC%*f%*f%f%f%f',...
                    'Delimiter',{' ',','},...
                    'MultipleDelimsAsOne',true);
                    gc(end+1,:)=[C{:}];%#ok<AGROW>
                case 'GS'
                    C=textscan(tline,'GS%*f%*f%f',...
                    'Delimiter',{' ',','},...
                    'MultipleDelimsAsOne',true);
                    gs=[C{:}];
                case 'GW'
                    C=textscan(tline,'GW%f%f%f%f%f%f%f%f%f',...
                    'Delimiter',{' ',','},...
                    'MultipleDelimsAsOne',true);
                    gw(end+1,:)=[C{:}];%#ok<AGROW>
                end
                tline=fgetl(fid);
            end
            fclose(fid);

            if gs>0
                gw(:,3:end)=gs*gw(:,3:end);
            end

            out=em.wire.partAntenna;
            j=1;
            for i=1:size(gw,1)
                w=em.wire.wire('StartPoint',gw(i,3:5),'EndPoint',gw(i,6:8));
                w.Tag=gw(i,1);
                w.Seg=gw(i,2);
                if gw(i,9)>0
                    w.WireDiameter=2*gw(i,9);
                else
                    if j>size(gc,1)
                        error('missing GC card')
                    end
                    w.WireDiameter=gc(j,2);
                    w.EndDiameter=gc(j,3);
                    j=j+1;
                end
                out.Parts(end+1)=w;
            end
...
...
...
...
...
...
...
...
...
        end
    end
end
