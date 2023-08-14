

function setFontColor(color,property,widgetId,model,isSlimDialog)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dashboardScopeDlgSrc=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        curIsSlim=~dlgs(i).isStandAlone;
        if curIsSlim==isSlimDialog&&utils.isWidgetDialog(dlgSrc,widgetId,model)
            dashboardScopeDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(dashboardScopeDlgSrc)

        if strcmpi(property,'fontColor')
            dashboardScopeDlgSrc.FontColor=color;
            color=jsondecode(color);
        end


        if isSlimDialog
            blockHandle=get(dashboardScopeDlgSrc.blockObj,'handle');
            set_param(blockHandle,property,color);
        else
            dashboardScopeDlgs=dashboardScopeDlgSrc.getOpenDialogs(true);
            for k=1:length(dashboardScopeDlgs)
                dashboardScopeDlgs{k}.enableApplyButton(true,true);
            end
        end
    end
end