

classdef(ConstructOnLoad)CheckReplaceOrOverlayEventData<event.EventData
    properties
NewVolType
NewVolSize
CurrVolSize
HasVolumeData
HasLabeledVolumeData
    end

    methods
        function obj=CheckReplaceOrOverlayEventData(newVolType,newVolSize,currVolSize,hasVolumeData,hasLabeledVolumeData)

            obj.NewVolType=newVolType;
            obj.NewVolSize=newVolSize;
            obj.CurrVolSize=currVolSize;
            obj.HasVolumeData=hasVolumeData;
            obj.HasLabeledVolumeData=hasLabeledVolumeData;
        end
    end
end