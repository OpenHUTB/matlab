function figureModeInteractionOnExit(hFig)




    if~matlab.graphics.interaction.internal.containsAxesInMode(hFig)
        hFig.FigureModeData.restoreFigure(hFig);
        set(hFig,'UIModeEnabled','off');
        delete(findprop(hFig,'FigureModeData'));
    end
