classdef ArrayValue<plccore.common.ConstValue




    properties(Access=protected)
ElemValueList
    end

    methods
        function obj=ArrayValue(type,elem_value_list)
            obj@plccore.common.ConstValue(type,'');
            obj.Kind='ArrayValue';
            obj.ElemValueList=elem_value_list;
            assert(isa(obj.type,'plccore.type.ArrayType'));
            assert(obj.type.numElem==length(obj.ElemValueList));
        end

        function ret=toString(obj)
            ret=sprintf('Array Value\n');
            for i=1:obj.type.numElem
                ret=sprintf('%selement value(%d): %s\n',ret,i-1,obj.ElemValueList{i}.toString);
            end
        end

        function ret=elemValueList(obj)
            ret=obj.ElemValueList;
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitArrayValue(obj,input);
        end
    end
end


