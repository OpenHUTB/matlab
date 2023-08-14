function htmlExportTraceLaunch(system)




    persistent guiHand;
    persistent quiInst;
    if~isa(guiHand,'RTW.ExportTraceGUI')
        guiHand=RTW.ExportTraceGUI;
    end
    if~isa(quiInst,'DAStudio.Dialog')
        quiInst=DAStudio.Dialog(guiHand,system,'DLG_STANDALONE');
    else
        quiInst.show;
    end

end