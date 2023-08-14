function anyBlockDialogOpen=anyBlockDialogOpenForModel(modelHandle)
    anyBlockDialogOpen=false;
    allDialogs=DAStudio.ToolRoot.getOpenDialogs;
    for dialogIdx=1:length(allDialogs)
        dialogSrc=allDialogs(dialogIdx).getDialogSource;
        if isa(dialogSrc,"Simulink.SLDialogSource")
            dlgModelHandle=bdroot(dialogSrc.get_param("Handle"));
            if dlgModelHandle==modelHandle
                dialogMode=allDialogs(dialogIdx).dialogMode;
                if~strcmp(dialogMode,"Slim")
                    anyBlockDialogOpen=true;
                    break;
                end
            end
        end
    end
end