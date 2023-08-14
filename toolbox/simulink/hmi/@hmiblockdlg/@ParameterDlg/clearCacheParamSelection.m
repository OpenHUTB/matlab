

function clearCacheParamSelection(widgetId,model)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dlgSrc.srcBlockObj='';
            dlgSrc.srcParamOrVar='';
            dlgSrc.srcElement='';
            dlgSrc.srcWksType='';
        end
    end
end