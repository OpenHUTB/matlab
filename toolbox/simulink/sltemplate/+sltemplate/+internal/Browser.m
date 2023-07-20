classdef(Abstract)Browser<handle






    methods(Access=public,Abstract)
        show(obj)
        hide(obj)
        close(obj)
        isValid=validateBrowser(obj)
        visible=isVisible(obj)
    end

end
