classdef DataRate<handle











    methods(Access=protected)
        function rate=getInputDataRateImpl(~,~)
            rate=1;
        end
        function rate=getOutputDataRateImpl(~,~)
            rate=1;
        end
    end
end
