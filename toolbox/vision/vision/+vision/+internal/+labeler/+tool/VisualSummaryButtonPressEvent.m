
classdef(ConstructOnLoad)VisualSummaryButtonPressEvent<event.EventData
    properties
        IsLeftBtnPressed;
        IsCompareButton;
        IsGlobalButton;
LabelType
LabelName
SignalName
    end

    methods
        function this=VisualSummaryButtonPressEvent(isLeftBtnPressed,isCompareBtn,isGlobalButton,labelType,labelName,signalName)
            this.IsLeftBtnPressed=isLeftBtnPressed;
            this.IsCompareButton=isCompareBtn;
            this.IsGlobalButton=isGlobalButton;
            this.LabelType=labelType;
            this.LabelName=labelName;
            this.SignalName=signalName;
        end
    end
end