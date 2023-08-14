function backgroundColor=getBackgroundColor(widgetId,model)


    backgroundColor='';
    displayDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(displayDlgSrc.BackgroundColor)
        backgroundColor=displayDlgSrc.BackgroundColor;
    end
end