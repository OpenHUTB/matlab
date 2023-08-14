classdef PasteBarrier<driving.internal.scenarioApp.undoredo.Edit
    properties(SetAccess=protected)
Barrier
    end

    methods
        function this=PasteBarrier(app,barrier)
            this.Application=app;
            this.Barrier=barrier;
        end

        function execute(this)


            app=this.Application;
            barrier=this.Barrier;

            if~isempty(barrier.Road)
                barrier.Road=[];
                barrier.RoadEdge=[];
            end
            addBarrierSpecification(app,barrier);
            updateForNewBarrier(app,barrier);
        end

        function undo(this)
            app=this.Application;
            barrier=this.Barrier;
            index=find(app.BarrierSpecifications==barrier);
            deleteBarrier(app,index);
        end

        function str=getDescription(this)
            str=getString(message('Spcuilib:application:PasteObject',this.Barrier.Name));
        end
    end
end


