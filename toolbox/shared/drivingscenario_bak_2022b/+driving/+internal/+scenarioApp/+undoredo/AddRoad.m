classdef AddRoad<driving.internal.scenarioApp.undoredo.Add

    properties(SetAccess=protected)
        OldSim3dScene;
    end
    methods
        function this=AddRoad(varargin)
            this@driving.internal.scenarioApp.undoredo.Add(varargin{:});
            this.OldSim3dScene=this.Application.Sim3dScene;
        end

        function execute(this)
            hApp=this.Application;
            notify(hApp,'NumRoadsChanging');
            roadCreationStarting(hApp);
            addRoad(hApp,this.Inputs{:});
            hApp.Sim3dScene='';
            roadCreationFinished(hApp);
            notify(hApp,'NumRoadsChanged');
        end

        function undo(this)



            hApp=this.Application;
            notify(hApp,'NumRoadsChanging');
            this.Specification=deleteRoad(hApp,numel(hApp.RoadSpecifications));
            hApp.Sim3dScene=this.OldSim3dScene;
            notify(hApp,'NumRoadsChanged');
        end




        function redo(this)
            hApp=this.Application;
            notify(hApp,'NumRoadsChanging');
            roadCreationStarting(hApp);
            addRoadSpecification(hApp,this.Specification);
            hApp.Sim3dScene='';
            updateForNewRoad(hApp,this.Specification);
            roadCreationFinished(hApp);
            notify(hApp,'NumRoadsChanged');
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:AddRoadLabel'));
        end
    end
end


