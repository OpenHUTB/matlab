function algorithmDescriptor(obj)



    blkType='AlgorithmDescriptor';

    if isR2018bOrEarlier(obj.ver)

        algDescBlks=slexportprevious.utils.findBlockType(obj.modelName,blkType);

        delete_block(algDescBlks);
    end

end
