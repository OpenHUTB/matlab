classdef SyntheticMouseWheelEvent<handle


    properties
VerticalScrollCount
VerticalScrollAmount
Point
Source
HitObject
        EventName='WindowScrollWheel';
    end

    methods
        function this=SyntheticMouseWheelEvent(fig,verticalScrollCount,point)
            this.VerticalScrollCount=verticalScrollCount;
            this.Point=point;
            this.Source=fig;
        end
    end
end