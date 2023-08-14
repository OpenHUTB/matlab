function setProperties(data,widgetId,model,isLibWidget,isSlimDialog)

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    dlgSrc=[];
    dlg=[];
    for idx=1:length(dlgs)
        dlgSrc=dlgs(idx).getSource;
        slimDialog=strcmpi(dlgs(idx).dialogMode,'Slim');
        if utils.isWidgetDialog(dlgSrc,widgetId,model)&&isequal(slimDialog,isSlimDialog)
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
            customwebblocks.utils.statesChanged(dlg,dlgSrc,widgetId,model,'sl_hmi_DiscretKnobProperties');
        else
            paramDlgs=dlgSrc.getOpenDialogs(true);
            for idx=1:length(paramDlgs)
                paramDlgs{idx}.enableApplyButton(true,true);
            end
        end
    end
end

