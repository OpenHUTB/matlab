classdef ArrayType<plccore.type.AbstractType




    properties(Access=protected)
DimList
ElemType
    end

    methods
        function obj=ArrayType(dim_list,elem_type)
            assert(isa(elem_type,'plccore.type.AbstractType'));
            assert(isa(dim_list,'double'));
            obj.Kind='ArrayType';
            obj.DimList=dim_list;
            obj.ElemType=elem_type;
        end

        function ret=numDims(obj)
            ret=length(obj.DimList);
        end

        function ret=numElem(obj)
            ret=1;
            for i=1:length(obj.DimList)
                ret=ret*obj.DimList(i);
            end
        end

        function ret=dims(obj)
            ret=obj.DimList;
        end

        function setDims(obj,dim_list)
            obj.DimList=dim_list;
        end

        function ret=dim(obj,dim_idx)
            assert(dim_idx>=1&&dim_idx<=length(obj.DimList));
            ret=obj.DimList(dim_idx);
        end

        function ret=elemType(obj)
            ret=obj.ElemType;
        end

        function ret=resetElemType(obj)
            ret=obj.ElemType;
        end

        function ret=toString(obj)
            ret=sprintf('Array [');
            for i=1:obj.numDims
                ret=sprintf('%s %d',ret,obj.DimList(i));
            end
            ret=sprintf('%s] of %s',ret,obj.ElemType.toString);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitArrayType(obj,input);
        end
    end
end


