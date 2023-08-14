classdef LastWarningGuard<handle


    properties
WarningMessage
WarningId
    end

    methods
        function obj=LastWarningGuard()
            [obj.WarningMessage,obj.WarningId]=lastwarn;
        end

        function delete(obj)
            lastwarn(obj.WarningMessage,obj.WarningId);
        end
    end
end

