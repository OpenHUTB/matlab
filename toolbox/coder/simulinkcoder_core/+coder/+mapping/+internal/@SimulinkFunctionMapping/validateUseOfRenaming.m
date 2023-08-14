function validateUseOfRenaming(model,func,fcnName)




    import coder.mapping.internal.SimulinkFunctionMapping.*;
    fcnBlock=getSimulinkFunctionOrCallerBlock(...
    model,fcnName);
    if isempty(fcnBlock)

        return;
    end
    if~isPublicFcn(fcnBlock,fcnName)
        return;
    end
    if~strcmp(func.name,fcnName)
        DAStudio.error('coderdictionary:api:RenamingWithPublicFunction',fcnName);
    end
    args=func.arguments;
    for i=1:length(args)
        currentArg=args{i};
        if~isempty(currentArg.mappedFrom)&&...
            ~isequal(currentArg.mappedFrom{1},currentArg.name)
            DAStudio.error('coderdictionary:api:RenamingWithPublicFunction',fcnName);
        end
    end
end
