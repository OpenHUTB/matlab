function blockToReplace=revertToOriginalWithPath(variantSystemPath)





    schema=FunctionApproximation.internal.approximationblock.BlockSchema();
    blockToReplace=variantSystemPath;



    blockToReplaceWith=schema.getOriginalSource(blockToReplace);
    kSystem=new_system;
    load_system(kSystem);
    modelName=get(kSystem,'Name');
    temporaryBlock=[modelName,'/aTemporaryName'];
    add_block(blockToReplaceWith,temporaryBlock);
    FunctionApproximation.internal.Utils.replaceBlockWithBlock(blockToReplace,temporaryBlock);
    close_system(modelName,0);




    delete(gcf);
end