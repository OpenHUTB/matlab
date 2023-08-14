function foregroundColor=getForegroundColor(widgetId,model)


    foregroundColor='';
    displayDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(displayDlgSrc.ForegroundColor)
        foregroundColor=displayDlgSrc.ForegroundColor;
    end
end