classdef EgoCentricView<driving.internal.scenarioApp.BaseView




    properties(SetAccess=protected,Hidden)
EgoCarIdListener
AxesContextMenu
ShowActorMeshesMenu
        RoadsDrawn=false;
    end

    properties
        ShowActorMeshes(1,1)logical=false
    end

    methods

        function this=EgoCentricView(varargin)

            this@driving.internal.scenarioApp.BaseView(varargin{:});
            enableLegacyExplorationModes(this.Figure);
            this.Axes.Toolbar=axtoolbar(this.Axes);

            this.EgoCarIdListener=addPropertyListener(this.Application,'EgoCarId',@this.onEgoCarIdChanged);
            this.AxesContextMenu=uicontextmenu('Parent',this.Figure,'Callback',@this.onAxesContextMenu);
            set(this.Figure,'UIContextMenu',this.AxesContextMenu);
            contribute(this.Application.Toolstrip,this,'DisplayProperties','EgoCentricView',{'ShowActorMeshes'},'EgoView');
        end

        function updateActor(this,varargin)
            app=this.Application;
            if this.RoadsDrawn&&~(isempty(app.ActorSpecifications)||isempty(app.EgoCarId))
                updateActor@driving.internal.scenarioApp.BaseView(this,varargin{:});
            else
                update(this);
            end
        end

        function update(this)
            app=this.Application;
            setCheckBoxProperty(app.Toolstrip,'ShowActorMeshes',this.ShowActorMeshes);
            if isempty(app.ActorSpecifications)||isempty(app.EgoCarId)
                deleteScene(this);
                deleteActors(this);
                this.RoadsDrawn=false;
                return;
            end
            this.RoadsDrawn=true;
            update@driving.internal.scenarioApp.BaseView(this);
            roadZ=[this.RoadBoundaries.ZData];
            if isempty(roadZ)
                set(this.Axes,'ZLimMode','Auto')
            else
                minZ=min(roadZ(:));
                maxZ=max(roadZ(:));

                set(this.Axes,'ZLim',100*[minZ/100-1,1+maxZ/100]);
            end

            set(this.RoadPatches,'UIContextMenu',this.AxesContextMenu);
            set(this.ActorPatches,'UIContextMenu',this.AxesContextMenu);
        end

        function name=getName(~)
            name=getString(message('driving:scenarioApp:EgoCentricViewTitle'));
        end

        function tag=getTag(~)
            tag='EgoCentricView';
        end

        function set.ShowActorMeshes(this,newVal)
            this.ShowActorMeshes=newVal;
            setCheckBoxProperty(this.Application.Toolstrip,'ShowActorMeshes',newVal,'EgoView');
            update(this);
        end
    end

    methods(Access=protected)

        function onEgoCarIdChanged(this,~,~)

            updateActor(this);
        end

        function opts=getPlotActorsOptions(this)
            app=this.Application;
            scenario=app.Scenario;
            egoId=app.EgoCarId;
            if egoId>numel(scenario.Actors)
                egoId=[];
            end
            ego=scenario.Actors(egoId);
            if isempty(ego)
                opts=struct(...
                'FullPaint',false,...
                'AxesOrientation',app.AxesOrientation,...
                'EgoActor',[]);
            else
                if this.ShowActorMeshes
                    showMeshes='on';
                else
                    showMeshes='off';
                end
                opts=struct(...
                'FullPaint',false,...
                'AxesOrientation',app.AxesOrientation,...
                'EgoActor',ego,...
                'Meshes',showMeshes,...
                'ViewHeight',3/2*ego.Height,...
                'ViewLocation',[-5/2*ego.Length,0],...
                'ViewRoll',0,...
                'ViewPitch',0,...
                'ViewYaw',0);
            end
        end

        function f=createFigure(this)
            f=createFigure@driving.internal.scenarioApp.BaseView(this);
            this.Axes.Visible='off';
        end

        function onAxesContextMenu(this,h,~)
            happ=this.Application;
            if happ.IsLoading
                return;
            end
            showActorMeshes=findobj(h,'Tag','ShowActorMeshes');
            if isempty(showActorMeshes)
                this.ShowActorMeshesMenu=uimenu(h,...
                'Tag','ShowActorMeshes',...
                'Label',getString(message('driving:scenarioApp:ShowActorMeshesLabel')),...
                'Callback',@this.toggleCallback);
                drawnow;
            end
            this.ShowActorMeshesMenu.Checked=this.ShowActorMeshes;
        end

        function toggleCallback(this,h,~)
            prop=h.Tag;
            this.(prop)=~this.(prop);
            update(this);
        end

        function windowMotionCallback(varargin)

        end
    end
end


