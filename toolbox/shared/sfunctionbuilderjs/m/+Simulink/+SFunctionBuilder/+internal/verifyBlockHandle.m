function blockHandle=verifyBlockHandle(blockHandle)






    if isstring(blockHandle)||ischar(blockHandle)
        try
            blockHandle=get_param(blockHandle,'Handle');
        catch
            errorId='Simulink:SFunctionBuilder:InvalidBlockHandle';
            error(errorId,DAStudio.message(errorId));
        end
    end

    if blockHandle==-1||~strcmp(get_param(blockHandle,'BlockType'),'S-Function')||(~strcmp(get_param(blockHandle,'MaskType'),'S-Function Builder')&&isempty(get_param(blockHandle,'WizardData')))
        errorId='Simulink:SFunctionBuilder:InvalidBlockHandle';
        error(errorId,DAStudio.message(errorId));
    end


    sfcnmodel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();
    blockIdx=sfcnmodel.findSFunctionBuilder(blockHandle);
    if isempty(blockIdx)
        Simulink.SFunctionBuilder.internal.setup(blockHandle);
    end
end
