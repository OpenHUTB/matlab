function setIndividualDataProperties(modelName,mappingObj,modelElementType,argParser,mappingType,modelIdentifierType,modelIdentifier)




    modelH=get_param(modelName,'Handle');
    modelMapping=Simulink.CodeMapping.getCurrentMapping(modelH);
    allowedProfileProps=coder.mapping.internal.getAllowedProfileProperties(mappingType);
    modelingElementCategory=coder.internal.ProfileStereotypeUtils.getModelingElementCategory(mappingType);


    if isa(modelMapping,'Simulink.CoderDictionary.ModelMapping')&&...
        modelMapping.isFunctionPlatform
        configureService=false;
        isIdentifierConfigurable=false;

        if isequal(modelElementType,'DataTransfer')
            meType='DataTransfers';
            mapFunction='map';
            allowedProps={'DataTransferService'};
            mappedService=argParser.Results.DataTransferService;
            configureService=true;
        elseif isequal(modelElementType,'Inports')
            meType='Inports';
            mapFunction='mapServicePort';
            allowedProps={'ReceiverService'};
            isIdentifierConfigurable=Simulink.CodeMapping.isCodeIdentifierValidProperty(mappingObj);
            if isIdentifierConfigurable
                allowedProps{end+1}='Identifier';
            end
            if isfield(argParser.Unmatched,'ReceiverService')
                configureService=true;
                mappedService=argParser.Unmatched.ReceiverService;
            end
        elseif isequal(modelElementType,'Outports')
            meType='Outports';
            mapFunction='mapServicePort';
            allowedProps={'SenderService'};
            isIdentifierConfigurable=Simulink.CodeMapping.isCodeIdentifierValidProperty(mappingObj);
            if isIdentifierConfigurable
                allowedProps{end+1}='Identifier';
            end
            if isfield(argParser.Unmatched,'SenderService')
                configureService=true;
                mappedService=argParser.Unmatched.SenderService;
            end
        elseif isequal(modelElementType,'InternalData')
            meType='InternalData';
            mapFunction='map';
            allowedProps={'MeasurementService','Identifier'};
            isIdentifierConfigurable=true;
            if isfield(argParser.Unmatched,'MeasurementService')
                configureService=true;
                mappedService=argParser.Unmatched.MeasurementService;
            end
        elseif isequal(modelElementType,'LocalParameters')
            meType='LocalParameters';
            mapFunction='map';
            allowedProps={'ParameterTuningService','Identifier'};
            isIdentifierConfigurable=true;
            if isfield(argParser.Unmatched,'ParameterTuningService')
                configureService=true;
                mappedService=argParser.Unmatched.ParameterTuningService;
            end
        elseif isequal(modelElementType,'ParameterArguments')
            meType='ParameterArguments';
            mapFunction='map';
            allowedProps={'ParameterTuningService','Identifier'};
            isIdentifierConfigurable=true;
            if isfield(argParser.Unmatched,'ParameterTuningService')
                configureService=true;
                mappedService=argParser.Unmatched.ParameterTuningService;
            end
        else
            assert(true,'Unsupported modeling element type')
        end

        if configureService
            allowedValues=codermapping.internal.c.dictionary.getAllowedServicePortNames(...
            modelH,meType);
            mappedService=validatestring(mappedService,allowedValues);
            dictionaryDefault=DAStudio.message('coderdictionary:mapping:PlatformDefault');
            notMeasured=DAStudio.message('coderdictionary:mapping:NoMeasurementService');
            notTuned=DAStudio.message('coderdictionary:mapping:NoTuningService');

            if isequal(mappedService,dictionaryDefault)
                mappingObj.(mapFunction)('');
            elseif isequal(mappedService,notMeasured)||...
                isequal(mappedService,notTuned)
                mappingObj.unmap();
            else
                uuid=codermapping.internal.c.dictionary.getServicePortUuidFromName(...
                modelH,mappedService,meType);
                mappingObj.(mapFunction)(uuid);
            end
        end
        if isIdentifierConfigurable&&isfield(argParser.Unmatched,'Identifier')
            mappingObj.setIdentifier(argParser.Unmatched.Identifier);
        end

        params=argParser.Unmatched;
        if~isempty(fields(params))

            instSpecificPropertyNames=transpose(fieldnames(params));
            instSpecificPropertyValues=struct2cell(params);
            for ii=1:numel(instSpecificPropertyNames)
                propertyName=instSpecificPropertyNames{ii};
                propertyValue=instSpecificPropertyValues{ii};
                if~any(strcmp(propertyName,allowedProps))
                    if~any(ismember(propertyName,allowedProfileProps))
                        allAllowedProps=strjoin(allowedProps,', ');
                        if~isempty(allowedProfileProps)
                            allAllowedProps=strcat(allAllowedProps,', ',...
                            strjoin(allowedProfileProps,', '));
                        end
                        DAStudio.error('coderdictionary:api:invalidPropertyName',propertyName,...
                        mappingType,modelIdentifierType,modelIdentifier,allAllowedProps);
                    else
                        coder.internal.ProfileStereotypeUtils.setStereotypePropertyValues(modelName,modelingElementCategory,mappingObj,propertyName,propertyValue);
                    end
                end
            end
        end
    else

        StorageClass=mappingObj.getStorageClassName();
        modelMapping=mappingObj.ParentMapping;
        if isfield(argParser.Unmatched,'StorageClass')
            StorageClass=argParser.Unmatched.StorageClass;
            StorageClass=validatestring(StorageClass,modelMapping.DefaultsMapping.getAllowedGroupNames(modelElementType,'IndividualLevel'));
        end

        allowedProps={'StorageClass'};

        if strcmp(StorageClass,DAStudio.message('coderdictionary:mapping:NoMapping'))
            mappingObj.unmap();
        elseif~isempty(StorageClass)
            mappedTo=mappingObj.MappedTo;
            scUuid=modelMapping.DefaultsMapping.getGroupUuidFromName(StorageClass);
            if isempty(mappedTo)||isempty(mappedTo.StorageClass)||~strcmp(scUuid,mappedTo.StorageClass.UUID)
                mappingObj.map(scUuid);
            end
            mappedTo=mappingObj.MappedTo;
            allowedProps=[allowedProps;...
            mappedTo.getCSCAttributeNames(modelH)];
        end

        if~strcmp(StorageClass,'Auto')
            allowedProps=[allowedProps;'Identifier'];
        end

        if isfield(argParser.Unmatched,'Identifier')
            if~strcmp(StorageClass,'Auto')

                mappingObj.setIdentifier(argParser.Unmatched.Identifier);
            else
                DAStudio.error('coderdictionary:api:invalidMappingProperty',...
                'Identifier',mappingType,modelIdentifierType,modelIdentifier);
            end
        end

        params=argParser.Unmatched;
        if~isempty(fields(params))
            instSpecificPropertyNames=fieldnames(params);
            instSpecificPropertyValues=struct2cell(params);
            errorMessages=cell(size(instSpecificPropertyNames));
            for ii=1:numel(instSpecificPropertyNames)
                propertyName=instSpecificPropertyNames{ii};
                if strcmp(propertyName,'StorageClass')||...
                    strcmp(propertyName,'Identifier')
                    continue;
                end

                propertyValue=instSpecificPropertyValues{ii};

                coder.mapping.internal.checkAllowedPropertiesForData(propertyName,...
                allowedProps,allowedProfileProps,mappingType,...
                modelIdentifierType,modelIdentifier);

                if ismember(propertyName,allowedProps)
                    propertyType=mappingObj.MappedTo.getCSCAttributeType(...
                    modelH,propertyName);
                    if isequal(propertyType,'string')&&...
                        ((isstring(propertyValue)&&isStringScalar(propertyValue))...
                        ||ischar(propertyValue))



                        errorMessage=mappingObj.setPerInstanceProperty(StorageClass,propertyName,propertyValue);
                        if~isempty(errorMessage)
                            errorMessages{ii}=errorMessage;
                        end
                    else
                        updatedPropertyValue=Simulink.CodeMapping.massageAndValidatePerInstancePropertyValue(...
                        modelH,mappingObj,propertyName,propertyValue);
                        Simulink.CodeMapping.setPerInstancePropertyValue(...
                        modelH,mappingObj,'MappedTo',propertyName,updatedPropertyValue);
                    end
                else
                    coder.internal.ProfileStereotypeUtils.setStereotypePropertyValues(modelName,modelingElementCategory,mappingObj,propertyName,propertyValue);
                end
            end
            errorMessages=errorMessages(~cellfun('isempty',errorMessages));
            if numel(errorMessages)>0
                error(errorMessages{1});
            end
        else
            DAStudio.error('coderdictionary:api:UnspecifiedPropertyName',...
            argParser.FunctionName,strjoin(allowedProps,', '));
        end
    end
end
