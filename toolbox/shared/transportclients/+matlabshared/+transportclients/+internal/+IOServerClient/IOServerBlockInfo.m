classdef(Hidden)IOServerBlockInfo<event.EventData









    properties(SetAccess=private)


Data

AbsTime
    end


    methods(Hidden)
        function obj=IOServerBlockInfo(data)

            obj.Data=data;
            obj.AbsTime=datetime;
        end
    end

end

