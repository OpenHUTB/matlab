


classdef EntryInfo

    properties
Name
Value
Status
DataSource
LastModified
LastModifiedBy

UUID
ParentUUID
Variant
SchemaElement
SchemaElementMemberIndex
ValueTypeID
ClassName
MetaclassName
    end

    properties(Dependent=true)
Key
    end

    methods
        function entry=...
            EntryInfo(name,value,dataSource,status,lastModified,...
            lastModifiedBy,uuid,parentUUID,variant,...
            schemaElement,schemaElementMemberIndex,...
            valueTypeID,className,metaclassName)
            entry.Name=name;
            entry.Value=value;
            entry.DataSource=dataSource;
            entry.Status=status;
            entry.LastModified=lastModified;
            entry.LastModifiedBy=lastModifiedBy;
            entry.UUID=uuid;
            entry.ParentUUID=parentUUID;
            entry.Variant=variant;
            entry.SchemaElement=schemaElement;
            entry.SchemaElementMemberIndex=schemaElementMemberIndex;
            entry.ValueTypeID=valueTypeID;
            entry.ClassName=className;
            entry.MetaclassName=metaclassName;
        end

        function obj=set.Name(obj,name)
            validateattributes(name,{'char'},{'row'});
            obj.Name=name;
        end



        function obj=set.DataSource(obj,dataSource)
            validateattributes(dataSource,{'char'},{});
            obj.DataSource=dataSource;
        end

        function obj=set.Status(obj,status)
            validateattributes(status,{'char'},{});
            obj.Status=status;
        end

        function obj=set.LastModified(obj,lastModified)
            validateattributes(lastModified,{'char'},{'row'});
            obj.LastModified=lastModified;
        end

        function obj=set.LastModifiedBy(obj,lastModifiedBy)
            validateattributes(lastModifiedBy,{'char'},{});
            obj.LastModifiedBy=lastModifiedBy;
        end

        function obj=set.UUID(obj,uuid)
            validateattributes(uuid,{'Simulink.dd.UUID'},{'scalar'});
            obj.UUID=uuid;
        end

        function obj=set.ParentUUID(obj,parentUUID)
            validateattributes(parentUUID,{'Simulink.dd.UUID'},{'scalar'});
            obj.ParentUUID=parentUUID;
        end

        function obj=set.Variant(obj,variant)
            validateattributes(variant,{'char'},{});
            obj.Variant=variant;
        end

        function obj=set.SchemaElement(obj,schemaElement)

            obj.SchemaElement=schemaElement;
        end

        function obj=set.SchemaElementMemberIndex(obj,schemaElementMemberIndex)
            validateattributes(schemaElementMemberIndex,{'numeric'},{'scalar'});
            obj.SchemaElementMemberIndex=int32(schemaElementMemberIndex);
        end

        function obj=set.ValueTypeID(obj,valueTypeID)
            validateattributes(valueTypeID,{'char'},{'scalar'});
            obj.ValueTypeID=valueTypeID;
        end

        function obj=set.ClassName(obj,className)
            validateattributes(className,{'char'},{});
            obj.ClassName=className;
        end

        function obj=set.MetaclassName(obj,metaclassName)
            validateattributes(metaclassName,{'char'},{});
            obj.MetaclassName=metaclassName;
        end
    end
end
