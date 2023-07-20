function[out,msg]=apply(obj,~)







    drawnow;
    dlg=obj.Dlg;

    [out,msg]=obj.preApplyCallback(dlg);
    if~out
        return;
    end

    hasUnappliedChanges=obj.hasUnappliedChanges;


    obj.callback(true);

    msg='';
    adp=obj.Source;
    lock=configset.internal.util.getConfigSetAdapterLockGuard(adp.Source);


    if~obj.errorMap.isempty



        out=false;
        errs=obj.errorMap.values;
        err=errs{1};
        configset.internal.util.buildErrorDialog(...
        struct('data',err.data,'dialog',obj.Dlg,'error',err.error),...
        err.me);
        return;
    end

    csc=adp.Source;


    configset.internal.util.dialogCustomAction(csc.getDialogController,csc,dlg,'apply');

    try

        cs=csc.getConfigSetSource;
        cs.assignFrom(csc,true,'ApplyCache');
        obj.enableApplyButton(false);


        obj.clearDirty;
        obj.clearHighlights;

        [out,msg]=configset.internal.util.postApply(csc,dlg);

        if out==true


            if hasUnappliedChanges&&isa(cs,'Simulink.ConfigSet')
                [out,msg]=configset.internal.util.applyChangeToDD(cs);
            end
        end

    catch ME
        out=false;
        msg=ME.message;
    end

