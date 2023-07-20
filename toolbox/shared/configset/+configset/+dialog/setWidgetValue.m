function setWidgetValue(dlg,tag,val,dirty)



    dlg.setWidgetValue(tag,val);
    if~dirty
        dlg.clearWidgetDirtyFlag(tag);
    end


