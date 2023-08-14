function dlgSrc=getDlgSrcObj(hThis)







    dlgSrc=0;
    daRoot=DAStudio.ToolRoot;
    openDlgs=daRoot.getOpenDialogs;

    for idx=1:length(openDlgs)
        if(isa(openDlgs(idx).getDialogSource(),'Simulink.SLDialogSource')&&...
            openDlgs(idx).getDialogSource().getBlock().Handle==pmsl_getdoublehandle(hThis.BlockHandle))
            dlgSrc=openDlgs(idx).getDialogSource();
            return;
        end
    end

    error([class(hThis),':getDlgSrcObj'],'Failed to find a matching DialogSource object.');
