function updateWebScopeViewerTitle(sourceElementHandle)






    viewerCOSI=get_param(sourceElementHandle,'BlockCOSI');
    if~isempty(viewerCOSI)&&~isempty(viewerCOSI.ClientID)
        hWebWindow=viewerCOSI.WebWindow;
        isObjectValid=isa(hWebWindow,'matlab.internal.webwindow')&&isvalid(hWebWindow);
        if isObjectValid
            name=Simulink.scopes.SLWebScopeUtils.updateViewerTitle(sourceElementHandle);
            hWebWindow.Title=name;
        end
    end

end