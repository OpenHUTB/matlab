


function onRowSelected(obj,codeLanguage,codeline)


    mrmgr=slci.manualreview.Manager.getInstance;
    codeview=mrmgr.getCodeView(obj.fStudio);
    codeview.hiliteAnnotation(codeLanguage,codeline);

end