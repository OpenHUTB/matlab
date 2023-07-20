function applyChanges(arg)




    cs=configset.internal.util.getConfigSet(arg);
    if configset.internal.util.hasUnappliedChanges(cs)
        dlg=cs.getDialogHandle;
        web=dlg.getDialogSource;
        web.apply;
    end
end
