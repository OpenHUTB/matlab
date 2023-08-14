function previewStr=getFunctionPreview(model,fcnName)




    prototypeStruct=coder.mapping.internal.SimulinkFunctionMapping.get(model,fcnName);
    func=coder.mapping.internal.SimulinkFunctionMapping.getParsedFunction(prototypeStruct.CodePrototype);


    if~isempty(func.returnArguments)

        returnStr=[func.returnArguments{1}.name,' = '];
    else
        returnStr='void ';
    end

    fcnBlock=coder.mapping.internal.SimulinkFunctionMapping.getSimulinkFunctionOrCallerBlock(...
    model,fcnName);
    isPubFcn=coder.mapping.internal.SimulinkFunctionMapping.isPublicFcn(...
    fcnBlock,fcnName);
    supportArgRenaming=~isPubFcn;
    supportFcnNameRenaming=~isPubFcn;


    if supportFcnNameRenaming
        fcnNameStr=coder.mapping.internal.SimulinkFunctionMapping.validateAndReturnFcnName(...
        model,fcnName,func.name);
    else
        fcnNameStr=coder.mapping.internal.SimulinkFunctionMapping.getFcnName(...
        fcnBlock,func.name,fcnName);
    end


    argStr='';
    comma='';
    [~,isMulti,isDefinedInMdlref,details]=...
    coder.mapping.internal.isPublicSimulinkFunction(fcnBlock);
    isCppClassGen=strcmp(get_param(model,'CodeInterfacePackaging'),'C++ class');
    if isMulti&&~isCppClassGen
        if isDefinedInMdlref
            multiInstanceIdentifier=getMultiInstanceIdentifier();
        else
            if isequal(details,{'TopBuild','MdlRefBuild'})||...
                isequal(details,{'TopBuild','ZeroMdlRef'})


                multiInstanceIdentifier=coder.mapping.internal.SimulinkFunctionMapping.getMultiInstanceIdentifier();
            else


                multiInstanceIdentifier=coder.mapping.internal.SimulinkFunctionMapping.getOptionalMultiInstanceIdentifier();
            end
        end
        comma=', ';
    else
        multiInstanceIdentifier='';
    end
    [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
    if strcmp(mappingType,'CoderDictionary')
        deploymentType=mapping.DeploymentType;
        isComponent=strcmp(deploymentType,'Component');
        isSubcomponent=strcmp(deploymentType,'Subcomponent');
        if isComponent
            if strcmp(get_param(model,'CodeInterfacePackaging'),'Reusable function')
                multiInstanceIdentifier=coder.mapping.internal.SimulinkFunctionMapping.getMultiInstanceIdentifier();
            else
                multiInstanceIdentifier='';
            end
        elseif(isSubcomponent)
            if strcmp(get_param(model,'ModelReferenceNumInstancesAllowed'),'Multi')
                multiInstanceIdentifier=coder.mapping.internal.SimulinkFunctionMapping.getMultiInstanceIdentifier();
            else
                multiInstanceIdentifier='';
            end
        end
    end

    supportMultiInstance=slfeature('SimulinkFunctionMultiInstance')&&isMulti;
    if supportMultiInstance
        argStr=[argStr,multiInstanceIdentifier];
    end

    [ins,outs,~]=coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(fcnBlock);

    inOuts=intersect(ins,outs);
    ins=setdiff(ins,inOuts);
    outs=setdiff(outs,inOuts);

    for argIdx=1:length(func.arguments)
        arg=func.arguments{argIdx};
        if strcmp(arg.qualifier,'None')
            isConst=false;
        else
            isConst=true;
        end
        if~strcmp(arg.passBy,'Value')
            isPointer=true;
        else
            isPointer=false;
        end
        if isConst&&isPointer
            qualifier='const * ';
        elseif isConst&&~isPointer
            qualifier='const ';
        elseif~isConst&&isPointer
            qualifier='* ';
        else
            qualifier='';
        end
        if isempty(argStr)
            argStr=qualifier;
        else
            argStr=[argStr,comma,qualifier];%#ok<AGROW>
        end

        if supportArgRenaming
            argSymbol=arg.name;
        else
            argSymbol=get_param(model,'CustomSymbolStrFcnArg');
        end

        if isempty(arg.mappedFrom)
            argName=arg.name;
        else
            if iscell(arg.mappedFrom)
                argName=arg.mappedFrom{1};
            else
                argName=arg.mappedFrom;
            end
        end

        if any(strcmp(argName,ins))
            argInOut='in';
        elseif any(strcmp(argName,outs))
            argInOut='out';
        else
            argInOut='inout';
        end

        argNameStr=coder.mapping.internal.SimulinkFunctionMapping.validateAndReturnArgName(...
        model,argName,argSymbol,argInOut);



        if length(argSymbol)>1&&strcmp(argSymbol(1:2),'$M')
            argNameStr=['$M',argNameStr];%#ok<AGROW>
        end
        argStr=[argStr,argNameStr];%#ok<AGROW>

        comma=', ';
    end

    previewStr=[returnStr,fcnNameStr,'(',argStr,')'];
end
