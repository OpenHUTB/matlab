function removeModel(this,mdlName)





    deleteElementIndex=this.findIndexForModel(mdlName);


    if~isempty(deleteElementIndex)

        delete(this.legendDataForAllModels(deleteElementIndex).legendDlg);
    end


    this.legendDataForAllModels(deleteElementIndex)=[];
end



