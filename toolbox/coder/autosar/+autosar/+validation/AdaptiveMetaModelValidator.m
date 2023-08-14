classdef AdaptiveMetaModelValidator<autosar.validation.PhasedValidator




    methods(Access=protected)

        function verifyInitial(this,hModel)
            commonValidator=autosar.validation.MetaModelCommonValidator(hModel);
            m3iModel=autosar.api.Utils.m3iModel(hModel);
            commonValidator.verify(m3iModel);
            this.verifyEventNames(hModel);
            this.verifyTopicNames(hModel,m3iModel);
            this.verifyUniqueInstanceIdentfiersForPorts(hModel);
            this.verifyMajorMinorVersion(hModel);
        end

    end

    methods(Static,Access=private)

        function verifyTopicNames(hModel,m3iModel)

            mapping=autosar.api.Utils.modelMapping(hModel);
            binding=autosar.internal.adaptive.manifest.ManifestUtilities.getBindingType(m3iModel);
            modelName=get_param(hModel,'Name');

            slPorts=[mapping.Inports,mapping.Outports];

            if strcmp(binding,'DDS')
                for dataIdx=1:length(slPorts)
                    slPort=slPorts(dataIdx);
                    arPortName=slPort.MappedTo.Port;
                    eventName=slPort.MappedTo.Event;
                    eventDeplObj=autosar.internal.adaptive.manifest.ManifestUtilities.getEventDeploymentObj(modelName,arPortName,eventName);
                    if~isempty(eventDeplObj)
                        topicName=eventDeplObj.TopicName;
                        if strcmp(get_param(modelName,'AutosarSchemaVersion'),'R20-11')
                            [isValid,~]=autosar.validation.AutosarUtils.checkFnmatchPattern(topicName,class(eventDeplObj));
                            if~isValid
                                autosar.validation.Validator.logError('autosarstandard:ui:validateDdsIdentifierName','TopicName',topicName,'TopicName');
                            end
                        else
                            [isValid,~]=autosar.validation.AutosarUtils.checkDdsIdentifier(topicName,class(eventDeplObj));
                            if~isValid
                                autosar.validation.Validator.logError('autosarstandard:ui:validateDdsIdentifierNameFnmatchPattern','TopicName',identifier,'TopicName');
                            end
                        end
                    end
                end
            end
        end

        function verifyEventNames(hModel)


            mapping=autosar.api.Utils.modelMapping(hModel);
            dataObj=autosar.api.getAUTOSARProperties(hModel,true);
            componentQName=dataObj.get('XmlOptions','ComponentQualifiedName');

            for dataIdx=1:length(mapping.Inports)
                inport=mapping.Inports(dataIdx);
                apPortName=inport.MappedTo.Port;
                apEventName=inport.MappedTo.Event;
                if isempty(apPortName)||isempty(apEventName)||...
                    autosar.composition.Utils.isCompositeInportBlock(get_param(inport.Block,'Handle'))



                    continue;
                end

                interfaceName=dataObj.get([componentQName,'/',apPortName],...
                'Interface');
                if strcmp(apEventName,interfaceName)
                    autosar.validation.Validator.logError('autosarstandard:validation:invalidAdaptiveInterfaceEventName',...
                    get_param(hModel,'Name'),interfaceName,apEventName);
                end
            end
        end

        function verifyUniqueInstanceIdentfiersForPorts(hModel)



            autosar.internal.adaptive.manifest.ManifestUtilities.verifyUniqueInstanceIdentifiersForPortsDeployment(hModel)
        end

        function verifyMajorMinorVersion(hModel)


            m3iModel=autosar.api.Utils.m3iModel(hModel);
            seq=autosar.mm.Model.findObjectByMetaClass(m3iModel,...
            Simulink.metamodel.arplatform.interface.ServiceInterface.MetaClass);
            for idx=1:size(seq)
                serviceinterface=seq.at(idx);

                [isValid,errmsg]=autosar.validation.AutosarUtils.checkVersion(serviceinterface.MajorVersion,1);
                if~isValid
                    autosar.validation.Validator.logError(errmsg{1},serviceinterface.MajorVersion,autosar.ui.metamodel.PackageString.majorVersionNode,errmsg{2});
                end

                [isValid,errmsg]=autosar.validation.AutosarUtils.checkVersion(serviceinterface.MinorVersion,1);
                if~isValid
                    autosar.validation.Validator.logError(errmsg{1},serviceinterface.MinorVersion,autosar.ui.metamodel.PackageString.minorVersionNode,errmsg{2});
                end
            end
        end

    end

end



