




classdef(Abstract)BrowserDialog<handle
    methods(Access=public,Abstract)
        show(this);
        hide(this);
        bIsValid=isValid(this);
        bIsVisible=isVisible(this);
        position(this,aModelName);
        reposition(this,aCenterXPos,aCenterYPos);
    end
end
