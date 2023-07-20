
function closeLegend(this,mdlName)


    deleteElementIndex=this.findIndexForModel(mdlName);



    this.legendDataForAllModels(deleteElementIndex).legendDlg=[];


end
