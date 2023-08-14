function out=convertToBusPort(portPath)





    import autosar.simulink.bep.RefactorModelInterface;

    modelName=get_param(portPath,'Parent');


    [canRefactor,~,errMessage]=...
    RefactorModelInterface.canRefactorModelInterface(modelName);

    if~canRefactor
        out=errMessage;
        return;
    end

    modelMapping=autosar.api.Utils.modelMapping(modelName);

    portMappings=[modelMapping.Inports,modelMapping.Outports];
    blockMapping=portMappings.findobj('Block',portPath);


    [canRefactor,~,errMessage]=...
    RefactorModelInterface.canConvertSignalToBEPs(modelName,blockMapping);
    if~canRefactor
        out=errMessage;
        return;
    end

    RefactorModelInterface.convertPortUsingBlockMapping(modelName,blockMapping);

    out='Block converted';
