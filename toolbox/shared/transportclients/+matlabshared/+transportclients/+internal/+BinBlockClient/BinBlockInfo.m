classdef(Hidden)BinBlockInfo<event.EventData

    properties(SetAccess=private)

Data
Count
AbsTime
    end


    methods(Hidden)
        function obj=BinBlockInfo(data,count)

            obj.Data=data;
            obj.Count=count;
            obj.AbsTime=datetime;
        end
    end

end

