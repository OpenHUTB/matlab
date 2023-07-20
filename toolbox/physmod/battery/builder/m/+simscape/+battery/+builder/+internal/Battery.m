classdef(AllowedSubclasses={...
    ?simscape.battery.builder.Cell,...
    ?simscape.battery.builder.Module,...
    ?simscape.battery.builder.ParallelAssembly,...
    ?simscape.battery.builder.ModuleAssembly,...
    ?simscape.battery.builder.Pack},Abstract)Battery<matlab.mixin.CustomDisplay








    properties(Access=private)


        Layout(:,:)uint16{mustBeInteger}
    end

    properties(Dependent,Hidden)


        XExtent(1,1){mustBeA(XExtent,"simscape.Value"),...
        simscape.mustBeCommensurateUnit(XExtent,"m")}


        YExtent(1,1){mustBeA(YExtent,"simscape.Value"),...
        simscape.mustBeCommensurateUnit(YExtent,"m")}


        ZExtent(1,1){mustBeA(ZExtent,"simscape.Value"),...
        simscape.mustBeCommensurateUnit(ZExtent,"m")}
    end

    methods
        function obj=Battery(varargin)
            ip=inputParser;
            ip.addParameter("OutputSignals",[]);
            ip.parse(varargin{:});
        end

        function value=get.XExtent(obj)
            axisExtentName="XData";
            value=obj.getExtent(axisExtentName);
        end
        function value=get.YExtent(obj)
            axisExtentName="YData";
            value=getExtent(obj,axisExtentName);
        end
        function value=get.ZExtent(obj)
            axisExtentName="ZData";
            value=getExtent(obj,axisExtentName);
        end

    end

    methods(Access=protected)

        function[Points,PatchDefinition]=CylindricalGeometryPatchDefinition(obj)
            Radius=value(obj.Geometry.Radius,"m");
            Height=value(obj.Geometry.Height,"m");

            [x,y,z]=cylinder(Radius,obj.Elements.Circumference);

            elementsHeight=obj.Elements.Height+1;
            meshX=repmat(x(1,:),elementsHeight,1);
            meshY=repmat(y(1,:),elementsHeight,1);
            meshZ=repmat(linspace(0,Height,elementsHeight)',1,length(z));
            SidePoints=simscape.battery.builder.internal.Points(...
            obj.Center.X+meshX,...
            obj.Center.Y+meshY,...
            obj.Center.Z+meshZ);
            clear meshX meshY meshZ
            Sidecdata=obj.Color.getCData(SidePoints);

            angles=cart2pol(x,y);
            radii=[0,Radius];
            [meshAngles,meshRadii]=meshgrid(angles,radii);
            meshHeight=Height.*ones(size(meshAngles));
            [meshX,meshY,meshZ]=pol2cart(meshAngles,meshRadii,meshHeight);
            TopPoints=simscape.battery.builder.internal.Points(...
            obj.Center.X+meshX,...
            obj.Center.Y+meshY,...
            obj.Center.Z+meshZ);
            clear meshX meshY meshZ
            Topcdata=obj.Color.getCData(TopPoints);

            meshHeight=zeros(size(meshAngles));
            [meshX,meshY,meshZ]=pol2cart(meshAngles,meshRadii,meshHeight);
            BottomPoints=simscape.battery.builder.internal.Points(...
            obj.Center.X+meshX,...
            obj.Center.Y+meshY,...
            obj.Center.Z+meshZ);
            clear meshX meshY meshZ
            Bottomcdata=obj.Color.getCData(BottomPoints);
            nans=NaN(2,1);

            X=[SidePoints.XData,nans,TopPoints.XData,nans,BottomPoints.XData];
            Y=[SidePoints.YData,nans,TopPoints.YData,nans,BottomPoints.YData];
            Z=[SidePoints.ZData,nans,TopPoints.ZData,nans,BottomPoints.ZData];
            C=[Sidecdata{:},nans,Topcdata{:},nans,Bottomcdata{:}];
            Points=simscape.battery.builder.internal.Points(X,Y,Z);
            PatchDefinition=surf2patch(X,Y,Z,C);
        end

        function[Points,PatchDefinition]=PouchGeometryPatchDefinition(obj)



            Length=value(obj.Geometry.Length,"m");
            Thickness=value(obj.Geometry.Thickness,"m");
            Height=value(obj.Geometry.Height,"m");
            TabWidth=value(obj.Geometry.TabWidth,"m");
            TabHeight=value(obj.Geometry.TabHeight,"m");
            ELength=obj.Elements.Length;
            EThickness=obj.Elements.Thickness;
            EHeight=obj.Elements.Height;

            faces=["top","bottom","left","right","back","front","posTab","negTab"];

            if strcmp(obj.StackingAxis,"X")
                [pouchSurfaces.top.X,pouchSurfaces.top.Y,pouchSurfaces.top.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),linspace(-Length/2,Length/2,ELength+1),Height*ones(ELength+1,EThickness+1));
            else
                [pouchSurfaces.top.X,pouchSurfaces.top.Y,pouchSurfaces.top.Z]=deal(linspace(-Length/2,Length/2,ELength+1),linspace(-Thickness/2,Thickness/2,EThickness+1),Height*ones(ELength+1,EThickness+1)');
            end

            if strcmp(obj.StackingAxis,"X")
                [pouchSurfaces.bottom.X,pouchSurfaces.bottom.Y,pouchSurfaces.bottom.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),linspace(-Length/2,Length/2,ELength+1),0*ones(ELength+1,EThickness+1));
            else
                [pouchSurfaces.bottom.X,pouchSurfaces.bottom.Y,pouchSurfaces.bottom.Z]=deal(linspace(-Length/2,Length/2,ELength+1),linspace(-Thickness/2,Thickness/2,EThickness+1),0*ones(ELength+1,EThickness+1)');
            end

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [pouchSurfaces.left.X,pouchSurfaces.left.Y,pouchSurfaces.left.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),(-Length/2)*ones(1,length(linspace(0,Height,EHeight+1))),flipud(z0'.*ones(EHeight+1,EThickness+1)));
            else
                [pouchSurfaces.left.X,pouchSurfaces.left.Y,pouchSurfaces.left.Z]=deal((-Length/2)*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Thickness/2,Thickness/2,EThickness+1),flipud(z0'.*ones(EHeight+1,EThickness+1))');
            end

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [pouchSurfaces.right.X,pouchSurfaces.right.Y,pouchSurfaces.right.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),Length/2*ones(1,length(linspace(0,Height,EHeight+1))),flipud(z0'.*ones(EHeight+1,EThickness+1)));
            else
                [pouchSurfaces.right.X,pouchSurfaces.right.Y,pouchSurfaces.right.Z]=deal(Length/2*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Thickness/2,Thickness/2,EThickness+1),flipud(z0'.*ones(EHeight+1,EThickness+1))');
            end
            clear z0

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [pouchSurfaces.back.X,pouchSurfaces.back.Y,pouchSurfaces.back.Z]=deal((-Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Length/2,Length/2,ELength+1),(z0'.*ones(EHeight+1,ELength+1))');
            else
                [pouchSurfaces.back.X,pouchSurfaces.back.Y,pouchSurfaces.back.Z]=deal(linspace(-Length/2,Length/2,ELength+1),(-Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),(z0'.*ones(EHeight+1,ELength+1)));
            end

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [pouchSurfaces.front.X,pouchSurfaces.front.Y,pouchSurfaces.front.Z]=deal((Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Length/2,Length/2,ELength+1),(z0'.*ones(EHeight+1,ELength+1))');
            else
                [pouchSurfaces.front.X,pouchSurfaces.front.Y,pouchSurfaces.front.Z]=deal(linspace(-Length/2,Length/2,ELength+1),(Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),(z0'.*ones(EHeight+1,ELength+1)));
            end
            if strcmp(obj.Geometry.TabLocation,"Opposed")

                z0=linspace(Height/2-TabWidth/2,Height/2+TabWidth/2,2);
                if strcmp(obj.StackingAxis,"X")
                    [pouchSurfaces.posTab.X,pouchSurfaces.posTab.Y,pouchSurfaces.posTab.Z]=deal(0*ones(1,length(linspace(0,TabHeight,2))),linspace(-Length/2-TabHeight/2,-Length/2+TabHeight/2,2),(z0'.*ones(2,2))');
                else
                    [pouchSurfaces.posTab.X,pouchSurfaces.posTab.Y,pouchSurfaces.posTab.Z]=deal(linspace(-Length/2-TabHeight/2,-Length/2+TabHeight/2,2),0*ones(1,length(linspace(0,TabHeight,2))),(z0'.*ones(2,2)));
                end

                z0=linspace(Height/2-TabWidth/2,Height/2+TabWidth/2,2);
                if strcmp(obj.StackingAxis,"X")
                    [pouchSurfaces.negTab.X,pouchSurfaces.negTab.Y,pouchSurfaces.negTab.Z]=deal(0*ones(1,length(linspace(0,TabHeight,2))),linspace(Length/2,Length/2+TabHeight/2,2),(z0'.*ones(2,2))');
                else
                    [pouchSurfaces.negTab.X,pouchSurfaces.negTab.Y,pouchSurfaces.negTab.Z]=deal(linspace(Length/2,Length/2+TabHeight/2,2),0*ones(1,length(linspace(0,TabHeight,2))),(z0'.*ones(2,2)));
                end
            elseif strcmp(obj.Geometry.TabLocation,"Standard")

                z0=linspace(Height,Height+TabHeight,2);
                if strcmp(obj.StackingAxis,"X")
                    [pouchSurfaces.posTab.X,pouchSurfaces.posTab.Y,pouchSurfaces.posTab.Z]=deal(0*ones(1,length(linspace(0,TabHeight,2))),linspace(-Length/2+Length/4-TabWidth/2,-Length/2+Length/4+TabWidth/2,2),(z0'.*ones(2,2))');
                else
                    [pouchSurfaces.posTab.X,pouchSurfaces.posTab.Y,pouchSurfaces.posTab.Z]=deal(linspace(-Length/2+Length/4-TabWidth/2,-Length/2+Length/4+TabWidth/2,2),zeros(1,length(linspace(0,TabHeight,2))),(z0'.*ones(2,2)));
                end

                z0=linspace(Height,Height+TabHeight,2);
                if strcmp(obj.StackingAxis,"X")
                    [pouchSurfaces.negTab.X,pouchSurfaces.negTab.Y,pouchSurfaces.negTab.Z]=deal(0*ones(1,length(linspace(0,TabHeight,2))),linspace(Length/2-Length/4-TabWidth/2,Length/2-Length/4+TabWidth/2,2),(z0'.*ones(2,2))');
                else
                    [pouchSurfaces.negTab.X,pouchSurfaces.negTab.Y,pouchSurfaces.negTab.Z]=deal(linspace(Length/2-Length/4-TabWidth/2,Length/2-Length/4+TabWidth/2,2),zeros(1,length(linspace(0,TabHeight,2))),(z0'.*ones(2,2)));
                end
            else
                error("Unknown tab location for pouch cell ")
            end

            for faceIdx=1:length(faces)
                thesePoints.X=obj.Center.X+pouchSurfaces.(faces{faceIdx}).X;
                thesePoints.Y=obj.Center.Y+pouchSurfaces.(faces{faceIdx}).Y;
                thesePoints.Z=obj.Center.Z+pouchSurfaces.(faces{faceIdx}).Z;
                thisPoints=simscape.battery.builder.internal.Points(thesePoints.X,thesePoints.Y,thesePoints.Z);
                cdata=obj.Color.getCData(thisPoints);
                if faceIdx==1
                    [X,Y,Z,C]=deal([],[],[],[]);
                end
                X=[X;thesePoints.X';NaN];
                Y=[Y;thesePoints.Y';NaN];
                Z=[Z;[[NaN(2,faceIdx*3-3)],thesePoints.Z,[NaN(2,(length(faces)*3-(3*faceIdx-1)))]];NaN(1,length(faces)*3)];
                C=[C;[[NaN(2,faceIdx*3-3)],cdata{:},[NaN(2,(length(faces)*3-(3*faceIdx-1)))]];NaN(1,length(faces)*3)];
            end
            Points=simscape.battery.builder.internal.Points(X,Y,Z);
            PatchDefinition=surf2patch(X,Y,Z,C);
        end

        function[Points,PatchDefinition]=PrismaticGeometryPatchDefinition(obj)



            Length=value(obj.Geometry.Length,"m");
            Thickness=value(obj.Geometry.Thickness,"m");
            Height=value(obj.Geometry.Height,"m");
            ELength=obj.Elements.Length;
            EThickness=obj.Elements.Thickness;
            EHeight=obj.Elements.Height;

            if strcmp(obj.StackingAxis,"X")
                [prismaticSurfaces.top.X,prismaticSurfaces.top.Y,prismaticSurfaces.top.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),linspace(-Length/2,Length/2,ELength+1),Height*ones(ELength+1,EThickness+1));
            else
                [prismaticSurfaces.top.X,prismaticSurfaces.top.Y,prismaticSurfaces.top.Z]=deal(linspace(-Length/2,Length/2,ELength+1),linspace(-Thickness/2,Thickness/2,EThickness+1),Height*ones(ELength+1,EThickness+1)');
            end

            if strcmp(obj.StackingAxis,"X")
                [prismaticSurfaces.bottom.X,prismaticSurfaces.bottom.Y,prismaticSurfaces.bottom.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),linspace(-Length/2,Length/2,ELength+1),zeros(ELength+1,EThickness+1));
            else
                [prismaticSurfaces.bottom.X,prismaticSurfaces.bottom.Y,prismaticSurfaces.bottom.Z]=deal(linspace(-Length/2,Length/2,ELength+1),linspace(-Thickness/2,Thickness/2,EThickness+1),zeros(ELength+1,EThickness+1)');
            end

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [prismaticSurfaces.left.X,prismaticSurfaces.left.Y,prismaticSurfaces.left.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),(-Length/2)*ones(1,length(linspace(0,Height,EHeight+1))),flipud(z0'.*ones(EHeight+1,EThickness+1)));
            else
                [prismaticSurfaces.left.X,prismaticSurfaces.left.Y,prismaticSurfaces.left.Z]=deal((-Length/2)*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Thickness/2,Thickness/2,EThickness+1),flipud(z0'.*ones(EHeight+1,EThickness+1))');
            end

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [prismaticSurfaces.right.X,prismaticSurfaces.right.Y,prismaticSurfaces.right.Z]=deal(linspace(-Thickness/2,Thickness/2,EThickness+1),Length/2*ones(1,length(linspace(0,Height,EHeight+1))),flipud(z0'.*ones(EHeight+1,EThickness+1)));
            else
                [prismaticSurfaces.right.X,prismaticSurfaces.right.Y,prismaticSurfaces.right.Z]=deal(Length/2*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Thickness/2,Thickness/2,EThickness+1),flipud(z0'.*ones(EHeight+1,EThickness+1))');
            end
            clear z0

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [prismaticSurfaces.back.X,prismaticSurfaces.back.Y,prismaticSurfaces.back.Z]=deal((-Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Length/2,Length/2,ELength+1),(z0'.*ones(EHeight+1,ELength+1))');
            else
                [prismaticSurfaces.back.X,prismaticSurfaces.back.Y,prismaticSurfaces.back.Z]=deal(linspace(-Length/2,Length/2,ELength+1),(-Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),(z0'.*ones(EHeight+1,ELength+1)));
            end

            z0=linspace(0,Height,EHeight+1);
            if strcmp(obj.StackingAxis,"X")
                [prismaticSurfaces.front.X,prismaticSurfaces.front.Y,prismaticSurfaces.front.Z]=deal((Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),linspace(-Length/2,Length/2,ELength+1),(z0'.*ones(EHeight+1,ELength+1))');
            else
                [prismaticSurfaces.front.X,prismaticSurfaces.front.Y,prismaticSurfaces.front.Z]=deal(linspace(-Length/2,Length/2,ELength+1),(Thickness/2)*ones(1,length(linspace(0,Height,EHeight+1))),(z0'.*ones(EHeight+1,ELength+1)));
            end
            faces=["top","bottom","left","right","back","front"];

            for faceIdx=1:length(faces)
                thesePoints.X=obj.Center.X+prismaticSurfaces.(faces{faceIdx}).X;
                thesePoints.Y=obj.Center.Y+prismaticSurfaces.(faces{faceIdx}).Y;
                thesePoints.Z=obj.Center.Z+prismaticSurfaces.(faces{faceIdx}).Z;
                thisPoints=simscape.battery.builder.internal.Points(thesePoints.X,thesePoints.Y,thesePoints.Z);
                cdata=obj.Color.getCData(thisPoints);
                if faceIdx==1
                    [X,Y,Z,C]=deal([],[],[],[]);
                end
                X=[X;thesePoints.X';NaN];
                Y=[Y;thesePoints.Y';NaN];
                Z=[Z;[[NaN(2,faceIdx*3-3)],thesePoints.Z,[NaN(2,(length(faces)*3-(3*faceIdx-1)))]];NaN(1,length(faces)*3)];
                C=[C;[[NaN(2,faceIdx*3-3)],cdata{:},[NaN(2,(length(faces)*3-(3*faceIdx-1)))]];NaN(1,length(faces)*3)];
            end
            Points=simscape.battery.builder.internal.Points(X,Y,Z);
            PatchDefinition=surf2patch(X,Y,Z,C);
        end

        function footer=getFooter(obj)


            objectName=inputname(1);



            if isscalar(obj)&&~isempty(objectName)
                linkStr=sprintf(...
                ['matlab: if exist( ''%s'', ''var''), ',...
                'simscape.battery.builder.internal.Battery.fullDisplay( %s ), ',...
                'end'],objectName,objectName);
                linkStr=...
                sprintf('<a href="%s">all properties</a>',linkStr);
                footer=sprintf('Show %s\n',linkStr);
            else
                footer='';
            end
        end
    end

    methods(Static,Hidden)
        function fullDisplay(o)
            details(o)
        end
    end
end
