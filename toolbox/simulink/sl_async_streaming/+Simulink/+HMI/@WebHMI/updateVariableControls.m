function updateVariableControls(this)





    for idx=1:length(this.WidgetIDs)
        bindingInfo=this.getBoundElement(this.WidgetIDs{idx});
        if isa(bindingInfo,'Simulink.HMI.ParamSourceInfo')&&~isempty(bindingInfo.WksType)
            widget=this.getWidget(this.WidgetIDs{idx});
            curVal=bindingInfo.getDoubleValue();
            if~isempty(widget)&&...
                ~isa(widget,'Simulink.HMI.PushButton')&&...
                curVal~=widget.Value
                widget.Value=curVal;
            end
        end
    end
end

