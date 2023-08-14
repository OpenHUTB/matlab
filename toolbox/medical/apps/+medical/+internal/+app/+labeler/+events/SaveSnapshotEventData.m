classdef(ConstructOnLoad)SaveSnapshotEventData<event.EventData




    properties

Filename
SliceIdx
SliceDirection


Snapshot3D

    end

    methods

        function data=SaveSnapshotEventData(filename,sliceIdx,sliceDir)

            data.Filename=filename;
            data.SliceIdx=sliceIdx;
            data.SliceDirection=sliceDir;

        end

    end

end