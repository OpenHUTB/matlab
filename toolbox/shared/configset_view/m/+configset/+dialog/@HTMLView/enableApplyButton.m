function enableApplyButton(obj,enable)








    obj.publish('enableApply',enable);
    obj.hasUnappliedChanges=enable;

    dlg=obj.Dlg;
    if isa(dlg,'DAStudio.Dialog')
        dlg.enableApplyButton(enable);
        if enable


            if isobject(obj.Source.Source)

            else
                source=obj.Source.Source.getConfigSetSource;
                configset.internal.util.callParentDialog(source.getDialogController,'enableApplyButton',enable);
            end
        end
    end
