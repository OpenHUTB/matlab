classdef ComponentPrototype<handle




    properties
        Name;
        ComponentQName;
        ComponentType;
    end

    methods
        function this=ComponentPrototype(name,compQName,type)
            this.Name=arblk.convertPortNameToArgName(name);
            this.ComponentQName=compQName;
            this.ComponentType=type;
        end
    end
end
