classdef ImplManagerClient<handle















    properties(Access=protected)
ImplManagerInstance
    end

    methods
        function obj=ImplManagerClient(implManager)
            obj.ImplManagerInstance=implManager;
            obj.ImplManagerInstance.registerClient(obj,@obj.onImplSwapIn,@obj.onImplSwapOut,@obj.onClientRegistration);
            mlock;
        end
    end

    methods(Access=protected)
        function onImplSwapIn(~)

        end

        function onImplSwapOut(~)

        end

        function onClientRegistration(~)

        end
    end
end
