classdef DataTipProvider<handle







    properties(Access=private)
Tip
    end
    methods
        function obj=get(hObj)
            obj=hObj.Tip;
        end

        function set(hObj,hTip)
            hObj.Tip=hTip;
        end

        function deleteTip(hObj)
            if~isempty(hObj.Tip)
                delete(hObj.Tip);
                hObj.Tip=matlab.graphics.shape.internal.PointDataTip.empty;
            end
        end
    end
end

