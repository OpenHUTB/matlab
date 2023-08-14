


classdef(ConstructOnLoad)AlgorithmSetupHelperVoxelLabelEventData<event.EventData
    properties
        Data;


        UpdateUndoRedo=true;
    end

    methods
        function this=AlgorithmSetupHelperVoxelLabelEventData(data,doUpdateUndoredo)
            this.Data=data;
            if nargin==1
                this.UpdateUndoRedo=true;
            else
                this.UpdateUndoRedo=doUpdateUndoredo;
            end
        end
    end
end
