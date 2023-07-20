


classdef(ConstructOnLoad)VoxelLabelEventData<event.EventData
    properties
        Data;


        UpdateUndoRedo=true;
    end

    methods
        function this=VoxelLabelEventData(data,doUpdateUndoredo)
            this.Data=data;
            if nargin==1
                this.UpdateUndoRedo=true;
            else
                this.UpdateUndoRedo=doUpdateUndoredo;
            end
        end
    end
end
