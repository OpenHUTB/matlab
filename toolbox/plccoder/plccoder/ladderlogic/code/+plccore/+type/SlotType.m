classdef SlotType<plccore.type.AbstractType




    properties(Access=protected)
Name
Type
Description
    end

    methods
        function obj=SlotType(name,type,desc)
            obj.Kind='SlotType';
            assert(type.isa('plccore.type.AbstractType'));
            obj.Name=name;
            obj.Type=type;
            if nargin>2
                assert(isa(desc,'char'));
                obj.Description=desc;
            else
                obj.Description='';
            end
        end

        function ret=name(obj)
            ret=obj.Name;
        end

        function ret=type(obj)
            ret=obj.Type;
        end

        function resetType(obj,typ)
            obj.Type=typ;
        end

        function ret=description(obj)
            ret=obj.Description;
        end

        function setDescription(obj,desc)
            obj.Description=desc;
        end

        function ret=toString(obj)
            ret='';
            if~isempty(obj.Description)
                ret=sprintf('/* %s */ ',obj.Description);
            end
            ret=sprintf('%s%s (PLC Slot/Port)= %s',ret,obj.name,obj.type.toString);
        end
    end

    methods(Access=protected)
        function ret=callVisitor(obj,visitor,input)
            ret=visitor.visitSlotType(obj,input);
        end
    end
end


