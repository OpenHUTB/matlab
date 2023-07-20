classdef AddBarrier<driving.internal.scenarioApp.undoredo.Add

    methods
        function this=AddBarrier(varargin)
            this@driving.internal.scenarioApp.undoredo.Add(varargin{:});
        end

        function execute(this)
            hApp=this.Application;
            notify(hApp,'NumBarriersChanging');
            addBarrier(hApp,this.Inputs{:});
            notify(hApp,'NumBarriersChanged');
        end

        function undo(this)

            hApp=this.Application;
            notify(hApp,'NumBarriersChanging');
            this.Specification=deleteBarrier(hApp,numel(hApp.BarrierSpecifications));
            notify(hApp,'NumBarriersChanged');
        end




        function redo(this)
            hApp=this.Application;
            notify(hApp,'NumBarriersChanging');
            addBarrierSpecification(hApp,this.Specification);
            updateForNewBarrier(hApp,this.Specification);
            notify(hApp,'NumBarriersChanged');
        end

        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:AddBarrierText_16'));
        end
    end
end


