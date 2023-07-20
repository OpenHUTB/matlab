


classdef DataDictionarySource<coder.api.internal.DataSource
    properties
ddConn
    end
    methods
        function obj=DataDictionarySource(ddConnection)
            obj.ddConn=ddConnection;
        end
    end
    methods
        function attribValue=getDataDefaults(obj,modelingElementType,attributeName)
            attribValue='';
            if any(strcmp(attributeName,{'StorageClass','MemorySection'}))
                dataDefault=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForElement(...
                obj.ddConn,modelingElementType,attributeName);
                if~isempty(dataDefault)
                    attribValue=dataDefault.getProperty('DisplayName');
                else
                    if strcmp(attributeName,'StorageClass')
                        attribValue=message('coderdictionary:mapping:SimulinkGlobal').getString;
                    elseif strcmp(attributeName,'MemorySection')
                        attribValue=message('coderdictionary:mapping:MappingNone').getString;
                    end
                end
            else
                v=coder.internal.CoderDataStaticAPI.getDataDefaultInstanceSpecificProperties(...
                obj.ddConn,modelingElementType);
                hasProp=false;
                for i=1:length(v)
                    if strcmp(v(i).Name,attributeName)
                        attribValue=v(i).Value;
                        hasProp=true;
                        break;
                    end
                end
                if~hasProp
                    DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
                end
            end

        end
        function setDataDefaults(obj,modelingElementType,argParser)
            storageClass=argParser.Results.StorageClass;
            memorySection=argParser.Results.MemorySection;
            if~isempty(storageClass)
                coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(...
                obj.ddConn,modelingElementType,'StorageClass',storageClass);
            end
            if~isempty(memorySection)
                coder.internal.CoderDataStaticAPI.setDefaultCoderDataForElement(...
                obj.ddConn,modelingElementType,'MemorySection',memorySection);
            end
            params=argParser.Unmatched;
            instSpecificPropertyNames=fieldnames(params);
            instSpecificPropertyValues=struct2cell(params);
            for ii=1:numel(instSpecificPropertyNames)
                coder.internal.CoderDataStaticAPI.setIndividualDataDefaultInstanceSpecificProperty(obj.ddConn,modelingElementType,...
                instSpecificPropertyNames{ii},instSpecificPropertyValues{ii});
            end
        end
        function allowedValues=getAllowedDataDefaultValues(obj,modelingElementType,attributeName)
            hlp=coder.internal.CoderDataStaticAPI.getHelper;
            dd=hlp.openDD(obj.ddConn);
            allows=coderdictionary.data.SlCoderDataClient.getAllCoderDataForModelElementTypeForContainer(dd.owner,modelingElementType,attributeName,'ModelLevel');
            allowedValues={};
            if~isempty(allows)
                allowedValues=cell(size(allows));
                for i=1:length(allows)
                    allowedValues{i}=allows(i).getProperty('DisplayName');
                end
            end
            if~iscell(allowedValues)
                allowedValues={allowedValues};
            end
            switch attributeName
            case 'StorageClass'
                allowedValues=[message('coderdictionary:mapping:SimulinkGlobal').getString
                allowedValues];
            case 'MemorySection'
                allowedValues=[message('coderdictionary:mapping:MappingNone').getString
                allowedValues];
            otherwise
                DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
            end
        end
        function attribValue=getFunctionDefaults(obj,modelFunction,attributeName)
            if~any(strcmp(attributeName,{'FunctionClass','MemorySection'}))
                DAStudio.error('coderdictionary:api:invalidAttributeName',attributeName);
            end
            value=coder.internal.CoderDataStaticAPI.getDefaultCoderDataForFunction(...
            obj.ddConn,modelFunction,attributeName);
            attribValue='';
            if~isempty(value)
                attribValue=value.getProperty('DisplayName');
            else
                if strcmp(attributeName,'FunctionClass')
                    attribValue=message('coderdictionary:mapping:MappingFunctionDefault').getString;
                elseif strcmp(attributeName,'MemorySection')
                    attribValue=message('coderdictionary:mapping:MappingNone').getString;
                end
            end
        end
        function setFunctionDefaults(obj,modelFunction,argParser)
            functionClass=argParser.Results.FunctionClass;
            memorySection=argParser.Results.MemorySection;
            if~isempty(memorySection)
                coder.internal.CoderDataStaticAPI.setDefaultCoderDataForFunction(...
                obj.ddConn,modelFunction,'MemorySection',memorySection);
            end
            if~isempty(functionClass)
                coder.internal.CoderDataStaticAPI.setDefaultCoderDataForFunction(...
                obj.ddConn,modelFunction,'FunctionClass',functionClass);
            end
        end
        function allowedValues=getAllowedFunctionDefaultValues(obj,modelFunction,attributeName)
            allows=coder.internal.CoderDataStaticAPI.getAllowableCoderDataForFunction(...
            obj.ddConn,modelFunction,attributeName);
            allowedValues=coder.internal.CoderDataStaticAPI.getDisplayName(obj.ddConn,allows);
        end
    end
end


