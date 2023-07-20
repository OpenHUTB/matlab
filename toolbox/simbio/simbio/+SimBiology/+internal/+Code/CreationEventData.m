








classdef CreationEventData<event.EventData
    properties(SetAccess=private,GetAccess=public)
uuid
    end

    properties(Access=public)
existingObject
    end

    methods(Access=public)
        function obj=CreationEventData(uuid)
            obj.uuid=uuid;
        end
    end
end