
classdef(ConstructOnLoad)ImageRotateEvent<event.EventData
    properties

Index

RotationType
    end

    methods
        function this=ImageRotateEvent(idx,rotType)
            this.Index=idx;
            this.RotationType=rotType;
        end
    end
end