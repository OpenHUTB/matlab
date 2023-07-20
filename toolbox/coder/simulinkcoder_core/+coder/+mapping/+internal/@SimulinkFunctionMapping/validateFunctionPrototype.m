function varargout=validateFunctionPrototype(...
    model,fcnBlock,fcnPrototype,returnCImpl)






    cImpl='';

    if isempty(fcnBlock)








        varargout{1}=cImpl;
        return;
    end

    if ishandle(fcnBlock)
        fcnBlock=getfullname(fcnBlock);
    end



    [inArgs,outArgs,fcnName]=...
    coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(fcnBlock);

    [isPublic,~,~,~]=coder.mapping.internal.isPublicSimulinkFunction(fcnBlock);




    if returnCImpl



        inArgsProp=codermapping.internal.simulinkfunction.getArgumentSpecificationsFromCatalog(get_param(fcnBlock,'Handle'),true);
        outArgsProp=codermapping.internal.simulinkfunction.getArgumentSpecificationsFromCatalog(get_param(fcnBlock,'Handle'),false);
    else




        [inArgsProp,outArgsProp]=...
        coder.mapping.internal.SimulinkFunctionMapping.getArgInAndArgOutProperties(fcnBlock);
    end


    isPublicCallerInSeparateModel=codermapping.internal.simulinkfunction.suppressConfigureFunctionInterface(get_param(fcnBlock,'Handle'));

    func=coder.mapping.internal.SimulinkFunctionMapping.getParsedFunction(fcnPrototype);



    coder.mapping.internal.SimulinkFunctionMapping.validateUseOfRenaming(model,func,fcnName);





    if~strcmp(func.name,fcnName)
        coder.mapping.internal.SimulinkFunctionMapping.validateAndReturnFcnName(model,fcnName,func.name);
    end


    inOutArgs=intersect(inArgs,outArgs,'stable');
    hasInOutArgs=~isempty(inOutArgs);

    flatCodeArguments={};
    codeArguments={};
    for argIdx=1:length(func.arguments)
        arg=func.arguments{argIdx};

        codeArgName=arg.name;
        if~isempty(arg.mappedFrom)
            designArgName=arg.mappedFrom{1};
        else
            designArgName=codeArgName;
        end

        if(hasInOutArgs&&...
            ~isempty(find(strcmp(designArgName,inOutArgs),1)))
            inOut='inout';
        elseif~isempty(find(strcmp(designArgName,outArgs),1))
            inOut='out';
        else
            inOut='in';
        end

        flattenedArg=coder.mapping.internal.SimulinkFunctionMapping.validateAndReturnArgName(...
        model,designArgName,codeArgName,inOut);

        flatCodeArguments=[flatCodeArguments,{flattenedArg}];%#ok<AGROW>
        codeArguments=[codeArguments,{codeArgName}];%#ok<AGROW>
    end





    if~isempty(codeArguments)
        hasMangleSymbol=cellfun(@(x)contains(x,'$M'),...
        codeArguments);
        flatCodeArguments(hasMangleSymbol)=[];
    end

    if length(flatCodeArguments)>length(unique(flatCodeArguments))
        DAStudio.error('coderdictionary:api:UniqueCodeArguments');
    end


    cImpl=RTW.CImplementation;
    flattenedStr=slInternal('getIdentifierUsingNamingService',...
    model,func.name,fcnName);
    cImpl.Name=flattenedStr;
    cImpl.Return=[];


    if~isempty(func.returnArguments)
        if length(func.returnArguments)~=1
            DAStudio.error('RTW:codeGen:MultipleReturnArgs',fcnPrototype);
        end

        retArgName=func.returnArguments{1}.name;
        if~isempty(func.returnArguments{1}.mappedFrom)


            DAStudio.error('coderdictionary:api:CannotRenameReturnArgument',retArgName);
        end

        portIdx=find(strcmp(retArgName,outArgs),1);
        if isempty(portIdx)
            DAStudio.error('RTW:codeGen:ReturnArgumentNotFound',...
            retArgName,fcnPrototype);
        end

        if~isempty(find(strcmp(retArgName,inArgs),1))

            DAStudio.error('RTW:codeGen:InputArgsAsReturn',...
            retArgName,fcnPrototype);
        end

        if~isequal(func.returnArguments{1}.qualifier,...
            coder.parser.Qualifier.None)



            DAStudio.error('RTW:codeGen:ReturnArgumentQualifier',...
            retArgName);
        end


        if~isPublicCallerInSeparateModel


            retArgProp=outArgsProp(arrayfun(@(x)isequal(x.Name,...
            retArgName),outArgsProp));


            if retArgProp.IsComplex
                DAStudio.error('RTW:codeGen:ReturnArgumentComplex',...
                retArgName);
            end


            if~coder.mapping.internal.SimulinkFunctionMapping.canArgBePassedByValue(retArgProp)
                DAStudio.error('RTW:codeGen:ReturnArgumentNonScalar',...
                retArgName);
            end
        end




        tmpRet=RTW.Argument;
        tmpRet.IOType='RTW_IO_OUTPUT';
        tmpRet.Name=[num2str(portIdx),':',retArgName];
        cImpl.Return=tmpRet;
    end

    slFcnArgs=[inArgs,outArgs];
    fcnProtoArgs=cell(1,length(func.arguments)+...
    length(func.returnArguments));
    for inArgIdx=1:length(func.arguments)
        fcnProtoArgs{inArgIdx}=func.arguments{inArgIdx}.name;
        if~isempty(func.arguments{inArgIdx}.mappedFrom)
            fcnProtoArgs{inArgIdx}=func.arguments{inArgIdx}.mappedFrom{1};
        end
    end
    if~isempty(func.returnArguments)
        fcnProtoArgs{end}=func.returnArguments{1}.name;
        if~isempty(func.returnArguments{1}.mappedFrom)
            fcnProtoArgs{end}=func.returnArguments{1}.mappedFrom{1};
        end
    end

    argsNotInProto=setdiff(slFcnArgs,fcnProtoArgs);
    if~isempty(argsNotInProto)
        DAStudio.error('RTW:codeGen:UnderspecifiedArguments',...
        fcnPrototype,fcnBlock);
    end



    allArgs=RTW.Argument.empty(length(func.arguments),0);
    for ii=1:length(func.arguments)
        supportVoidPointerArg=false;
        argName=func.arguments{ii}.name;
        if~isempty(func.arguments{ii}.mappedFrom)
            argName=func.arguments{ii}.mappedFrom{1};
        end

        tmpArg=RTW.Argument;
        tmpArg.Name=argName;

        if(~isempty(find(ismember(inArgs,argName),1))&&...
            isempty(find(ismember(outArgs,argName),1)))
            tmpArg.IOType='RTW_IO_INPUT';
            supportVoidPointerArg=...
            coder.mapping.internal.SimulinkFunctionMapping.isaSupportedVoidPtrArg(...
            func.arguments{ii},'RTW_IO_INPUT');

            if isequal(func.arguments{ii}.passBy,...
                coder.parser.PassByEnum.Value)



                if~isequal(func.arguments{ii}.qualifier,...
                    coder.parser.Qualifier.None)

                    DAStudio.error('RTW:codeGen:InputArgumentScalarQualifier',...
                    argName);
                end

                inpArgProp=inArgsProp(arrayfun(@(x)isequal(x.Name,argName),inArgsProp));
                if isPublic&&coder.mapping.internal.SimulinkFunctionMapping.canArgBePassedByValue(inpArgProp)





                    scalarType=embedded.numerictype;
                    scalarType.ReadOnly=1;
                    tmpArg.Type=scalarType;
                end
            else


                if~isequal(func.arguments{ii}.qualifier,...
                    coder.parser.Qualifier.Const)





                    DAStudio.error('RTW:codeGen:InputArgumentNonScalarConstQualifier',...
                    argName);
                end

                if~supportVoidPointerArg





                    pointerType=embedded.pointertype;
                    pointerType.BaseType=embedded.numerictype;
                    pointerType.BaseType.ReadOnly=1;

                    tmpArg.Type=pointerType;
                end
            end

        elseif~isempty(find(ismember(inArgs,argName),1))
            tmpArg.IOType='RTW_IO_INPUT_OUTPUT';
            if~isequal(func.arguments{ii}.qualifier,...
                coder.parser.Qualifier.None)
                DAStudio.error('RTW:codeGen:OutOrInOutArgumentQualifier',...
                argName);
            end
        elseif~isempty(find(ismember(outArgs,argName),1))
            tmpArg.IOType='RTW_IO_OUTPUT';
            supportVoidPointerArg=...
            coder.mapping.internal.SimulinkFunctionMapping.isaSupportedVoidPtrArg(...
            func.arguments{ii},'RTW_IO_OUTPUT');
            if~isequal(func.arguments{ii}.qualifier,...
                coder.parser.Qualifier.None)
                DAStudio.error('RTW:codeGen:OutOrInOutArgumentQualifier',...
                argName);
            end
        else

            DAStudio.error('RTW:codeGen:ArgumentNotFound',...
            argName,fcnPrototype);
        end


        if(supportVoidPointerArg)
            tmpArg.Type=embedded.pointertype;
            tmpArg.Type.BaseType=embedded.voidtype;
            if(isequal(func.arguments{ii}.qualifier,coder.parser.Qualifier.Const))
                tmpArg.Type.BaseType.ReadOnly=true;
            end
        end

        allArgs(ii)=tmpArg;
    end
    cImpl.Arguments=allArgs;
    if returnCImpl
        varargout{1}=cImpl;
    end
end
