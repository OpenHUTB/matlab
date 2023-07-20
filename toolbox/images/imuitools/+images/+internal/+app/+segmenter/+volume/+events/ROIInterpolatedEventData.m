classdef(ConstructOnLoad)ROIInterpolatedEventData<event.EventData





    properties

PositionOne
PositionTwo

SliceOne
SliceTwo

Value

SliceDirection

    end

    methods

        function data=ROIInterpolatedEventData(pos1,pos2,val,slice1,slice2)

            data.PositionOne=pos1;
            data.PositionTwo=pos2;

            data.SliceOne=slice1;
            data.SliceTwo=slice2;

            data.Value=val;

        end

    end

end