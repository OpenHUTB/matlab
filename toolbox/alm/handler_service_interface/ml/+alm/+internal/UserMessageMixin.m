classdef UserMessageMixin<matlab.mixin.SetGet&handle




    properties(Hidden)
        UserMessageProvider;
    end

    methods
        function notifyUser(h,type,message)
            h.UserMessageProvider.notifyUser(type,message);
        end
    end
end
