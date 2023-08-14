function fontColor=getFontColor(widgetId,model)


    fontColor='';
    displayDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(displayDlgSrc.FontColor)
        fontColor=displayDlgSrc.FontColor;
    end
end