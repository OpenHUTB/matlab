classdef StructType<plccore.type.AbstractType




    properties(Access=protected)
FieldNames
FieldTypes
FieldDescriptions
    end

    methods
        function obj=StructType(field_names,field_types)
            import plccore.type.TypeTool;
            assert(length(field_names)==length(field_types));
            for i=1:length(field_names)
                assert(isa(field_names{i},'char'));
                assert(isa(field_types{i},'plccore.type.AbstractType'));
                if TypeTool.isStructType(field_types{i})
                    assert(TypeTool.isNamedType(field_types{i}));
                end
            end
            obj.Kind='StructType';
            obj.FieldNames=field_names;
            obj.FieldTypes=field_types;
            obj.FieldDescriptions=cell(1,length(field_names));
        end

        function ret=numFields(obj)
            ret=length(obj.FieldNames);
        end

        function ret=fieldName(obj,idx)
            ret=obj.FieldNames{idx};
        end

        function ret=fieldType(obj,idx)
            ret=obj.FieldTypes{idx};
        end

        function setFieldType(obj,idx,field_type)
            obj.FieldTypes{idx}=field_type;
        end

        function ret=fieldDescription(obj,idx)
            ret=obj.FieldDescriptions{idx};
        end

        function setFieldName(obj,idx,field_name)
            obj.FieldNames{idx}=field_name;
        end

        function setFieldDescription(obj,idx,desc)
            obj.FieldDescriptions{idx}=desc;
        end

        function ret=hasField(obj,name)
            ret=ismember(name,obj.FieldNames);
        end

        function ret=findField(obj,name)
            ret=find(ismember(obj.FieldNames,name),1);
            assert(~isempty(ret));
        end

        function ret=toString(obj)
            ret=sprintf('Struct Type\n');
            for i=1:obj.numFields
                ret=[ret,sprintf('%s: %s\n',obj.FieldNames{i},...
                obj.FieldTypes{i}.toString)];%#ok<AGROW>
            end
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitStructType(obj,input);
        end
    end
end


