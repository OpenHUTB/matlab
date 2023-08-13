classdef SyntheticMouseEvent<handle


    properties
HitObject
Point
HitPrimitive
Source
EventName
    end

    methods
        function this=SyntheticMouseEvent(fig,ax,pos,eventName)
            this.HitObject=ax;
            this.Point=pos;
            this.HitPrimitive=[];
            this.Source=fig;
            this.EventName=eventName;
        end
    end
end