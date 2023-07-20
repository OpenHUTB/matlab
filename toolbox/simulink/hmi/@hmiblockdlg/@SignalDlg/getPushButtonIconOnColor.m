function iconOnColor=getPushButtonIconOnColor(widgetId,model)


    displayDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    iconOnColor=jsonencode(displayDlgSrc.IconOnColor);
end