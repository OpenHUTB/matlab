classdef TextInteractionContainer<matlab.graphics.interaction.interactioncontainers.InteractionContainer




    properties
        TextObject;
    end

    methods

        function this=TextInteractionContainer(t)

            this=this@matlab.graphics.interaction.interactioncontainers.InteractionContainer(t);
            this.TextObject=t;

        end

        function arr=getDefaultInteractionsArray(~)

            arr=[];
        end

        function validateInteractions(~,interactions)
            for i=1:numel(interactions)
                interaction=interactions(i);
                isValidTextInteraction=isa(interaction,...
                'matlab.graphics.interaction.interactions.EditInteraction');

                if~isValidTextInteraction
                    ME=MException(message('MATLAB:graphics:interaction:TextInteractionsProperty',class(interaction)));
                    throwAsCaller(ME);
                end
            end
        end

        function findConflicts(this,arr)
            this.findDuplicateInteractions(arr);
        end

        function updateInteractionsAfterDisablingThem(~)


        end

        function updateInteractions(this)
            interactions=this.InteractionsArray;

            if(isempty(interactions))
                return;
            end

            canvas=ancestor(this.TextObject,...
            'matlab.graphics.primitive.canvas.Canvas','node');

            if(isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas'))
                this.createWebInteractions(canvas,interactions);
            else
                this.createJavaInteractions(interactions);
            end
        end

        function createWebInteractions(this,canvas,interactions)
            interactionsList=cell(1,numel(interactions));
            for i=1:numel(interactions)
                interaction=interactions(i).createWebInteraction(this.TextObject);
                interactionsList{i}=interaction;
            end
            this.List=matlab.graphics.interaction.internal.WebInteractionsList(canvas,interactionsList);
        end

        function createJavaInteractions(this,interactions)
            interactionsList=cell(1,numel(interactions));
            for i=1:numel(interactions)
                interaction=interactions(i).createInteraction(this.TextObject);
                interactionsList{i}=interaction;
            end
            this.List=matlab.graphics.interaction.internal.InteractionsList(interactionsList);
        end

        function findDuplicateInteractions(~,array)
            b=cell(numel(array),1);
            for i=1:numel(array)
                b{i}=class(array(i));
            end

            a=unique(b);
            if(numel(a)~=numel(array))
                me=MException(message('MATLAB:graphics:interaction:DuplicateFound'));
                throwAsCaller(me);
            end
        end

    end
end

