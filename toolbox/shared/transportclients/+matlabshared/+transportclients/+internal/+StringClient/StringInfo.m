classdef(Hidden)StringInfo<event.EventData









    properties(SetAccess=private)

Count

AbsTime
    end


    methods(Hidden)
        function obj=StringInfo(count)

            obj.Count=count;
            obj.AbsTime=datetime;
        end
    end

end

