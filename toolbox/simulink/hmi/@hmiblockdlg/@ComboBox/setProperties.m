function setProperties(data,widgetId,model,~,isSlimDialog)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlgSrc=[];
    dlg=[];
    for idx=1:length(dlgs)
        dlgSrc=dlgs(idx).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dlg=dlgs(idx);
            break;
        end
    end

    if~isempty(dlgSrc)
        switch data.action
        case 'add'
            newRow=data.newRow;
            dlgSrc.propMap(newRow.index)=newRow;
        case 'delete'
            indicesToDelete=data.indicesToDelete;
            for idx=1:length(indicesToDelete)
                dlgSrc.propMap.remove(indicesToDelete(idx));
            end
        case 'update'
            modifiedRow=data.modifiedRow;
            dlgSrc.propMap(modifiedRow.index)=modifiedRow;
        end

        if isSlimDialog
            utils.slimDialogUtils.coreBlockStateTableChanged(dlg,dlgSrc,'sl_hmi_DiscretKnobProperties');
        else
            paramDlgs=dlgSrc.getOpenDialogs(true);
            for idx=1:length(paramDlgs)
                paramDlgs{idx}.enableApplyButton(true,true);
            end
        end
    end
end

