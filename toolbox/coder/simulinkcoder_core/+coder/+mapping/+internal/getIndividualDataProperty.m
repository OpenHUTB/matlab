function value=getIndividualDataProperty(mdlH,mapping,property,mappingType,modelIdentifierType,modelIdentifier)




    modelMapping=Simulink.CodeMapping.getCurrentMapping(mdlH);
    allowedProfileProps=coder.mapping.internal.getAllowedProfileProperties(mappingType);

    if isa(modelMapping,'Simulink.CoderDictionary.ModelMapping')&&...
        modelMapping.isFunctionPlatform
        autoLabel='';
        if isa(mapping,'Simulink.CoderDictionary.SignalDataTransfersMapping')
            allowedProps={'DataTransferService'};
            modelElementType='DataTransfer';
        elseif isa(mapping,'Simulink.CoderDictionary.InportsMapping')
            allowedProps={'ReceiverService'};
            if Simulink.CodeMapping.isCodeIdentifierValidProperty(mapping)
                allowedProps{end+1}='Identifier';
            end
            modelElementType='Inputs';
        elseif isa(mapping,'Simulink.CoderDictionary.OutportsMapping')
            allowedProps={'SenderService'};
            if Simulink.CodeMapping.isCodeIdentifierValidProperty(mapping)
                allowedProps{end+1}='Identifier';
            end
            modelElementType='Outputs';
        elseif isa(mapping,'Simulink.CoderDictionary.InternalDataMapping')||...
            isa(mapping,'Simulink.CoderDictionary.SynthesizedLocalDataStoreMapping')

            allowedProps={'MeasurementService','Identifier'};
            modelElementType='Internal';
            autoLabel=DAStudio.message('coderdictionary:mapping:NoMeasurementService');
        elseif isa(mapping,'Simulink.CoderDictionary.ModelScopedParameterMapping')
            if mapping.InstanceSpecific
                modelElementType='InstanceSpecificParameters';
            else
                modelElementType='Parameters';
            end
            allowedProps={'ParameterTuningService','Identifier'};
            autoLabel=DAStudio.message('coderdictionary:mapping:NoTuningService');
        end

        coder.mapping.internal.checkAllowedPropertiesForData(property,...
        allowedProps,allowedProfileProps,mappingType,...
        modelIdentifierType,modelIdentifier);
        if isequal(property,'Identifier')

            value=mapping.getIdentifier();
        else

            if isa(mapping,'Simulink.CoderDictionary.SignalDataTransfersMapping')
                sp=mapping;
            else
                sp=mapping.MappedTo.ServicePort;
            end
            if isempty(sp)
                assert(~isempty(autoLabel),...
                'Empty setting is only for internal data and parameters')
                value=autoLabel;
            elseif isempty(sp.UUID)
                dictionaryDefault=DAStudio.message('coderdictionary:mapping:PlatformDefault');
                value=dictionaryDefault;
            else
                value=codermapping.internal.c.dictionary.getServicePortNameFromUuid(mdlH,...
                sp.UUID,modelElementType);
            end
        end
    else

        allowedProps={'StorageClass'};
        storageClass=mapping.getStorageClassName();
        if~strcmp(storageClass,'Auto')


            allowedProps=[allowedProps;'Identifier'];

            mappedTo=mapping.MappedTo;
            if~isempty(mappedTo)
                allowedProps=[allowedProps;...
                mappedTo.getCSCAttributeNames(mdlH)];
            end
        end
        coder.mapping.internal.checkAllowedPropertiesForData(property,...
        allowedProps,allowedProfileProps,mappingType,...
        modelIdentifierType,modelIdentifier);
        if strcmp(property,'StorageClass')
            value=storageClass;
        elseif strcmp(property,'Identifier')
            value=mapping.getIdentifier();
        elseif ismember(property,allowedProps)



            defValue='';
            sc=coder.internal.CoderDataStaticAPI.getByName(mdlH,'StorageClass',storageClass);
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            scSchema=hlp.getProp(sc,'CSCAttributesSchema');
            if~isempty(scSchema)
                defAttribs=jsondecode(scSchema);
                for jj=1:length(defAttribs)
                    if strcmp(defAttribs(jj).Name,property)
                        defValue=defAttribs(jj).Value;
                        break;
                    end
                end
            end


            attribsJson=mappedTo.CSCAttributes;
            if~isempty(attribsJson)
                attribs=jsondecode(attribsJson);
                for jj=1:length(attribs)
                    if strcmp(attribs(jj).Name,property)
                        value=attribs(jj).Value;
                        if isequal(mappedTo.getCSCAttributeType(mdlH,property),'bool')&&...
                            ischar(value)



                            if isequal(value,'1')
                                value=true;
                            else
                                value=false;
                            end
                        end
                        if isequal(mappedTo.getCSCAttributeType(mdlH,property),'int32')&&...
                            ischar(value)



                            value=str2double(value);
                        end
                        return;
                    end
                end
            end
            value=defValue;
        end
    end
    if ismember(property,allowedProfileProps)
        modelingElementCategory=coder.internal.ProfileStereotypeUtils.getModelingElementCategory(mappingType);
        [~,value]=coder.internal.ProfileStereotypeUtils.getStereotypePropertyValue(mapping,property,modelingElementCategory);
    end
end
