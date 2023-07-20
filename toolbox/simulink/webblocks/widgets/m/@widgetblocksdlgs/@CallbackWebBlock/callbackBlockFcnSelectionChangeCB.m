function callbackBlockFcnSelectionChangeCB(dlg,obj,value)
    obj.editingFcn=value;
    dialogs=obj.getOpenDialogs(true);
    for i=1:length(dialogs)
        if~isequal(dlg,dialogs{i})
            dialogs{i}.setWidgetValue('callbackSwitch',value);
        end
        dialogs{i}.refresh;
    end
end