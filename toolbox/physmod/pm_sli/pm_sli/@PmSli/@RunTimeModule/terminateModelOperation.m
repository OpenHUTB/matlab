function terminateModelOperation(this,block,operation_id)











    if~this.isLibraryBlock(block)

        mdl=getBlockModel(block);










        if this.blockIsTriggeringModelOperation(block)





            SSC.SimscapeCC.postSave_restoreProducts(mdl);








            this.validateLibraryLinks(mdl);





            this.setBlockCheckedModelOperation(block,operation_id);

        end

    end



