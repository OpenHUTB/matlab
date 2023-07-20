classdef StructValue<plccore.common.ConstValue




    properties(Access=protected)
FieldNameList
FieldValueList
    end

    methods
        function obj=StructValue(type,field_name_list,field_value_list)
            import plccore.type.TypeTool;
            obj@plccore.common.ConstValue(type,'');
            obj.Kind='StructValue';
            obj.FieldNameList=field_name_list;
            obj.FieldValueList=field_value_list;
            assert(length(obj.FieldNameList)==length(obj.FieldValueList));
        end

        function ret=structType(obj)
            import plccore.type.TypeTool;
            ret=TypeTool.structType(obj.type);
        end

        function ret=toString(obj)
            ret=sprintf('Struct Value\n');
            for i=1:length(obj.fieldNameList)
                ret=sprintf('%sfield %s: %s\n',ret,obj.fieldNameList{i},...
                obj.fieldValueList{i}.toString);
            end
        end

        function ret=fieldNameList(obj)
            ret=obj.FieldNameList;
        end

        function ret=setFieldNameList(obj,fn_list)
            obj.FieldNameList=fn_list;
            ret=[];
        end

        function ret=fieldValueList(obj)
            ret=obj.FieldValueList;
        end

        function ret=fieldValue(obj,name)
            assert(obj.hasFieldValue(name));
            idx=find(ismember(obj.fieldNameList,name),1);
            ret=obj.fieldValueList{idx};
        end

        function ret=hasFieldValue(obj,name)
            ret=ismember(name,obj.fieldNameList);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitStructValue(obj,input);
        end
    end
end


