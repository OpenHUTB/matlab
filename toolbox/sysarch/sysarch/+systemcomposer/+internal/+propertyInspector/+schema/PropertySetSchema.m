classdef PropertySetSchema<handle



    properties
        propertyParser;
        propertyIDMap;
        elementWrapper;
        schemaFile;
        propertiesFile;
    end

    methods(Static,Access=public)
        function refresh(hdl)
            systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(hdl);
        end

        function removeHiliterFromConnector(obj)
            if~isempty(obj.hilitedConn)&&isvalid(obj.hiliter)
                obj.hiliter.removeClass(obj.hilitedConn,'ArchConnector')
            end
        end
        function prop=removeFakeProperty(fakeProp)







            idx=strfind(fakeProp,':');
            prop=fakeProp(1:idx(end)-1);
        end
    end

    methods
        function obj=PropertySetSchema(varargin)



            obj.elementWrapper=varargin{1};
            obj.propertyIDMap=containers.Map('keytype','char','valuetype','any');
            obj.schemaFile=varargin{2};
            if nargin>2
                obj.propertiesFile=varargin{3};
            else
                obj.propertiesFile='propertySchema.json';
            end
            propertyFilePath=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+propertyInspector','+templates',obj.propertiesFile);
            if(exist(propertyFilePath,'file')==2)
                obj.propertyParser=systemcomposer.internal.propertyInspector.schema.PropertySchemaParser(propertyFilePath);
            end
        end

        function[subSchema,propertySchema]=getPropertySubSchema(obj,subSchemaID,parentID)
            subSchema={};
            schemaFilePath=fullfile(matlabroot,'toolbox','sysarch','sysarch','+systemcomposer','+internal','+propertyInspector','+templates',obj.schemaFile);
            if(exist(schemaFilePath,'file')==2)
                propertySchemaSet=jsondecode(fileread(schemaFilePath)).propertySchemaSet;
                for itr=1:numel(propertySchemaSet)
                    propertySchema=propertySchemaSet(itr).propertySchema;
                    if strcmp(propertySchema.id,subSchemaID)
                        break;
                    end
                end
                if~isempty(propertySchema)&&isfield(propertySchema,'properties')
                    subSchema=obj.populatePropertySchema(parentID,propertySchema.properties);
                end
            end
        end

        function populatedSchema=populatePropertySchema(obj,parentID,childProperties)

            populatedSchema={};
            properties=childProperties;
            for propItr=1:numel(properties)
                if isstruct(properties)
                    property=properties(propItr);
                else
                    property=properties{propItr};
                end
                propertySchema=obj.propertyParser.getEvaluatedProperty(property.id,obj.elementWrapper);
                if isempty(parentID)
                    propID=property.id;
                else
                    propID=strcat(parentID,':',property.id);
                end
                property.id=propID;
                propertySchema.id=propID;
                if isfield(property,'children')&&~isempty(property.children)
                    propertySchema.children=obj.populatePropertySchema(propID,property.children);
                else
                    propertySchema.children=[];
                end

                subSchema=obj.getSubSchema(propID);
                if~isempty(subSchema)
                    propertySchema.children=subSchema;
                end
                obj.propertyIDMap(propID)=propertySchema;
                populatedSchema{end+1}=propertySchema;
                dynamicPropertySchema=obj.addDynamicPropertyAfter(propID);


                if contains(propID,'ParameterSection')
                    populatedSchema{end}=obj.propertyIDMap(propID);
                end
                if~isempty(dynamicPropertySchema)

                    for schemaItr=1:numel(dynamicPropertySchema)
                        propertySchema=dynamicPropertySchema{schemaItr};
                        populatedSchema{end+1}=propertySchema;
                    end
                end
            end
        end

        function dynamicProperty=addDynamicPropertyAfter(~,~)
            dynamicProperty={};
        end
        function subSchema=getSubSchema(~,~)
            subSchema={};
        end

    end
end
