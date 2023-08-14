function gridColor=getGridColor(widgetId,model)


    gridColor='';
    displayDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(displayDlgSrc.GridColor)
        gridColor=displayDlgSrc.GridColor;
    end
end