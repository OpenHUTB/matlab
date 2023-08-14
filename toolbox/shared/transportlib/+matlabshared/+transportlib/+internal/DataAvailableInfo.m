classdef(Hidden)DataAvailableInfo<event.EventData








    properties(SetAccess=private)

Count

AbsTime
    end


    methods(Hidden)
        function obj=DataAvailableInfo(count)

            obj.Count=count;
            obj.AbsTime=datetime;
        end
    end

end

