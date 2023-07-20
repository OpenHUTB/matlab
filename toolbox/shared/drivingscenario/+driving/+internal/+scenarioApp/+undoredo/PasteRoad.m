classdef PasteRoad<driving.internal.scenarioApp.undoredo.Edit
    properties(SetAccess=protected)
Road
        OldSim3dScene;
    end

    methods
        function this=PasteRoad(app,Road)
            this.Application=app;
            this.Road=Road;
            this.OldSim3dScene=app.Sim3dScene;
        end

        function execute(this)


            app=this.Application;
            road=this.Road;
            addRoadSpecification(app,road);
            app.Sim3dScene='';
            updateForNewRoad(app,road);
        end

        function undo(this)
            app=this.Application;
            road=this.Road;
            index=find(app.RoadSpecifications==road);
            deleteRoad(app,index);
            app.Sim3dScene=this.OldSim3dScene;
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:PasteObject',this.Road.Name));
        end
    end
end


