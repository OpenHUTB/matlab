classdef DeleteActor<driving.internal.scenarioApp.undoredo.Delete

    properties(Access=protected)
        WasEgoCar=false;
    end


    methods
        function this=DeleteActor(varargin)
            this@driving.internal.scenarioApp.undoredo.Delete(varargin{:});
        end


        function execute(this)
            hApp=this.Application;
            notify(hApp,'NumActorsChanging');
            oldEgo=hApp.EgoCarId;

            if~isempty(oldEgo)&&any(oldEgo==this.Index)
                this.WasEgoCar=oldEgo;
            end
            this.Specification = deleteActor(hApp,this.Index);
            notify(hApp,'NumActorsChanged');
            actorProps=hApp.ActorProperties;
            if~isempty(actorProps)&&~isstruct(actorProps)
                actorProps.SpecificationIndex=1;
                update(actorProps);
            end
            hApp.ScenarioView.CurrentSpecification=[];
        end


        function undo(this)
            hApp=this.Application;
            notify(hApp,'NumActorsChanging');
            for indx=1:numel(this.Specification)
                addActorSpecification(hApp,this.Specification(indx),this.Index(indx));
            end
            if this.WasEgoCar
                hApp.EgoCarId=this.WasEgoCar;
            elseif any(this.Index <= hApp.EgoCarId)
                hApp.EgoCarId=hApp.EgoCarId+1;
            end
            updateForNewActor(hApp,this.Specification);
            notify(hApp,'NumActorsChanged');
        end


        function str=getDescription(~)
            str=getString(message('driving:scenarioApp:DeleteActorText'));
        end

    end
end


