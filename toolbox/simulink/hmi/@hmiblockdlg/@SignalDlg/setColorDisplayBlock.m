function setColorDisplayBlock(color,property,widgetId,model,isSlimDialog)



    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    displayDlgSrc=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        curIsSlim=~dlgs(i).isStandAlone;
        if curIsSlim==isSlimDialog&&utils.isWidgetDialog(dlgSrc,widgetId,model)
            displayDlgSrc=dlgSrc;
            break;
        end
    end

    if~isempty(displayDlgSrc)

        if strcmpi(property,'backgroundColor')
            displayDlgSrc.BackgroundColor=color;
        end
        if strcmpi(property,'foregroundColor')
            displayDlgSrc.ForegroundColor=color;
        end
        if strcmpi(property,'gridColor')
            displayDlgSrc.GridColor=color;
            color=jsondecode(color);
        end
        if strcmpi(property,'fontColor')
            displayDlgSrc.FontColor=color;
            color=jsondecode(color);
        end
        if strcmpi(property,'PushButtonIconOnColor')
            color=jsondecode(color)';
            displayDlgSrc.IconOnColor=color;
            property='IconOnColor';
        end
        if strcmpi(property,'PushButtonIconOffColor')
            color=jsondecode(color)';
            displayDlgSrc.IconOffColor=color;
            property='IconOffColor';
        end


        if isSlimDialog
            blockHandle=get(displayDlgSrc.blockObj,'handle');
            set_param(blockHandle,property,color);
        else
            displayDlgs=displayDlgSrc.getOpenDialogs(true);
            for k=1:length(displayDlgs)
                displayDlgs{k}.enableApplyButton(true,true);
            end
        end
    end
end