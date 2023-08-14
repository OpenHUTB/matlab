function doShowNewInspector=shouldShowNewInspector(varargin)












    doShowNewInspector=true;


    hInspectorMgnr=matlab.graphics.internal.propertyinspector.PropertyInspectorManager.getInstance();
    if hInspectorMgnr.IsUnSupportedPlatform
        doShowNewInspector=false;
    end