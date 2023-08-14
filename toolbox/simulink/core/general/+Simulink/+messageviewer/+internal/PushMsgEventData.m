classdef PushMsgEventData<event.EventData


    methods

        function obj=PushMsgEventData(aMsgObject)
            obj.m_MsgObject=aMsgObject;
        end

    end

    properties
m_MsgObject
    end
end
