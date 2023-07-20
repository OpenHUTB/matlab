function[portNameVec,methodNameVec,numInArgs,numOutArgs,numInOutArgs,...
    isFireAndForget,isClient,slFcnName,inOutAndOutArgOrderBitSet,...
    comErrArgNames,timeoutErrArgNames,outputArgNames]=...
    getMethodInfoFromAdaptiveDict(modelH)






















    mappedBlockPaths=find_system(get_param(modelH,'Name'),...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'IsComposite','on','IsClientServer','on');
    portNameVec=get_param(mappedBlockPaths,'PortName');
    elementNames=get_param(mappedBlockPaths,'Element');
    slFcnName=cell(length(mappedBlockPaths),1);
    isClient=cell(length(mappedBlockPaths),1);
    methodNameVec=cell(length(mappedBlockPaths),1);
    componentAdapter=autosar.ui.wizard.builder.ComponentAdapter.getComponentAdapter(modelH);
    for ii=1:length(mappedBlockPaths)

        elementNames{ii}=...
        autosar.simulink.functionPorts.Utils.escapeBrackets(elementNames{ii});
        if strcmp(get_param(mappedBlockPaths{ii},'BlockType'),'Inport')
            slFcnName{ii}=[portNameVec{ii},'.',elementNames{ii}];
        else
            slFcnName{ii}=elementNames{ii};
        end
        methodNameVec{ii}=componentAdapter.getAutosarMethodName(slFcnName{ii});
        isClient{ii}=strcmp(get_param(mappedBlockPaths{ii},'BlockType'),'Inport');
    end

    m3iComp=autosar.api.Utils.m3iMappedComponent(modelH);


    numInArgs=num2cell(int32(zeros(1,length(methodNameVec))));
    numOutArgs=num2cell(int32(zeros(1,length(methodNameVec))));
    numInOutArgs=num2cell(int32(zeros(1,length(methodNameVec))));
    isFireAndForget=cell(1,length(methodNameVec));
    inOutAndOutArgOrderBitSet=num2cell(uint32(zeros(1,length(methodNameVec))));
    comErrArgNames=cell(1,length(methodNameVec));
    comErrArgNames(:)={''};
    timeoutErrArgNames=cell(1,length(methodNameVec));
    timeoutErrArgNames(:)={''};
    outputArgNames=cell(1,length(methodNameVec));
    outputArgNames(:)={''};
    delim='::';

    for methodIdx=1:length(methodNameVec)
        m3iPort=autosar.mm.Model.findChildByName(m3iComp,portNameVec{methodIdx});
        if isempty(m3iPort)


            continue;
        end

        m3iInterface=m3iPort.Interface;

        m3iMethod=autosar.mm.Model.findElementInSequenceByName(...
        m3iInterface.Methods,methodNameVec{methodIdx});

        assert(~isempty(m3iMethod),'Expected to find method');

        inOutAndOutArgOrderIdx=1;
        argOrder=uint32(zeros);
        outArgIdx=1;
        numArguments=m3iMethod.Arguments.size();
        argNames=cell(1,numArguments);
        argNames(:)={''};

        for argIdx=1:numArguments
            curArg=m3iMethod.Arguments.at(argIdx);

            switch curArg.Direction
            case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.In
                numInArgs{methodIdx}=numInArgs{methodIdx}+1;
            case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Out
                numOutArgs{methodIdx}=numOutArgs{methodIdx}+1;
                inOutAndOutArgOrderIdx=inOutAndOutArgOrderIdx+1;
                argNames{outArgIdx}=curArg.Name;
                outArgIdx=outArgIdx+1;
            case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.InOut
                numInOutArgs{methodIdx}=numInOutArgs{methodIdx}+1;
                argOrder=bitset(argOrder,inOutAndOutArgOrderIdx);
                inOutAndOutArgOrderIdx=inOutAndOutArgOrderIdx+1;
                argNames{outArgIdx}=curArg.Name;
                outArgIdx=outArgIdx+1;
            case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.CommunicationError
                assert(isempty(comErrArgNames{methodIdx}),'Expected max 1 ComError');
                comErrArgNames{methodIdx}=curArg.Name;
            case Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.TimeoutError
                assert(isempty(timeoutErrArgNames{methodIdx}),'Expected max 1 TimeoutError');
                timeoutErrArgNames{methodIdx}=curArg.Name;
            otherwise
                assert(false,'Did not expect to get here');
            end
        end
        inOutAndOutArgOrderBitSet{methodIdx}=argOrder;
        isFireAndForget{methodIdx}=m3iMethod.FireAndForget;
        outputArgNames{methodIdx}=strjoin(argNames,delim);
        outputArgNames{methodIdx}=strip(outputArgNames{methodIdx},'right',':');
    end
end


