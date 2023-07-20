classdef(Hidden)ErrorInfo<event.EventData







    properties(SetAccess=private)

Message

ID

AbsTime
    end


    methods(Hidden)
        function obj=ErrorInfo(id,message)

            obj.ID=id;
            obj.Message=message;
            obj.AbsTime=datetime;
        end
    end
end

