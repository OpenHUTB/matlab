classdef(ConstructOnLoad)PriorMaskEventData<event.EventData





    properties

Mask
HoleMask
ParentMask

SliceIdx
SliceDirection

    end

    methods

        function data=PriorMaskEventData(mask,holeMask,parentMask)

            data.Mask=mask;
            data.HoleMask=holeMask;
            data.ParentMask=parentMask;

        end

    end

end