classdef LinkSetEventData<event.EventData


    properties
Artifact
    end

    methods
        function this=LinkSetEventData(dataLinkSet)
            this.Artifact=dataLinkSet.artifact;
        end
    end

end

