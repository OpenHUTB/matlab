classdef StereotypePropertyElementSchema<systemcomposer.internal.propertyInspector.schema.PropertySetSchema



    properties
        propertySchemaID='PropertyTable';
        stereotype;
        colIds;
    end

    methods

        function obj=StereotypePropertyElementSchema(elementWrapper)


            obj=obj@systemcomposer.internal.propertyInspector.schema.PropertySetSchema(elementWrapper,'ProfileEditorPropertyInspector.json','profileEditorProperties.json');
        end

        function schema=getPropertyTableSchema(obj)
            obj.stereotype=obj.elementWrapper.element;

            props=obj.stereotype.propertySet.properties.toArray;
            [~,schema]=obj.getPropertySubSchema(obj.propertySchemaID,'');
            schema.id=obj.elementWrapper.uuid;
            obj.colIds=schema.colIds;
            for colItr=1:numel(obj.colIds)
                colId=obj.colIds{colItr};
                colSchema={};
                colSchema.id=colId;
                colSchema.parent=NaN;
                colProperty=obj.propertyParser.getProperty(colId);
                colSchema.metadata.id=colProperty.id;
                colSchema.metadata.parent=NaN;
                colSchema.metadata.label=colProperty.label;
                schema.col{end+1}=colSchema;
            end
            index=1;
            for prop=props
                propWrapper=systemcomposer.internal.propertyInspector.wrappers.StereotypePropertyWrapper(prop.UUID,obj.elementWrapper.profileName,obj.elementWrapper.options);
                rowSchema={};
                rowSchema.id=propWrapper.uuid;
                rowSchema.parent=NaN;
                rowSchema.metadata.id=propWrapper.uuid;
                rowSchema.metadata.parent=NaN;
                rowSchema.metadata.label=num2str(index);
                for colItr=1:numel(obj.colIds)
                    colId=obj.colIds{colItr};
                    cellSchema={};
                    cellSchema.id=strcat(propWrapper.uuid,colId);
                    cellSchema.rowId=propWrapper.uuid;
                    cellSchema.colId=colId;
                    cellData=obj.propertyParser.getEvaluatedProperty(colId,propWrapper);
                    cellSchema.data={obj.formatCellInfo(cellData,cellSchema.id)};
                    schema.cell{end+1}=cellSchema;
                end
                schema.row{end+1}=rowSchema;
                index=index+1;
            end
        end

        function cellData=formatCellInfo(~,cellData,cellId)
            cellData.label=cellData.value;
            cellData.items=cellData.entries;
            cellData.isEditable=cellData.editable;
            cellData.isDisabled=~cellData.enabled;
            cellData.id=cellId;
            fields={'getter','tooltip','entries','editable','enabled'};
            cellData=rmfield(cellData,fields);
        end
    end
end



