classdef(ConstructOnLoad)InitailizeDisplayEventData<event.EventData




    properties

DataLimits
NumSlicesASC
PixelSpacingASC
IsRGB

    end

    methods

        function data=InitailizeDisplayEventData(dataLimits,numSlices,pixelSpacing,isRGB)

            data.DataLimits=dataLimits;
            data.NumSlicesASC=numSlices;
            data.PixelSpacingASC=pixelSpacing;
            data.IsRGB=isRGB;

        end

    end

end