
function registerToolbarInteraction(obj,ax,canvas)





    if isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')&&~obj.isMobileToolbar()

        toolbar=obj;



        deleteInteraction=false;
        if~isempty(toolbar.Interaction)&&isvalid(toolbar.Interaction)
            deleteInteraction=~eq(toolbar.Interaction.Object,ax)||~eq(toolbar.Interaction.Canvas,canvas);
        end



        if~isempty(toolbar)&&isvalid(toolbar)&&(isempty(toolbar.Interaction)||~isvalid(toolbar.Interaction))||...
deleteInteraction

            if~isempty(toolbar.Interaction)&&isvalid(toolbar.Interaction)
                canvas.InteractionsManager.unregisterInteraction(toolbar.Interaction);
            end

            delete(toolbar.Interaction);

            toolbar.Interaction=matlab.graphics.controls.internal.AxesToolbarInteraction(canvas,ax,obj);

            if~isempty(toolbar.Interaction)
                canvas.InteractionsManager.registerInteraction(ax,toolbar.Interaction);
            end
        end

    end
end