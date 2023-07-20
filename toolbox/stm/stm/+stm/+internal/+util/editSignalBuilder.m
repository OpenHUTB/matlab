function editSignalBuilder(id)



    sutID=stm.internal.getPermutationSetup(id,'systemundertest');
    modelName=stm.internal.getSystemUnderTestProperty(sutID,'name');
    hName=stm.internal.getSystemUnderTestProperty(sutID,'harnessname');
    modelToUse=stm.internal.util.resolveHarness(modelName,hName,true);

    block=getBlock(modelToUse);
    if~isempty(block.handle)
        open_system(block.handle);
    else
        error(message('stm:general:NoSigBuilderFoundInModel',modelToUse));
    end
end

function block=getBlock(modelToUse)
    block=stm.internal.blocks.SignalEditorBlock(modelToUse);
    if isempty(block.handle)
        block=stm.internal.blocks.SignalBuilderBlock(modelToUse);
    end
end
