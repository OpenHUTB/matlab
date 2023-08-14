function modelCloseOperation(this,block,operation_id)





    if~this.isLibraryBlock(block)




        if this.blockIsTriggeringModelOperation(block)

            mdl=getBlockModel(block);




            SSC.SimscapeCC.clearCachedConfigSet(mdl.Name);




            this.setBlockCheckedModelOperation(block,operation_id);

        end

    end

end

