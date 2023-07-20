classdef(ConstructOnLoad)ROIEventData<event.EventData





    properties

Mask
Label

PreviousMask
Offset

SliceIdx
SliceDirection

    end

    methods

        function data=ROIEventData(mask,val,oldmask,offset)

            data.Mask=mask;
            data.Label=val;
            data.PreviousMask=oldmask;
            data.Offset=offset;

        end

    end

end