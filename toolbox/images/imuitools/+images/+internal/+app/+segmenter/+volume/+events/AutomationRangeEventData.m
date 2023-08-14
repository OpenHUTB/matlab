classdef(ConstructOnLoad)AutomationRangeEventData<event.EventData





    properties

Start
End

    end

    methods

        function data=AutomationRangeEventData(startVal,endVal)

            data.Start=startVal;
            data.End=endVal;

        end

    end

end