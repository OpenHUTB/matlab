


function refreshAnnotation(obj,codeLanguage)

    mrmgr=slci.manualreview.Manager.getInstance;
    resultView=mrmgr.getManualReview(obj.fStudio);

    data=resultView.getDialog.getCurrentData;


    if~isempty(data)
        anno=resultView.getDialog.getAnnotationData(data);


        obj.updateAnnotation(codeLanguage,anno);
    end
end