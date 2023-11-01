classdef PasteActor<driving.internal.scenarioApp.undoredo.Edit
    properties(SetAccess=protected)
        Actor
    end

    methods
        function this=PasteActor(app,actor)
            this.Application=app;
            this.Actor=actor;
        end


        function execute(this)
            app=this.Application;
            actor=this.Actor;
            addActorSpecification(app,actor);
            updateForNewActor(app,actor);
        end


        function undo(this)
            app=this.Application;
            actor=this.Actor;
            [~,index,~]=intersect(app.ActorSpecifications,actor);
            deleteActor(app,index);
            update(app.ActorProperties);
        end


        function str=getDescription(this)
            str=getString(message('Spcuilib:application:PasteObject',[this.Actor.Name]));
        end
    end
end


