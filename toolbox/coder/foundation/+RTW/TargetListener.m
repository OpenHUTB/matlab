classdef TargetListener<handle
    properties(SetAccess=public,GetAccess=public)
        ListenerID=0;
    end

    methods(Abstract)
        event(hThis,hEvent);
    end
end