function editCommand(configname,elementname)
    model=dig.config.Model.getOrCreate(configname);
    action=model.findAction(elementname);
    if~isempty(action)
        action.editCommand();
    else
        widget=model.findWidget(elementname);
        if~isempty(widget)&&isa(widget,'dig.config.CommandControl')&&~isempty(widget.ActionReference)
            dig.config.editCommand(configname,widget.ActionReference);
        else



            throw(MException(message('dig:config:resources:NoSuchElement','Action',elementname)));
        end
    end
end