classdef AddActor<driving.internal.scenarioApp.undoredo.Add

    methods
        function this=AddActor(varargin)
            this@driving.internal.scenarioApp.undoredo.Add(varargin{:});
        end

        function execute(this)
            hApp=this.Application;
            notify(hApp,'NumActorsChanging');
            addActor(hApp,this.Inputs{:});
            notify(hApp,'NumActorsChanged');
        end


        % 撤销加入参与者的操作（删除参与者）
        function undo(this)
            hApp = this.Application;
            notify(hApp,'NumActorsChanging');
            this.Specification = deleteActor(hApp, numel(hApp.ActorSpecifications));
            notify(hApp, 'NumActorsChanged');
        end


        function redo(this)
            hApp=this.Application;
            notify(hApp,'NumActorsChanging');
            addActorSpecification(hApp, this.Specification);
            updateForNewActor(hApp,this.Specification);
            notify(hApp,'NumActorsChanged');
        end


        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:AddActorText_16'));
        end
    end
end


