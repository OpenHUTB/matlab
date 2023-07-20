function disableAllWebAxesModes(hFig)





    axes=findall(hFig,'Type','Axes');
    for n=1:numel(axes)
        ax=axes(n);
        if(~strcmp(ax.InteractionContainer.CurrentMode,'none'))
            matlab.graphics.interaction.webmodes.toggleMode(ax,ax.InteractionContainer.CurrentMode,'off');
        end
    end