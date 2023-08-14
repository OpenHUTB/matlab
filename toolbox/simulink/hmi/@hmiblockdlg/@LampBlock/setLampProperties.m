

function setLampProperties(lampProperties,widgetId,model,isLibWidget,isSlimDialog)


    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlg=[];
    lampDlgSrc=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            lampDlgSrc=dlgSrc;
            dlg=dlgs(i);
            break;
        end
    end

    if(~isempty(lampDlgSrc))



        switch lampProperties.action
        case 1

            lampDlgSrc.States{length(lampDlgSrc.States)+1}=lampProperties.States;
            lampDlgSrc.StateColors=[lampDlgSrc.StateColors;...
            lampProperties.StateColors.'];
        case 2

            indexesToDelete=lampProperties.PropIndexes;
            lampDlgSrc.States(indexesToDelete)=[];

            lampDlgSrc.StateColors(indexesToDelete,:)=[];
        case 3

            lampDlgSrc.States{lampProperties.PropIndex}=lampProperties.States;
        case 4

            lampDlgSrc.StateColors(lampProperties.PropIndex,:)=lampProperties.StateColors.';
            lampDlgSrc.ApplyColorChange=true;
        case 5

            lampDlgSrc.DefaultColor=lampProperties.DefaultColor;
            lampDlgSrc.ApplyColorChange=true;
        case 6

            lampDlgSrc.Icon=lampProperties.Icon;
            lampDlgSrc.ApplyCustom=false;
        case 7

            if~(lampProperties.CustomIcon=="Invalid")
                lampDlgSrc.CustomIcon=lampProperties.CustomIcon;
            end
            lampDlgSrc.ApplyCustom=true;
            if~strlength(lampProperties.CustomIcon)
                lampDlgSrc.Icon='Default';
            else
                lampDlgSrc.Icon='Custom';
            end
        case 8

            if~(lampProperties.CustomIcon=="Invalid")
                lampDlgSrc.CustomIcon=lampProperties.CustomIcon;
            end
            lampDlgSrc.ApplyCustom=true;
            lampDlgSrc.InitialCustom=true;
            lampDlgSrc.DisableApplyColorSlimDialog=true;
        case 9

            if~(lampProperties.CustomIcon=="Invalid")
                lampDlgSrc.CustomIcon=lampProperties.CustomIcon;
            end
            lampDlgSrc.ApplyCustom=true;
            if~strlength(lampProperties.CustomIcon)
                lampDlgSrc.Icon='Default';
            else
                lampDlgSrc.Icon='Custom';
            end
            lampDlgSrc.DisableApplyColorSlimDialog=true;
        end

        if isSlimDialog
            if~lampDlgSrc.DisableApplyColorSlimDialog

                utils.slimDialogUtils.lampColorsChanged(...
                dlg,lampDlgSrc,'lamp_properties_browser');
            else
                lampDlgSrc.DisableApplyColorSlimDialog=false;
            end


            if~isa(lampDlgSrc.getBlock(),'Simulink.CustomWebBlock')
                block=get(lampDlgSrc.getBlock(),'Handle');
                if~isfield(lampProperties,'CustomIcon')
                    set_param(block,'Icon',lampProperties.Icon);
                else
                    if(~lampDlgSrc.InitialCustom)
                        if~strlength(lampProperties.CustomIcon)
                            set_param(block,'Icon','Default');
                        else
                            set_param(block,'Icon','Custom');
                        end
                    else
                        lampDlgSrc.InitialCustom=false;
                    end
                    set_param(block,'CustomIcon',lampProperties.CustomIcon);
                end
            end
        else
            lampDlgs=lampDlgSrc.getOpenDialogs(true);
            for k=1:length(lampDlgs)
                if~isfield(lampProperties,'CustomIcon')
                    lampDlgs{k}.enableApplyButton(true,true);
                else

                    if~(lampProperties.CustomIcon=="Invalid")
                        lampDlgs{k}.enableApplyButton(true,true);
                    else
                        lampDlgs{k}.enableApplyButton(false,false);
                    end
                end
            end
        end
    end

end
