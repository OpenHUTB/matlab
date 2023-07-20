function[codeInArgs,codeOutArgs]=getCodeInputOutputArguments(blk,fcnPrototype)









    [inArgs,outArgs,~]=...
    coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(blk);


    inOutArgs=intersect(inArgs,outArgs,'stable');
    hasInOutArgs=~isempty(inOutArgs);


    func=coder.mapping.internal.SimulinkFunctionMapping.getParsedFunction(fcnPrototype);


    argMap=containers.Map;
    for i=1:length(func.arguments)
        arg=func.arguments{i};
        codeName=arg.name;
        if~isempty(arg.mappedFrom)
            designName=arg.mappedFrom{1};
        else
            designName=codeName;
        end
        inoutArgStr='';
        if(hasInOutArgs&&...
            ~isempty(find(strcmp(designName,inOutArgs),1)))
            inoutArgStr=':1';
        end
        argMap(designName)=[codeName,inoutArgStr];
    end

    if~isempty(func.returnArguments)
        codeName=func.returnArguments{1}.name;
        if~isempty(func.returnArguments{1}.mappedFrom)
            designName=func.returnArguments{1}.mappedFrom{1};
        else
            designName=codeName;
        end
        inoutArgStr='';
        if(hasInOutArgs&&...
            ~isempty(find(strcmp(designName,inOutArgs),1)))
            inoutArgStr=':1';
        end
        argMap(designName)=[codeName,inoutArgStr];
    end



    codeInArgs=cellfun(@(x)strcat(x,':',argMap(x)),inArgs,...
    'UniformOutput',false);
    codeOutArgs=cellfun(@(x)strcat(x,':',argMap(x)),outArgs,...
    'UniformOutput',false);
end
