function setIndividualDataFromMappingInspector(modelName,mappingObj,modelingElementCategory,varargin)






    modelH=get_param(modelName,'Handle');
    argParser=inputParser;
    argParser.FunctionName='setIndividualDataFromMappingInspector';
    argParser.KeepUnmatched=true;
    argParser.parse(varargin{:});

    params=argParser.Unmatched;
    propertyNames=fieldnames(params);
    propertyValues=struct2cell(params);
    errorMessages=cell(size(propertyNames));


    storageClass=mappingObj.getStorageClassName();
    CSCAttributes=mappingObj.MappedTo.getCSCAttributeNames(modelH);
    for ii=1:numel(propertyNames)
        propertyName=propertyNames{ii};
        propertyValue=propertyValues{ii};

        if strcmp(propertyName,'Identifier')
            mappingObj.setIdentifier(argParser.Unmatched.Identifier);
        elseif ismember(propertyName,CSCAttributes)
            propertyType=mappingObj.MappedTo.getCSCAttributeType(...
            modelH,propertyName);
            if isequal(propertyType,'string')&&...
                ((isstring(propertyValue)&&isStringScalar(propertyValue))...
                ||ischar(propertyValue))

                errorMessage=mappingObj.setPerInstanceProperty(storageClass,propertyName,propertyValue);
                if~isempty(errorMessage)
                    errorMessages{ii}=errorMessage;
                end
            else
                if any(strcmp(propertyType,{'int32','double'}))&&...
                    ((isstring(propertyValue)&&isStringScalar(propertyValue))...
                    ||ischar(propertyValue))
                    propertyValue=str2double(propertyValue);
                end
                updatedPropertyValue=Simulink.CodeMapping.massageAndValidatePerInstancePropertyValue(...
                modelH,mappingObj,propertyName,propertyValue);
                Simulink.CodeMapping.setPerInstancePropertyValue(...
                modelH,mappingObj,'MappedTo',propertyName,updatedPropertyValue);
            end
        else
            propertyName=propertyNames{ii};
            try
                coder.internal.ProfileStereotypeUtils.setStereotypePropertyValues(...
                modelName,modelingElementCategory,mappingObj,propertyName,propertyValue);
            catch ME
                errorMessages{ii}=ME.message;
            end
        end
    end

    errorMessages=errorMessages(~cellfun('isempty',errorMessages));
    if numel(errorMessages)>0
        error(errorMessages{1});
    end
