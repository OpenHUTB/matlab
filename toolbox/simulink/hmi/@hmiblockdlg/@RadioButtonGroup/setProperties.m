

function setProperties(data,widgetId,model,~,isSlimDialog)


    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlgSrc=[];
    dlg=[];
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dlg=dlgs(i);
            break;
        end
    end

    if(~isempty(dlgSrc))

        switch data.action
        case 'add'
            newRow=data.newRow;
            dlgSrc.propMap(newRow.index)=newRow;
        case 'delete'
            indicesToDelete=data.indicesToDelete;
            for i=1:length(indicesToDelete)
                dlgSrc.propMap.remove(indicesToDelete(i));
            end
        case 'update'
            modifiedRow=data.modifiedRow;
            dlgSrc.propMap(modifiedRow.index)=modifiedRow;
        end

        if isSlimDialog
            utils.slimDialogUtils.coreBlockStateTableChanged(dlg,dlgSrc,'sl_hmi_RadioButtonGroupProperties');
        else
            paramDlgs=dlgSrc.getOpenDialogs(true);



            for j=1:length(paramDlgs)
                paramDlgs{j}.enableApplyButton(true,true);
            end
        end
    end
end

