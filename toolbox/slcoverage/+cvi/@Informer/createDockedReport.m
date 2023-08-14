function dr=createDockedReport(this,studio,covMode,hasMultipleTypes)







    contentFcn=@(modelH,covMode,selectionH,useModelAsFallback)...
    this.getCoverageDetailsContent(modelH,covMode,selectionH,useModelAsFallback);

    dr=cvi.DockedReport(studio,covMode,contentFcn,hasMultipleTypes);
    this.storeDockedReport(dr);
end