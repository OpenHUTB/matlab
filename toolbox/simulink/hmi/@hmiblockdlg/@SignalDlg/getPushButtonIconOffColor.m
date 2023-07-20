function iconOffColor=getPushButtonIconOffColor(widgetId,model)


    displayDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    iconOffColor=jsonencode(displayDlgSrc.IconOffColor);
end