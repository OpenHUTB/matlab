classdef AdaptiveMethodsValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifyFcnPortsHaveImplementation(hModel);
            this.verifyNoPublicScopedSLFunctions(hModel);
            this.verifyFireAndForgetMapping(hModel);
            this.verifyErrorArguments(hModel);
            this.verifyTimeoutError(hModel);
            this.verifyNoErrorsOnServerSide(hModel);
        end

        function verifyPostProp(this,hModel)
            this.verifyWordSizeOnSLFcnSideIO(hModel);
            this.verifyNoNonZeroIcOnFcnCallerOutput(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyFcnPortsHaveImplementation(hModel)





            csPorts=[...
            autosar.simulink.functionPorts.Utils.findClientPorts(hModel);...
            autosar.simulink.functionPorts.Utils.findServerPorts(hModel)];
            for portIdx=1:length(csPorts)
                curPort=csPorts(portIdx);
                isCaller=strcmp(get_param(curPort,'BlockType'),'Inport');
                fcnName=[get_param(curPort,'PortName'),'.',get_param(curPort,'Element')];
                implBlockH=autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(hModel,fcnName,isCaller);
                if isempty(implBlockH)
                    autosar.validation.Validator.logError('autosarstandard:validation:FcnPortNoImplementation',...
                    getfullname(curPort));
                end
            end
        end

        function verifyWordSizeOnSLFcnSideIO(hModel)





            serverPorts=...
            autosar.simulink.functionPorts.Utils.findServerPorts(hModel);
            for portIdx=1:length(serverPorts)
                curPort=serverPorts(portIdx);
                fcnName=[get_param(curPort,'PortName'),'.'...
                ,get_param(curPort,'Element')];
                isCaller=false;
                slFcnBlock=...
                autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(...
                hModel,fcnName,isCaller);
                assert(length(slFcnBlock)==1,'Did not find Simulink Function');
                autosar.validation.AdaptiveModelingStylesValidator.verifyWordSizeSideIOForSS(...
                get_param(slFcnBlock{1},'Handle'));
            end
        end

        function verifyNoPublicScopedSLFunctions(hModel)



            findOptions=Simulink.FindOptions('SearchDepth',1);
            slFcns=Simulink.findBlocksOfType(get_param(hModel,'Handle'),...
            'SubSystem','IsSimulinkFunction','on',findOptions);

            idx=arrayfun(@(x)autosar.validation.ExportFcnValidator.isPublicScopedSimulinkFunction(x),...
            slFcns);
            slFcns=slFcns(idx);

            if~isempty(slFcns)
                slFcnBlockPaths=arrayfun(@(x)getfullname(x),...
                slFcns,'UniformOutput',false);
                autosar.validation.Validator.logError('autosarstandard:validation:adaptivePublicScopedSLFunction',...
                get_param(hModel,'Name'),...
                autosar.api.Utils.cell2str(slFcnBlockPaths));
            end
        end

        function verifyNoNonZeroIcOnFcnCallerOutput(hModel)




            mapping=autosar.api.Utils.modelMapping(hModel);
            clientPorts=mapping.ClientPorts;

            for portIdx=1:length(clientPorts)
                curPort=clientPorts(portIdx);
                fcnName=[curPort.MappedTo.Port,'.',curPort.MappedTo.Method];

                isCaller=true;
                fcnCallerBlock=...
                autosar.api.internal.MappingFinder.getBlockPathsByFunctionName(...
                hModel,fcnName,isCaller);

                fcnCBHandle=get_param(fcnCallerBlock,'PortHandles');


                for i=1:size(fcnCBHandle)
                    outports=fcnCBHandle{i}.Outport;

                    if isempty(outports)
                        continue;
                    end

                    for idx=1:size(outports)
                        label=get_param(outports(idx),'Label');
                        if~isempty(label)
                            [sigExists,sigObj,~]=autosar.utils.Workspace.objectExistsInModelScope(hModel,label);
                            if sigExists&&~isempty(sigObj.InitialValue)


                                autosar.validation.Validator.logError(...
                                'autosarstandard:validation:adaptiveNoInitValSpecOnMethodOutput',...
                                autosar.api.Utils.cell2str(fcnCallerBlock));

                            end
                        end
                    end
                end

            end
        end

        function verifyFireAndForgetMapping(hModel)




            if~slfeature('AUTOSARMethodsFireAndForgetMapping')


                return;
            end

            mapping=autosar.api.Utils.modelMapping(hModel);

            functionPorts=[mapping.ClientPorts,mapping.ServerPorts];
            for portIdx=1:length(functionPorts)
                curBlockMapping=functionPorts(portIdx);
                if strcmp(curBlockMapping.MappedTo.FireAndForget,'false')
                    continue;
                end
                [~,outArgs]=...
                autosar.simulink.functionPorts.Utils.getArgumentsFromFunctionPort(...
                hModel,curBlockMapping.Block);
                if~isempty(outArgs)
                    autosar.validation.Validator.logError(...
                    'autosarstandard:validation:invalidFireAndForgetMapping',...
                    get_param(hModel,'Name'),...
                    curBlockMapping.Block);
                end
            end
        end

        function verifyErrorArguments(hModel)


            import Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind;

            if~slfeature('AdaptiveMethodsCommErrorHandling')&&...
                ~slfeature('AdaptiveMethodsTimeoutErrorHandling')


                return;
            end
            m3iModel=autosar.api.Utils.m3iModel(hModel);
            metaClass=Simulink.metamodel.arplatform.interface.Operation.MetaClass();
            recursiveSearch=true;
            m3iMethodSeq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            metaClass,recursiveSearch);

            for methodIdx=1:m3iMethodSeq.size()
                numComErrorArgs=...
                autosar.validation.AdaptiveMethodsValidator.getNumErrArguments(...
                m3iMethodSeq.at(methodIdx),ArgumentDataDirectionKind.CommunicationError);
                if numComErrorArgs>1
                    autosar.validation.Validator.logError('autosarstandard:validation:InvalidNumberOfErrArgsOnMethod',...
                    m3iMethodSeq.at(methodIdx).Name,...
                    ArgumentDataDirectionKind.CommunicationError.toString());
                end
                numTimeoutErrorArgs=...
                autosar.validation.AdaptiveMethodsValidator.getNumErrArguments(...
                m3iMethodSeq.at(methodIdx),ArgumentDataDirectionKind.TimeoutError);
                if numTimeoutErrorArgs>1
                    autosar.validation.Validator.logError('autosarstandard:validation:InvalidNumberOfErrArgsOnMethod',...
                    m3iMethodSeq.at(methodIdx).Name,...
                    ArgumentDataDirectionKind.CommunicationError.toString());
                end
            end
        end

        function verifyTimeoutError(hModel)



            import Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind;
            if~slfeature('AdaptiveMethodsTimeoutErrorHandling')


                return;
            end
            mapping=autosar.api.Utils.modelMapping(hModel);

            for clientPort=mapping.ClientPorts
                m3iMethod=autosar.validation.AdaptiveMethodsValidator.getM3IMethodForFcnPort(clientPort.Block);
                if isempty(m3iMethod)

                    continue;
                end
                assert(length(m3iMethod)==1,'Did not find method');

                timeout=clientPort.MappedTo.Timeout;
                hasTimeoutMapping=~strcmp(timeout,'0');
                numTimeoutErrorArgs=...
                autosar.validation.AdaptiveMethodsValidator.getNumErrArguments(...
                m3iMethod,ArgumentDataDirectionKind.TimeoutError);
                if hasTimeoutMapping


                    if numTimeoutErrorArgs==0
                        autosar.validation.Validator.logError(...
                        'autosarstandard:validation:TimeoutMappingButNoTimeoutErrorArg',...
                        clientPort.Block,timeout,m3iMethod.Name);
                    end
                else


                    if numTimeoutErrorArgs>0
                        autosar.validation.Validator.logError(...
                        'autosarstandard:validation:TimeoutErrorArgButNoTimeout',...
                        clientPort.Block,m3iMethod.Name);
                    end
                end

            end
        end

        function[numErrorArgs,errArgIdx]=getNumErrArguments(m3iMethod,errorArgKind)
            m3iArgumentSeq=m3iMethod.Arguments;
            argumentDirections=m3i.mapcell(@(m3iArg)m3iArg.Direction,...
            m3iArgumentSeq);
            errArgIdx=cellfun(...
            @(direction)eq(direction,errorArgKind),...
            argumentDirections);
            numErrorArgs=sum(errArgIdx);
        end

        function verifyNoErrorsOnServerSide(hModel)



            import Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind;
            if~slfeature('AdaptiveMethodsCommErrorHandling')&&...
                ~slfeature('AdaptiveMethodsTimeoutErrorHandling')


                return;
            end
            mapping=autosar.api.Utils.modelMapping(hModel);

            for serverPort=mapping.ServerPorts
                m3iMethod=autosar.validation.AdaptiveMethodsValidator.getM3IMethodForFcnPort(serverPort.Block);
                if isempty(m3iMethod)

                    continue;
                end
                assert(length(m3iMethod)==1,'Did not find method');
                [numComErrorArgs,errArgIdx]=...
                autosar.validation.AdaptiveMethodsValidator.getNumErrArguments(...
                m3iMethod,ArgumentDataDirectionKind.CommunicationError);
                if numComErrorArgs>0
                    assert(numComErrorArgs==1,'Should be at most 1 error arg');
                    m3iArgument=m3iMethod.Arguments.at(find(errArgIdx));
                    autosar.validation.Validator.logError('autosarstandard:validation:InvalidErrArgOnServerMethod',...
                    m3iMethod.Name,serverPort.Block,m3iArgument.Name,...
                    ArgumentDataDirectionKind.CommunicationError.toString());
                end
                [numTimeoutErrorArgs,errArgIdx]=...
                autosar.validation.AdaptiveMethodsValidator.getNumErrArguments(...
                m3iMethod,ArgumentDataDirectionKind.TimeoutError);
                if numTimeoutErrorArgs>0
                    assert(numTimeoutErrorArgs==1,'Should be at most 1 error arg');
                    m3iArgument=m3iMethod.Arguments.at(find(errArgIdx));
                    autosar.validation.Validator.logError('autosarstandard:validation:InvalidErrArgOnServerMethod',...
                    m3iMethod.Name,serverPort.Block,m3iArgument.Name,...
                    ArgumentDataDirectionKind.CommunicationError.toString());
                end
            end
        end

    end

    methods(Static,Access=public)
        function m3iMethod=getM3IMethodForFcnPort(fcnPort)
            m3iMethod=[];
            portName=get_param(fcnPort,'PortName');
            modelName=get_param(fcnPort,'Parent');
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            if strcmp(get_param(fcnPort,'BlockType'),'Inport')
                m3iPortSeq=m3iComp.RequiredPorts;
                metaClass='Simulink.metamodel.arplatform.port.ServiceRequiredPort';
            else
                m3iPortSeq=m3iComp.ProvidedPorts;
                metaClass='Simulink.metamodel.arplatform.port.ServiceProvidedPort';
            end
            m3iPort=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
            m3iComp,m3iPortSeq,portName,metaClass);
            if isempty(m3iPort)

                return;
            end
            assert(length(m3iPort)==1,'Did not find port');
            methodName=get_param(fcnPort,'Element');
            m3iMethod=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
            m3iPort.Interface,m3iPort.Interface.Methods,...
            methodName,...
            'Simulink.metamodel.arplatform.interface.Operation');
        end
    end
end


