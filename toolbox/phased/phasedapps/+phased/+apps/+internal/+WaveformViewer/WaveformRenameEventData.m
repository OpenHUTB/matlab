classdef WaveformRenameEventData<event.EventData



    properties
scenIndex
scenNewName
scenPreviousName
    end

    methods
        function this=WaveformRenameEventData(indx,newName,previousName)
            this.scenIndex=indx;
            this.scenNewName=newName;
            this.scenPreviousName=previousName;
        end
    end
end