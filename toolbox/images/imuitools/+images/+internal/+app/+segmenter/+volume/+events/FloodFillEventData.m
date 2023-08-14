classdef(ConstructOnLoad)FloodFillEventData<event.EventData





    properties

Mask
Label
Superpixels
Sensitivity

SliceIdx
SliceDirection

    end

    methods

        function data=FloodFillEventData(mask,val,L,tol)

            data.Mask=mask;
            data.Label=val;
            data.Superpixels=L;
            data.Sensitivity=tol;

        end

    end

end