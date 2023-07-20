classdef(Abstract)Object<handle




    properties(Access=protected)
Kind
Tag
    end

    methods
        function obj=Object
            obj.Kind='Object';
            obj.Tag=[];
        end

        function ret=kind(obj)
            ret=obj.Kind;
        end

        function ret=tag(obj)
            ret=obj.Tag;
        end

        function setTag(obj,tag)
            obj.Tag=tag;
        end

        function ret=toString(obj)
            ret=obj.Kind;
        end

        function disp(obj)
            fprintf('%s\n',obj.toString);
        end

        function result=isa(obj,cls_name)
            result=builtin('isa',obj,cls_name);
        end

        function ret=accept(obj,visitor,input)
            obj.checkVisitor(visitor);
            ret=obj.callVisitor(visitor,input);
        end

        function ret=equal(obj,other)
            ret=false;
            if~isa(other,'plccore.common.Object')
                return;
            end
            ret=strcmp(obj.toString,other.toString);
        end
    end

    methods(Access=protected)
        function checkVisitor(obj,visitor)%#ok<INUSL>
            assert(visitor.isa('plccore.visitor.AbstractVisitor'));
        end

        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitObject(obj,input);
        end
    end
end


