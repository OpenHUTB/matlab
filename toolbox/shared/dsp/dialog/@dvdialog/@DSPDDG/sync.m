function sync(this,dialog,tag)



    tr=DAStudio.ToolRoot;
    od=tr.getOpenDialogs;
    for i=1:length(od)
        if isequal(this,od(i).getDialogSource)&&~isequal(dialog,od(i))
            od(i).setWidgetValue(tag,dialog.getWidgetValue(tag));
        end
    end
