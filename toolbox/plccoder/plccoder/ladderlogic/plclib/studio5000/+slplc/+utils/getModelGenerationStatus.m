function paramValue=getModelGenerationStatus(block)

    rootModel=bdroot(block);
    modelGenerationStatus=plccore.visitor.ModelEmitter.ModelGenerationStatus;

    try
        paramValue=get_param(rootModel,modelGenerationStatus);
    catch
        paramValue='none';
    end
end