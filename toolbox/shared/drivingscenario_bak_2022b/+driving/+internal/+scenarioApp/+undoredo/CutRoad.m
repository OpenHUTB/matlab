classdef CutRoad<driving.internal.scenarioApp.undoredo.DeleteRoad

    methods
        function this=CutRoad(hApp,hActor)
            index=find(hApp.RoadSpecifications==hActor);
            this@driving.internal.scenarioApp.undoredo.DeleteRoad(hApp,index);
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:CutObject',this.Specification.Name));
        end
    end
end
