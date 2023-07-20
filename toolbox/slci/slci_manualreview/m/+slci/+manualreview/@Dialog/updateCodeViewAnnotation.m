


function updateCodeViewAnnotation(obj,codeLanguage,data)

    anno=obj.getAnnotationData(data);


    mrmgr=slci.manualreview.Manager.getInstance;
    codeView=mrmgr.getCodeView(obj.fStudio);
    codeView.updateAnnotation(codeLanguage,anno);

end


