classdef CutBarrier<driving.internal.scenarioApp.undoredo.DeleteBarrier

    methods
        function this=CutBarrier(hApp,hBarrier)
            index=find(hApp.BarrierSpecifications==hBarrier);
            this@driving.internal.scenarioApp.undoredo.DeleteBarrier(hApp,index);
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:CutObject',this.Specification.Name));
        end
    end
end
