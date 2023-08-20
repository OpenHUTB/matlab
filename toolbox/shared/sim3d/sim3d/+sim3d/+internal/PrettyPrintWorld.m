classdef PrettyPrintWorld<handle

    properties
        XAxisLimits=[-10,10];
        YAxisLimits=[-10,10];
        ZAxisLimits=[-10,10];
        World=[];
    end


    properties
        EdgeColor=[0.4,0.4,0.4];
        EdgeAlpha=[0.7];
        FaceAlpha=[0.7];
    end


    properties
        UIAxes=[];
        UIFigure=[];
    end


    methods

        function self=PrettyPrintWorld(World,xaxisL,yaxisL,zaxisL)
            if nargin>1
                self.XAxisLimits=xaxisL;
                self.YAxisLimits=yaxisL;
                self.XAxisLimits=zaxisL;
            end
            self.World=World;
        end


        function createFigure(self,xaxisL,yaxisL,zaxisL)
            if nargin>1
                self.ZAxisLimits=zaxisL;
                self.YAxisLimits=yaxisL;
                self.XAxisLimits=xaxisL;
            end
            self.UIFigure=figure('Name','PrettyPrintWorld');
            self.UIAxes=axes(self.UIFigure);
            xlim(self.UIAxes,self.XAxisLimits);
            ylim(self.UIAxes,self.YAxisLimits);
            zlim(self.UIAxes,self.ZAxisLimits);
            view(self.UIAxes,3);
            hold(self.UIAxes,'on');
            set(self.UIAxes,'color','white');
            set(self.UIFigure,'color','white');
        end


        function draw(self,tickTime)
            if isempty(self.UIFigure)
                self.createFigure();
            end

            cla(self.UIAxes);
            if(nargin>1)
                text(self.XAxisLimits(2)-2,self.YAxisLimits(1)+2,self.ZAxisLimits(2)-1,['tick: ',num2str(tickTime)]);
            end

            world=self.World;
            actorNames=fieldnames(world.Actors);
            for n=1:length(actorNames)
                actor=world.Actors.(actorNames{n});
                if isa(actor,'sim3d.Actor')||isa(actor,'MockUnrealActor')
                    uiActor=self.createUI4GenericActor(actor);
                elseif isa(actor,'sim3d.sensors.AbstractCameraSensor')
                    uiActor=self.createUI4SensorActor(actor);
                else
                    uiActor=self.createUI4ClassicActor(actor);
                end
                uiActor.ActorName=actor.getTag();
                self.drawUIActor(uiActor);
            end

        end


        function uiActor=createUI4GenericActor(self,actor)
            actorXYZ=double(actor.Translation());
            actorScale=double(actor.Scale());
            xVertices=actor.Vertices(:,1)*actorScale(1)+actorXYZ(1);
            yVertices=actor.Vertices(:,2)*actorScale(2)+actorXYZ(2);
            zVertices=actor.Vertices(:,3)*actorScale(3)+actorXYZ(3);
            if~isempty(actor.VertexColors)
                [uiActor.ColorIndex,uiActor.ColorMap]=cmunique(1:size(actor.VertexColors,1),actor.VertexColors);
            end
            uiActor.FaceColor=actor.Color;
            uiActor.EdgeColor=self.EdgeColor;
            uiActor.FaceAlpha=self.FaceAlpha;
            warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
            uiActor.dt=delaunayTriangulation(xVertices,yVertices,zVertices);

        end


        function uiActor=createUI4ClassicActor(self,actor)
            [Vcube,~,~,~,~]=sim3d.utils.Geometry.box();
            actorXYZ=double(actor.Translation());
            actorScale=double(actor.Scale());
            xVertices=Vcube(:,1)*actorScale(1)+actorXYZ(1);
            yVertices=Vcube(:,2)*actorScale(2)+actorXYZ(2);
            zVertices=Vcube(:,3)*actorScale(3)+actorXYZ(3);

            uiActor.FaceColor='red';
            uiActor.EdgeColor=self.EdgeColor;
            uiActor.FaceAlpha=self.FaceAlpha;
            warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
            uiActor.dt=delaunayTriangulation(xVertices,yVertices,zVertices);
        end


        function uiActor=createUI4SensorActor(self,actor)
            [Vsphere,~,~,~,~]=sim3d.utils.Geometry.box([0.5,0.5,0.5]);
            actorXYZ=double(actor.Translation());
            xVertices=Vsphere(:,1)+actorXYZ(1);
            yVertices=Vsphere(:,2)+actorXYZ(2);
            zVertices=Vsphere(:,3)+actorXYZ(3);

            uiActor.FaceColor='green';
            uiActor.EdgeColor=self.EdgeColor;
            uiActor.FaceAlpha=0.7;
            warning('off','MATLAB:delaunayTriangulation:DupPtsWarnId');
            uiActor.dt=delaunayTriangulation(xVertices,yVertices,zVertices);
        end


        function drawUIActor(self,uiActor)
            hold on;
            if(~isempty(uiActor.dt)&&size(uiActor.dt,1)~=0)
                if(isfield(uiActor,'ColorIndex')&&isfield(uiActor,'ColorMap'))
                    colormap(uiActor.ColorMap);
                    dh=tetramesh(uiActor.dt,'FaceColor',uiActor.FaceColor,'EdgeColor',uiActor.EdgeColor,'FaceAlpha',uiActor.FaceAlpha);
                else
                    dh=tetramesh(uiActor.dt,'FaceColor',uiActor.FaceColor,'EdgeColor',uiActor.EdgeColor,'FaceAlpha',uiActor.FaceAlpha);
                end
            end
        end

    end


end