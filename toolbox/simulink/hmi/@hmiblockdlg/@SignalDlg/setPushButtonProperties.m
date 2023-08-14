

function setPushButtonProperties(pushButtonProperties,widgetId,model,isLibWidget,isSlimDialog)


    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlg=[];
    pushButtonDlgSrc=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            pushButtonDlgSrc=dlgSrc;
            dlg=dlgs(i);
            break;
        end
    end

    if(~isempty(pushButtonDlgSrc))



        switch pushButtonProperties.action
        case 'UpdateIcon'

            pushButtonDlgSrc.Icon=pushButtonProperties.Icon;
            pushButtonDlgSrc.ApplyCustom=false;
        case 'UpdateCustomIcon'

            if~(pushButtonProperties.CustomIcon=="Invalid")
                pushButtonDlgSrc.CustomIcon=pushButtonProperties.CustomIcon;
            end
            pushButtonDlgSrc.ApplyCustom=true;
            if~strlength(pushButtonProperties.CustomIcon)
                pushButtonDlgSrc.Icon='None';
            else
                pushButtonDlgSrc.Icon='Custom';
            end
        case 'InitializeCustomIcon'

            if~(pushButtonProperties.CustomIcon=="Invalid")
                pushButtonDlgSrc.CustomIcon=pushButtonProperties.CustomIcon;
            end
            pushButtonDlgSrc.ApplyCustom=true;
            pushButtonDlgSrc.InitialCustom=true;
        end

        if isSlimDialog
            block=get(pushButtonDlgSrc.getBlock(),'Handle');
            if~isfield(pushButtonProperties,'CustomIcon')
                set_param(block,'Icon',pushButtonProperties.Icon);
            else
                if(~pushButtonDlgSrc.InitialCustom)
                    if~strlength(pushButtonProperties.CustomIcon)
                        set_param(block,'Icon','None');
                    else
                        set_param(block,'Icon','Custom');
                    end
                else
                    pushButtonDlgSrc.InitialCustom=false;
                end
                set_param(block,'CustomIcon',pushButtonProperties.CustomIcon);
            end
        else
            pushButtonDlgs=pushButtonDlgSrc.getOpenDialogs(true);
            for k=1:length(pushButtonDlgs)
                if~isfield(pushButtonProperties,'CustomIcon')
                    pushButtonDlgs{k}.enableApplyButton(true,true);
                else

                    if~(pushButtonProperties.CustomIcon=="Invalid")
                        pushButtonDlgs{k}.enableApplyButton(true,true);
                    else
                        pushButtonDlgs{k}.enableApplyButton(false,false);
                    end
                end
            end
        end
    end

end