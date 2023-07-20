classdef AdaptiveMappingValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            this.verifySLPortAPIs(hModel);
            this.verifyDataStoreMapping(hModel);
            this.verifyMapping(hModel);
            this.verifyNoMixedEventMethodPort(hModel);
        end

        function verifyPostProp(this,hModel)
            this.verifyDataStores(hModel);
        end
    end

    methods(Static,Access=private)

        function verifySLPortAPIs(hModel)

            mapping=autosar.api.Utils.modelMapping(hModel);


            apiMap=containers.Map();
            for inportIdx=1:length(mapping.Inports)
                inport=mapping.Inports(inportIdx);
                apiMap=autosar.validation.AdaptiveMappingValidator.i_checkAPI(hModel,apiMap,inport);
            end

            for outportIdx=1:length(mapping.Outports)
                outport=mapping.Outports(outportIdx);
                apiMap=autosar.validation.AdaptiveMappingValidator.i_checkAPI(hModel,apiMap,outport);
            end

        end

        function verifyDataStoreMapping(hModel)

            mapping=autosar.api.Utils.modelMapping(hModel);
            portDataElementToBlockMap=containers.Map();

            for dataStoreIndx=1:length(mapping.DataStores)
                dataStore=mapping.DataStores(dataStoreIndx);
                if strcmp(dataStore.MappedTo.ArDataRole,'Persistency')
                    arPerPortName=dataStore.MappedTo.getPerInstancePropertyValue('Port');
                    arDataElementName=dataStore.MappedTo.getPerInstancePropertyValue('DataElement');
                    dataStoreBlockStr=dataStore.OwnerBlockPath;

                    if isempty(arPerPortName)||isempty(arDataElementName)
                        autosar.validation.Validator.logError('autosarstandard:validation:unmappedDataStore',dataStoreBlockStr);
                    end

                    portDataElementStr=sprintf('%s->%s',arPerPortName,arDataElementName);

                    if portDataElementToBlockMap.isKey(portDataElementStr)&&~isempty(arPerPortName)&&~isempty(arDataElementName)

                        autosar.validation.Validator.logError('autosarstandard:validation:duplicateDataElement',...
                        dataStoreBlockStr,portDataElementToBlockMap(portDataElementStr),arPerPortName,arDataElementName);
                    else

                        portDataElementToBlockMap(portDataElementStr)=dataStoreBlockStr;
                    end
                end
            end
        end

        function apiMap=i_checkAPI(hModel,apiMap,port)


            arPortName=port.MappedTo.Port;
            arEventName=port.MappedTo.Event;

            apiStr=sprintf('%s->%s',arPortName,arEventName);

            usrReadableRefStr=DAStudio.message('RTW:autosar:simulinkPort',port.Block);
            if apiMap.isKey(apiStr)&&~isempty(arPortName)

                dataObj=autosar.api.getAUTOSARProperties(hModel,true);
                componentQName=dataObj.get('XmlOptions','ComponentQualifiedName');
                interfaceQName=dataObj.get([componentQName,'/',arPortName],'Interface','PathType','FullyQualified');
                autosar.validation.Validator.logError('RTW:autosar:duplicateApi',...
                usrReadableRefStr,apiMap(apiStr).usrReadableRefStr,arEventName,interfaceQName,arPortName);
            else

                apiMap(apiStr)=struct('usrReadableRefStr',usrReadableRefStr);
            end
        end

        function verifyMapping(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            try
                mapping.validate();
            catch ME




                autosar.validation.Validator.logError(ME.identifier,ME);
            end
        end

        function verifyDataStores(hModel)
            mapping=autosar.api.Utils.modelMapping(hModel);
            try
                mapping.validateDataStores();
            catch ME




                autosar.validation.Validator.logError(ME.identifier,ME);
            end
        end

        function verifyNoMixedEventMethodPort(hModel)



            autosar.validation.AdaptiveMappingValidator.verifyNoMixedMapping(hModel,'RequiredPorts');
            autosar.validation.AdaptiveMappingValidator.verifyNoMixedMapping(hModel,'ProvidedPorts');
        end

        function verifyNoMixedMapping(hModel,portType)
            mapping=autosar.api.Utils.modelMapping(hModel);
            switch portType
            case 'RequiredPorts'
                blockMappings=mapping.Inports;
                fcnPorts=autosar.simulink.functionPorts.Utils.findClientPorts(hModel);
            case 'ProvidedPorts'
                blockMappings=mapping.Outports;
                fcnPorts=autosar.simulink.functionPorts.Utils.findServerPorts(hModel);
            otherwise
                assert(false,'unexpected port type')
            end

            if isempty(blockMappings)||isempty(fcnPorts)

                return;
            end

            eventMappedPorts=arrayfun(@(x)x.MappedTo.Port,blockMappings,...
            'UniformOutput',false);
            eventMappedPorts=unique(eventMappedPorts);

            methodMappedPorts=get_param(fcnPorts,'PortName');
            if~iscell(methodMappedPorts)
                methodMappedPorts={methodMappedPorts};
            end
            methodMappedPorts=unique(methodMappedPorts);

            mixedPorts=intersect(eventMappedPorts,methodMappedPorts);
            if~isempty(mixedPorts)
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:mixedEventMethodPort',...
                portType,autosar.api.Utils.cell2str(mixedPorts));
            end
        end
    end

end


