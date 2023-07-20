classdef Bus<dnnfpga.typedefs.AbstractTypeDef
    properties
Name
Elements
ElementMap
    end

    methods
        function obj=Bus(name)
            obj.Name=name;
            obj.Elements=[];
            obj.ElementMap=containers.Map('KeyType','char','ValueType','Any');
            hwt=dnnfpga.typedefs.TypeDefs.getInstance();
            hwt.add(obj);
        end
        function add(obj,busElement)
            if isa(busElement,'dnnfpga.typedefs.BusElement')
                if isKey(obj.ElementMap,busElement.Name)
                    error("Bus '%s' already has an element named '%s'..",obj.Name,busElement.Name);
                else
                    obj.ElementMap(busElement.Name)=busElement;
                    obj.Elements=[obj.Elements,busElement];
                end
            else
                msg=message('dnnfpga:workflow:InvalidDataWrongClass','busElement','dnnfpga.typedefs.BusElement',class(busElement));
                error(msg);
            end
        end
        function value=defaultValue(obj)
            value=struct();
            for i=1:numel(obj.Elements)
                be=obj.Elements(i);
                value.(be.Name)=be.defaultValue();
            end
        end
    end
end
