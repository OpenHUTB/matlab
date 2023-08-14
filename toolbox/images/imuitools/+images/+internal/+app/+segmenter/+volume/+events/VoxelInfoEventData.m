classdef(ConstructOnLoad)VoxelInfoEventData<event.EventData





    properties

Location
Value

    end

    methods

        function data=VoxelInfoEventData(loc,val)

            data.Location=loc;
            data.Value=val;

        end

    end

end