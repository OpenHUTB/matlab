






function res=webGraphicsStateManager
    import matlab.internal.lang.capability.Capability;
    res=[];
    currentFigure=get(groot,'CurrentFigure');
    isRemoteClientThatMirrorsSwingUIs=~Capability.isSupported(Capability.LocalClient)&&Capability.isSupported(Capability.Swing);
    if~feature('LiveEditorRunning')...
        &&isRemoteClientThatMirrorsSwingUIs
        if isempty(currentFigure)
            mls.internal.feature('webGraphics','off');
            res=onCleanup(@()mls.internal.feature('webGraphics','on'));
        else
            matlab.ui.internal.prepareFigureFor(currentFigure,mfilename('fullpath'));
        end
    end
end

