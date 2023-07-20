classdef ProfileStereotypeUtils




    methods(Static,Access='public')
        function[valid,msg,name]=loadIfValidProfile(profileName)
            name=[];
            valid=false;
            msg=[];
            try
                if~sl.data.annotation.api.Api.isProfileLoaded(profileName)
                    profile=sl.data.annotation.api.Api.loadFromFile(profileName);
                else
                    profile=sl.data.annotation.api.Api.getProfileByName(profileName);
                    if isempty(profile)
                        profile=sl.data.annotation.api.Api.loadFromFile(profileName);
                    end
                end
                name=profile.getName();
                valid=~profile.isUnhealthyOnLoad;
            catch E
                msg=E.message;
            end
        end

        function[names,displayNames,schemas]=initStereotypes(profileName)
            names={};
            displayNames={};
            schemas={};
            if~sl.data.annotation.api.Api.isProfileLoaded(profileName)
                profile=sl.data.annotation.api.Api.loadFromFile(profileName);
            else
                profile=sl.data.annotation.api.Api.getProfileByName(profileName);
            end
            if~isempty(profile)
                prototypes=profile.prototypes.toArray;
                count=numel(prototypes);
                names=cell(0,count);
                displayNames=cell(0,count);
                schemas=cell(0,count);
                for ii=1:count
                    splits=split(prototypes(ii).fullyQualifiedName,'.');
                    if isequal(numel(splits),2)
                        names{ii}=splits{end};
                        displayNames{ii}=prototypes(ii).friendlyName;
                        schemas{ii}=sl.data.annotation.api.Api.getPrototypeDefinition([profileName,'.',names{ii}]);
                    end
                end
            end
        end

        function[properties,appliedTo]=getStereotypeProperties(profileName,stereotypeName,getProperty)
            properties={};
            appliedTo=[];
            if~sl.data.annotation.api.Api.isProfileLoaded(profileName)
                profile=sl.data.annotation.api.Api.loadFromFile(profileName);
            else
                profile=sl.data.annotation.api.Api.getProfileByName(profileName);
            end
            schemas=sl.data.annotation.api.Api.getPrototypeDefinition([profileName,'.',stereotypeName]);
            schema=jsondecode(schemas);
            appliedTo=schema.AppliesTo;
            if strcmp(getProperty,'getAllProps')
                for property=transpose(schema.Properties)

                    properties=[properties,property.Name];
                end
            else
                for property=transpose(schema.Properties)

                    if property.IsVisible
                        properties=[properties,property.Name];
                    end
                end
            end
        end

        function[ret,dataType,defaultValue,allowedValues]=isStereotypeProperty(...
            model,modelingElementCategory,propertyName)%#ok<INUSL>



            ret=false;
            allowedValues={};
            dataType=[];
            defaultValue=[];

            stereotypeName=coder.internal.ProfileStereotypeUtils.getStereotypeName(modelingElementCategory);
            schemas=sl.data.annotation.api.Api.getPrototypeDefinition(['Calibration','.',stereotypeName]);
            stereotypeSchema=jsondecode(schemas);
            if isfield(stereotypeSchema,'Properties')
                for prop=transpose(stereotypeSchema.Properties)

                    if strcmp(prop.Name,propertyName)
                        dataType=prop.Type;
                        defaultValue=coder.internal.ProfileStereotypeUtils.typeCastJsonData(prop.DefaultValue,'string');
                        allowedValues=prop.AllowedValues;
                        ret=true;
                        break;
                    end
                end
            end
        end
        function stereotypeName=getStereotypeName(modelingElementCategory)


            if strcmp(modelingElementCategory,'ModelParameters')
                stereotypeName='Calibration';
            else
                stereotypeName='Measurement';
            end
        end
        function[valAsString,val]=getStereotypePropertyValue(mappingObj,propertyName,category)


            schema=mappingObj.StereotypeProperties;
            found=false;
            if~isempty(schema)
                records=jsondecode(schema);
                for jj=1:numel(records)
                    if strcmp(records(jj).Name,propertyName)
                        val=records(jj).Value;
                        found=true;
                        break;
                    end
                end
            end

            if~found
                val=coder.internal.ProfileStereotypeUtils.getStereotypePropertyDefaultValue(...
                'Calibration',propertyName,category);
            end
            valAsString=coder.internal.ProfileStereotypeUtils.typeCastJsonData(val,'string');
        end

        function[propUpdated,errMsg]=setStereotypePropertyValue(model,modelingElementCategory,mappingObj,propertyName,propertyValue)


            propUpdated=false;
            stereotypeName=coder.internal.ProfileStereotypeUtils.getStereotypeName(modelingElementCategory);
            [allowedProperties,~]=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',stereotypeName,'getAllProps');
            propertyName=validatestring(propertyName,allowedProperties,'setProperty','PROPERTYNAME',4);
            errMsg=[];

            isVisible=coder.internal.ProfileStereotypeUtils.isVisibleProperty(stereotypeName,propertyName);


            if strcmp(propertyName,'Format')
                isValid=false;
                if~isempty(propertyValue)

                    expression='%[0-9]*(\.[0-9]*)';
                    [startRegex,endRegex]=regexp(propertyValue,expression,'ONCE');
                    if~isempty(startRegex)&&startRegex==1&&numel(propertyValue)==endRegex
                        isValid=true;
                    end
                    if~isValid
                        DAStudio.error('coderdictionary:profiles:ValidateFormat');
                    end
                end


            elseif strcmp(propertyName,'BitMask')
                isValid=false;
                if~isempty(propertyValue)

                    expression='^0[xX][0-9a-fA-F]+$';
                    if~isempty(regexp(propertyValue,expression,'ONCE'))
                        isValid=true;
                    end
                    if~isValid
                        DAStudio.error('coderdictionary:profiles:ValidateBitMask');
                    end
                end
            elseif strcmp(propertyName,'Export')
                isValid=false;
                if~isempty(propertyValue)

                    if islogical(propertyValue)||...
                        strcmp(propertyValue,'0')||...
                        strcmp(propertyValue,'1')
                        isValid=true;
                    end
                    if~isValid
                        DAStudio.error('coderdictionary:profiles:ValidateExport',propertyValue,propertyName);
                    end
                end
            end
            [~,dataType,defaultVal,allowedValues]=coder.internal.ProfileStereotypeUtils.isStereotypeProperty(model,modelingElementCategory,propertyName);
            isStringValue=ischar(defaultVal)||isStringScalar(defaultVal);
            if isStringValue&&numel(allowedValues)>1
                propertyValue=validatestring(propertyValue,allowedValues);
            end
            propertyValue=coder.internal.ProfileStereotypeUtils.typeCastJsonData(propertyValue,dataType);
            encodedString='';
            schema=mappingObj.StereotypeProperties;
            if~isempty(schema)
                records=jsondecode(schema);
                entryFound=false;
                indicesToRemove=[];

                for jj=1:numel(records)
                    if strcmp(records(jj).Name,propertyName)
                        records(jj).Value=propertyValue;
                        if isStringValue&&strcmp(records(jj).Value,defaultVal)...
                            ||~isStringValue&&(records(jj).Value==defaultVal)
                            indicesToRemove=[indicesToRemove,jj];%#ok<AGROW>
                        end
                        entryFound=true;
                        break;
                    end

                end

                if entryFound


                    if numel(indicesToRemove)>0
                        records(indicesToRemove)=[];
                    end
                else
                    records(end+1)=struct('Name',propertyName,'Value',propertyValue,'isVisible',isVisible);
                end
                if~isempty(records)
                    encodedString=jsonencode(records);
                end
            else
                if~strcmp(propertyValue,defaultVal)
                    encodedString=jsonencode(struct('Name',propertyName,'Value',propertyValue,'isVisible',isVisible));
                end
            end
            mappingObj.StereotypeProperties=encodedString;
            propUpdated=true;
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',propUpdated);
            set_param(model,'Dirty','on');
        end

        function[propUpdated,errMsg]=setStereotypePropertyValues(model,modelingElementCategory,mappingObj,propertyName,propertyValue)
            errMsg=[];
            stereotypeName=coder.internal.ProfileStereotypeUtils.getStereotypeName(modelingElementCategory);
            [allowedProperties,appliesTo]=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',stereotypeName,'getAllProps');
            propertyName=validatestring(propertyName,allowedProperties,'setProperty','PROPERTYNAME',4);
            if any(strcmp(modelingElementCategory,appliesTo))
                [propUpdated,errMsg]=coder.internal.ProfileStereotypeUtils.setStereotypePropertyValue(...
                model,modelingElementCategory,mappingObj,propertyName,propertyValue);
            else
                DAStudio.error('coderdictionary:profiles:StereotypePropertyNotApplicable',propertyName,modelingElementCategory);
            end
            if~propUpdated
                return;
            end
            propUpdated=true;
        end

        function defaultVal=getStereotypePropertyDefaultValue(profileName,propertyName,category)


            defaultVal='';
            stereotypeName=coder.internal.ProfileStereotypeUtils.getStereotypeName(category);
            schemas=sl.data.annotation.api.Api.getPrototypeDefinition([profileName,'.',stereotypeName]);
            schema=jsondecode(schemas);
            if any(strcmp(category,schema.AppliesTo))
                for prop=transpose(schema.Properties)

                    if strcmp(prop.Name,propertyName)
                        defaultVal=prop.DefaultValue;
                        break;
                    end
                end
            else
                DAStudio.error('coderdictionary:profiles:StereotypePropertyNotApplicable',propertyName,category);
            end
        end

        function typeCastedValue=typeCastJsonData(origValue,targetDataType)




            if strcmp(targetDataType,'boolean')
                if strcmp(origValue,'true')||strcmp(origValue,'1')
                    typeCastedValue=true;
                elseif strcmp(origValue,'false')||strcmp(origValue,'0')
                    typeCastedValue=false;
                else
                    typeCastedValue=origValue;
                end
            elseif strcmp(targetDataType,'double')||strcmp(targetDataType,'single')...
                ||strcmp(targetDataType,'int16')||strcmp(targetDataType,'uint16')...
                ||strcmp(targetDataType,'int32')||strcmp(targetDataType,'uint32')
                if ischar(origValue)||isStringScalar(origValue)
                    origValue=str2double(origValue);
                end
                typeCastedValue=cast(origValue,targetDataType);
            elseif strcmp(targetDataType,'string')||strcmp(targetDataType,'ustring')
                if islogical(origValue)
                    if origValue
                        typeCastedValue='1';
                    else
                        typeCastedValue='0';
                    end
                elseif isa(origValue,'double')||isa(origValue,'single')
                    typeCastedValue=rtw.connectivity.CodeInfoUtils.double2str(origValue);
                elseif isnumeric(origValue)
                    typeCastedValue=int2str(origValue);
                else
                    typeCastedValue=origValue;
                end
            else
                typeCastedValue=origValue;
            end
        end
        function modelingElementCategory=getModelingElementCategory(mappingType)
            modelingElementCategory='';
            switch mappingType
            case 'model parameter mapping'
                modelingElementCategory='ModelParameters';
            case 'signal mapping'
                modelingElementCategory='Signals';
            case 'inport mapping'
                modelingElementCategory='Inports';
            case 'outport mapping'
                modelingElementCategory='Outports';
            case 'state mapping'
                modelingElementCategory='States';
            case 'data store mapping'
                modelingElementCategory='DataStores';
            case 'model data store mapping'
                modelingElementCategory='SynthesizedDataStores';
            case 'synthesized data store mapping'
                modelingElementCategory='SynthesizedDataStores';

            end
        end
        function displayName=getDisplayName(propertyName,prefix)


            stereotype=strsplit(prefix,'.');
            profileName='Calibration';
            if~sl.data.annotation.api.Api.isProfileLoaded(profileName)
                profile=sl.data.annotation.api.Api.loadFromFile(profileName);
            else
                profile=sl.data.annotation.api.Api.getProfileByName(profileName);
            end
            schemas=sl.data.annotation.api.Api.getPrototypeDefinition(['Calibration','.',stereotype{1}]);
            schema=jsondecode(schemas);
            for property=transpose(schema.Properties)
                if strcmp(property.Name,propertyName)
                    if~isempty(property.FriendlyName)
                        displayName=property.FriendlyName;
                        break;
                    end
                end
            end
        end
    end
    methods(Static,Access=private)
        function isVisble=isVisibleProperty(stereotypeName,propertyName)


            schemas=sl.data.annotation.api.Api.getPrototypeDefinition(['Calibration','.',stereotypeName]);
            schema=jsondecode(schemas);
            for property=transpose(schema.Properties)

                if strcmp(property.Name,propertyName)
                    isVisble=property.IsVisible;
                    break;
                end
            end

        end

    end

end


