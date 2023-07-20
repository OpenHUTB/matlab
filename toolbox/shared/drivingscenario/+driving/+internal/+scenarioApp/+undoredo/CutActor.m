classdef CutActor<driving.internal.scenarioApp.undoredo.DeleteActor

    methods
        function this=CutActor(hApp,hActor)
            [~,index,~]=intersect(hApp.ActorSpecifications,hActor);
            this@driving.internal.scenarioApp.undoredo.DeleteActor(hApp,index);
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:CutObject',[this.Specification.Name]));
        end
    end
end
