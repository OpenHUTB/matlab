function callParentDialog(controller,action,varargin)


    dlg=controller.ParentDialog;
    if~isempty(dlg)
        switch action
        case 'enableApplyButton'
            dlg.enableApplyButton(varargin{:});
        case 'revert'

            if dlg.hasUnappliedChanges
                imd=DAStudio.imDialog.getIMWidgets(dlg);
                imd.clickRevert(dlg);
            end
        end
    end
