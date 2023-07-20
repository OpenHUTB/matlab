classdef Warning<event.EventData





    properties
        Message='';
    end

    methods
        function this=Warning(msg)
            this.Message=msg;
        end
    end

end

