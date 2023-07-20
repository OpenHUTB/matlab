classdef DeleteRoad<driving.internal.scenarioApp.undoredo.Delete

    properties(SetAccess=protected)
        OldSim3dScene;
    end

    methods
        function this=DeleteRoad(varargin)
            this@driving.internal.scenarioApp.undoredo.Delete(varargin{:});
            this.OldSim3dScene=this.Application.Sim3dScene;
        end

        function execute(this)
            app=this.Application;
            notify(app,'NumRoadsChanging');
            this.Specification=deleteRoad(app,this.Index);
            app.Sim3dScene='';
            notify(app,'NumRoadsChanged');
        end

        function undo(this)
            app=this.Application;
            notify(app,'NumRoadsChanging');
            addRoadSpecification(app,this.Specification,this.Index);
            app.Sim3dScene=this.OldSim3dScene;
            updateForNewRoad(app,this.Specification);
            notify(app,'NumRoadsChanged');
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:DeleteRoadText'));
        end
    end
end


