

classdef(Abstract)BrowserDialog<handle
    methods(Access=public,Abstract)
        addOnCloseFcn(this,onCloseFcn);
        show(this);
        hide(this);
        bIsValid=isValid(this);
        bIsVisible=isVisible(this);
        aTitle=getTitle(this);
        setTitle(this,aTitle);
        [aWindowPosition,bIsMaximized]=getWindowState(this);
        setWindowState(this,aWindowState);
    end
end
