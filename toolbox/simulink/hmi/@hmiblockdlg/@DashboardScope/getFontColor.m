

function fontColor=getFontColor(widgetId,model)
    fontColor='';
    dashboardScopeDlgSrc=[];

    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dashboardScopeDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(dashboardScopeDlgSrc.FontColor)
        fontColor=dashboardScopeDlgSrc.FontColor;
    end
end