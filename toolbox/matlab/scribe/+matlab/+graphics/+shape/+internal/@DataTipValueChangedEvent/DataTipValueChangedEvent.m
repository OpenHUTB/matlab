classdef(Sealed)DataTipValueChangedEvent<event.EventData




    properties(GetAccess=public,SetAccess=private)
        PreviousPosition=[];
        NewPosition=[];
    end

    methods
        function obj=DataTipValueChangedEvent(previousPosition,newPosition)

            if nargin
                obj.PreviousPosition=previousPosition;
                obj.NewPosition=newPosition;
            end
        end
    end
end