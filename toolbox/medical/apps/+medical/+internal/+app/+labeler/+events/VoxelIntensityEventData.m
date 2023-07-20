classdef(ConstructOnLoad)VoxelIntensityEventData<event.EventData




    properties


Index
Position
Intensity

SliceDirection

    end

    methods

        function data=VoxelIntensityEventData(pos,index,sliceDir)

            data.Position=pos;
            data.Index=index;
            data.SliceDirection=sliceDir;

        end

    end

end