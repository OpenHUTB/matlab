function state=getTableState(widgetId,model)
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlgSrc=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            break;
        end
    end
    if~isempty(dlgSrc)&&isprop(dlgSrc,'tableState')
        state=dlgSrc.tableState;
    else
        state=true;
    end
end

