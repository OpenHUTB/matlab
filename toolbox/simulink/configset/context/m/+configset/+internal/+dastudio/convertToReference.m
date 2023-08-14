function convertToReference(cs)




    persistent dlg

    if~configset.internal.dastudio.reuseDialog(dlg,cs)
        csme=Simulink.ConfigSetME;
        csme.node=cs;
        dlg=DAStudio.Dialog(csme,'convertToCSRef','DLG_STANDALONE');
    end
