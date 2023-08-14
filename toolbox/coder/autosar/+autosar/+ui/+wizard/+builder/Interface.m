



classdef Interface<handle
    properties(SetAccess=private)
        Name;
        InterfaceType;
    end

    methods
        function obj=Interface(name,type)
            obj.Name=name;
            obj.InterfaceType=type;
        end

        function setName(obj,interfaceName)
            obj.Name=interfaceName;
        end

        function setType(obj,type)
            obj.InterfaceType=type;
        end


        function dataType=getPropDataType(~,propName)
            strProps={'Name','InterfaceType'};
            assert(any(strcmp(propName,strProps)));
            dataType='string';
        end

    end

end
