function prepareFigureForPrint(fig,onlyMorphLiveEditorFigures)











    if nargin<2
        onlyMorphLiveEditorFigures=false;
    end

    if onlyMorphLiveEditorFigures




        if~isLiveEditorFigure(fig)
            return
        end
    end

    try
        fig=handle(fig);
        matlab.ui.internal.prepareFigureFor(fig,mfilename('fullpath'));
    catch
    end
end

function tf=isLiveEditorFigure(fig)
    tf=isprop(fig,'LiveEditorRunTimeFigure');
end
