
classdef(ConstructOnLoad)VisualSummaryEvent<event.EventData
    properties

        CheckBoxTag;
        CheckBoxStatus;
Index
    end

    methods
        function this=VisualSummaryEvent(checkBoxTag,chkBoxStatus,index)
            this.CheckBoxTag=checkBoxTag;
            this.CheckBoxStatus=chkBoxStatus;
            this.Index=index;
        end
    end
end