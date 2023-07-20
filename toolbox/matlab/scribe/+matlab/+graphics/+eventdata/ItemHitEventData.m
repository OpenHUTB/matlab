classdef ItemHitEventData<event.EventData




    properties
        Peer;
        Region;
        SelectionType;
    end

    properties(Hidden=true)
        Item matlab.graphics.illustration.legend.LegendEntry;
    end

    methods(Hidden=true)
        function hObj=ItemHitEventData(varargin)



            if(nargin==1)
                data=varargin{1};
                hObj.Item=data.Item;
                hObj.Peer=data.Peer;
                hObj.SelectionType=data.SelectionType;
                hObj.Region=data.Region;
            end
        end
    end
end
