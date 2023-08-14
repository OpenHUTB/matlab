



classdef Port<handle
    properties(SetAccess=private)
        Name;
        Interface;
        PortType;
    end

    methods
        function obj=Port(name,interface,type)
            obj.Name=name;
            obj.Interface=interface;
            obj.PortType=type;
        end

        function setName(obj,portName)
            obj.Name=portName;
        end

        function setInterface(obj,interface)
            obj.Interface=interface;
        end

        function setType(obj,type)
            obj.PortType=type;
        end


        function dataType=getPropDataType(~,propName)
            assert(strcmp(propName,'Name'));
            dataType='string';
        end
    end

end
