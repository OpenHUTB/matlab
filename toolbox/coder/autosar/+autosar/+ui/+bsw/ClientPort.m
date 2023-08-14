



classdef ClientPort<handle
    properties(SetAccess=private)
        Name;
        PortDefinedArgument;
        IdType;
    end

    methods
        function obj=ClientPort(name,idType,arg)
            obj.Name=name;
            obj.IdType=idType;
            obj.PortDefinedArgument=arg;
        end

        function setName(obj,name)
            obj.Name=name;
        end

        function setPortDefinedArgument(obj,portDefinedArgument)
            obj.PortDefinedArgument=portDefinedArgument;
        end
    end
end
