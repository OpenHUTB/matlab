function unbind(widgetId)


    widget=Simulink.HMI.getActiveWidget(widgetId);
    if isempty(widget)
        return;
    end
    widget.unbind();
end