classdef MRTMessage<handle



    properties
        message='';
        identifier='';
    end

    methods
        function this=MRTMessage(msgId)
            this.identifier=msgId;
        end
    end
end
