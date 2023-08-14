function close(obj,~,action)







    obj.isWebPageReady=true;

    dlg=obj.Dlg;


    adp=obj.Source;
    src=adp.Source;
    if~isa(src,'Simulink.BaseConfig')&&~isa(src,'qe.BaseConfig')
        return;
    end

    controller=src.getDialogController;
    configset.internal.util.closePopupDialog(dlg,controller,'');
    configset.internal.util.dialogCustomAction(controller,src,dlg,action);


    controller.usingToolchainApproach=-1;

    cs=src.getConfigSetSource;
    if action=="cancel"


        configset.internal.util.callParentDialog(cs.getDialogController,'revert');
    elseif action=="ok"

        configset.internal.util.callParentDialog(cs.getDialogController,'enableApplyButton',false);
    end


    csc=obj.Source.Source;
    if isobject(csc)


        cs.closeDialog;
    elseif isa(csc,'Simulink.ConfigSetRoot')&&strcmp(csc.IsDialogCache,'on')
        cs.destroyDialogCache();
    end


    if isa(dlg,'DAStudio.Dialog')
        try
            cs.ConfigPrmDlgPosition=dlg.position;
        catch
        end
    end


