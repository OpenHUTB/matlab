classdef(Hidden)DataWrittenInfo<event.EventData








    properties(SetAccess=private)


SpaceAvailable

AbsTime
    end


    methods(Hidden)
        function obj=DataWrittenInfo(spaceAvailable)

            obj.SpaceAvailable=spaceAvailable;
            obj.AbsTime=datetime;
        end
    end

end

