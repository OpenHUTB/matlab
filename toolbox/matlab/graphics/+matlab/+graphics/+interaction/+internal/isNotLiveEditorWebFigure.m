function ret=isNotLiveEditorWebFigure(hFig)




    ret=matlab.ui.internal.isUIFigure(hFig)&&~matlab.uitools.internal.uimode.isLiveEditorFigure(hFig);
end
