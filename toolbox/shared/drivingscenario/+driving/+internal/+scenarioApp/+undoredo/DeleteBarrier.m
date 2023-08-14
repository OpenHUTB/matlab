classdef DeleteBarrier<driving.internal.scenarioApp.undoredo.Delete




    methods
        function this=DeleteBarrier(varargin)
            this@driving.internal.scenarioApp.undoredo.Delete(varargin{:});
        end

        function execute(this)
            hApp=this.Application;
            notify(hApp,'NumBarriersChanging');
            this.Specification=deleteBarrier(hApp,this.Index);
            notify(hApp,'NumBarriersChanged');
        end

        function undo(this)
            hApp=this.Application;
            notify(hApp,'NumBarriersChanging');
            addBarrierSpecification(hApp,this.Specification,this.Index);
            updateForNewBarrier(hApp,this.Specification);
            notify(hApp,'NumBarriersChanged');
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:DeleteBarrierText'));
        end
    end
end


