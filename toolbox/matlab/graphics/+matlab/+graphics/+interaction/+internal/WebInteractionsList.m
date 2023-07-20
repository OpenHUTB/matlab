classdef WebInteractionsList<matlab.graphics.interaction.internal.InteractionsList





    properties
Object
Canvas
    end

    methods
        function hObj=WebInteractionsList(Canvas,interactions)
            hObj@matlab.graphics.interaction.internal.InteractionsList(interactions);
            hObj.Canvas=Canvas;
            hObj.Object=hObj.getObjects(interactions);
        end

        function delete(hObj)
            if~isempty(hObj.Canvas)&&isvalid(hObj.Canvas)
                for i=1:numel(hObj.InteractionObjects)
                    interactionObject=hObj.InteractionObjects{i};
                    hObj.Canvas.InteractionsManager.unregisterInteraction(interactionObject);
                    delete(interactionObject);
                end
            end
        end

        function objs=getObjects(~,ints)
            objs=gobjects(size(ints));
            for i=1:numel(ints)
                objs(i)=ints{i}.Object;
            end
            objs=unique(objs);
        end
    end
end

