classdef(ConstructOnLoad)CopyPasteUpdatedEventData<event.EventData





    properties

CanCopy
CanPaste

    end

    methods

        function data=CopyPasteUpdatedEventData(canCopy,canPaste)

            data.CanCopy=canCopy;
            data.CanPaste=canPaste;

        end

    end

end