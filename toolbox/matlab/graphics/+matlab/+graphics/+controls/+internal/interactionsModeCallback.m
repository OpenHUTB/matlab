function interactionsModeCallback(buttonType,~,d)









    if(isprop(d,'Axes')||isfield(d,'Axes'))&&~isempty(d.Axes)
        ax=d.Axes;


        if~isscalar(d.Axes)
            ax=d.Axes(1);
        end

        fig=ancestor(ax,'figure','node');
    elseif(isprop(d,'Source')||isfield(d,'Source'))&&~isempty(d.Source)
        fig=ancestor(d.Source,'figure','node');
    end



    if~isempty(fig)&&(~isprop(fig,'UseLegacyExplorationModes')||~fig.UseLegacyExplorationModes)&&...
        isa(fig.getCanvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
        isWebFigure=true;
    else
        isWebFigure=false;
    end

    if isWebFigure


        for i=1:numel(d.Axes)
            ax=d.Axes(i);
            matlab.graphics.interaction.webmodes.toggleMode(ax,buttonType,d.Value);
        end
    else
        if strcmp(buttonType,'zoomout')
            matlab.graphics.controls.internal.zoominout(ancestor(d.Source,'figure'),d.Value,char(matlab.graphics.controls.internal.ToolbarValidator.zoomout));
        elseif strcmp(buttonType,'zoom')
            matlab.graphics.controls.internal.zoominout(ancestor(d.Source,'figure'),d.Value,char(matlab.graphics.controls.internal.ToolbarValidator.zoomin));
        elseif strcmp(buttonType,'rotate')
            rotate3d(ancestor(d.Source,'figure'),d.Value,'-orbit');
        elseif strcmp(buttonType,'pan')
            matlab.graphics.controls.internal.setPanMode(ancestor(d.Source,'figure'),d.Value);
        end
    end
end

